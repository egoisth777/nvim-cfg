-- In-terminal LaTeX PDF preview.
--
-- Shows one page of the compiled PDF in a right-hand split, drawn inside the
-- terminal by snacks.image (kitty graphics protocol). A 1-row status split
-- sits under it (page N/M, follow state).
--
-- Sync, both directions:
--   tex -> pdf : `synctex view` maps cursor line -> page. Runs on demand
--                (forward/view keys, ctrl+click in tex) and in follow mode
--                (debounced CursorMoved; CursorHold is unusable here because
--                updatetime is 30 s).
--   pdf -> tex : ctrl+click on the page -> `synctex edit` maps the click
--                (cell -> PDF points) -> file:line, cursor jumps there.
--   disk -> pdf: a file watcher re-renders after the compiled PDF changes,
--                whatever wrote it (vimtex latexmk -pvc, texlab, external).
--
-- Why snapshots: snacks.image caches conversions by source path, so a PDF that
-- is rewritten in place would keep showing the old render. Each refresh copies
-- the PDF to a uniquely named file in the snacks image cache and renders that;
-- the previous snapshot and its rasters are deleted.
--
-- Why no winbar: on terminals without unicode placeholders (WezTerm) snacks
-- paints the image from the window's top-left cell, which is the winbar row.
--
-- Requirements: kitty-graphics terminal (WezTerm/kitty/ghostty), `magick`, `gs`.
-- Optional: `pdfinfo` (page count/size), `synctex` (forward/inverse/follow).
local M = {}

local uv = vim.uv or vim.loop
local api = vim.api

M.config = {
  width = 0.45, -- preview split width as a fraction of the editor columns
  follow = true, -- start with follow mode on
  debounce = 400, -- ms of quiet after the last PDF write before re-rendering
  follow_debounce = 250, -- ms of cursor rest before follow mode re-syncs
}

-- Session state. `pdf` is the real compiled file; `src` is the snapshot shown.
local S = {
  buf = nil, ---@type integer?  image buffer
  win = nil, ---@type integer?  image window
  sbuf = nil, ---@type integer? status buffer
  swin = nil, ---@type integer? status window
  pdf = nil, ---@type string?
  src = nil, ---@type string?
  tex_buf = nil, ---@type integer?
  placement = nil, ---@type snacks.image.Placement?
  page = 1,
  pages = nil, ---@type integer?
  page_size = nil, ---@type {[1]: number, [2]: number}? PDF points (w, h)
  follow = M.config.follow,
  gen = 0,
  mtime = nil, ---@type integer?
  watcher = nil, ---@type uv.uv_fs_event_t?
  timer = nil, ---@type uv.uv_timer_t?
  follow_timer = nil, ---@type uv.uv_timer_t?
  last = nil, ---@type {[1]: integer, [2]: integer}? last synced {buf, line}
  augroup = nil, ---@type integer?
}

local TEX_FT = { tex = true, plaintex = true, latex = true }
local DEFAULT_PAGE_SIZE = { 595.276, 841.89 } -- A4, used when no tool reports the size

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = "LaTeX preview" })
end

local function is_tex(buf)
  return TEX_FT[vim.bo[buf].filetype] == true
end

local function has_snacks()
  return _G.Snacks ~= nil and Snacks.image ~= nil and Snacks.image.placement ~= nil
end

local function cache_dir()
  local dir = Snacks.image.config.cache
  vim.fn.mkdir(dir, "p")
  return dir
end

local function file_mtime_ms(stat)
  return stat.mtime.sec * 1000 + math.floor(stat.mtime.nsec / 1e6)
end

local function close_timer(t)
  if t then
    t:stop()
    if not t:is_closing() then
      t:close()
    end
  end
end

function M.is_open()
  return S.win ~= nil and api.nvim_win_is_valid(S.win) and S.buf ~= nil and api.nvim_buf_is_valid(S.buf)
end

--- Resolve the compiled PDF for a tex buffer.
--- Order: vimtex compiler output, vimtex root/name.pdf, <buffer>.pdf.
---@param buf? integer
---@return string? path, string? source one of "vimtex", "vimtex-root", "buffer"
function M.pdf_path(buf)
  buf = buf or api.nvim_get_current_buf()
  local ok, out = pcall(api.nvim_buf_call, buf, function()
    return api.nvim_eval(
      "exists('b:vimtex') && exists('*b:vimtex.compiler.get_file') ? b:vimtex.compiler.get_file('pdf') : ''"
    )
  end)
  if ok and type(out) == "string" and out ~= "" and uv.fs_stat(out) then
    return out, "vimtex"
  end
  local ok2, rootname = pcall(api.nvim_buf_call, buf, function()
    return api.nvim_eval("exists('b:vimtex') ? get(b:vimtex, 'root', '') . '/' . get(b:vimtex, 'name', '') : ''")
  end)
  if ok2 and type(rootname) == "string" and rootname ~= "/" and rootname ~= "" then
    local cand = rootname .. ".pdf"
    if uv.fs_stat(cand) then
      return cand, "vimtex-root"
    end
  end
  local name = api.nvim_buf_get_name(buf)
  if name ~= "" then
    local cand = vim.fn.fnamemodify(name, ":p:r") .. ".pdf"
    if uv.fs_stat(cand) then
      return cand, "buffer"
    end
  end
  return nil
end

-- Snapshot naming: lp-<nvim pid>-<8 hex of pdf path>-<generation>.
-- The pid scopes deletion to this Neovim instance.
local function stem_prefix()
  return ("lp-%d-%s-"):format(vim.fn.getpid(), vim.fn.sha256(S.pdf):sub(1, 8))
end

local function purge_glob(pattern)
  for _, f in ipairs(vim.fn.glob(pattern, true, true)) do
    pcall(vim.fn.delete, f)
  end
end

--- Delete snapshot + rasters for one stem (or every stem of this pdf).
---@param stem? string
local function purge(stem)
  if not has_snacks() then
    return
  end
  -- "<stem>.*" keeps generation 1 from matching generation 10, 11, ...
  purge_glob(cache_dir() .. "/*" .. (stem and (stem .. ".*") or (stem_prefix() .. "*")))
end

--- Delete leftovers: anything from this Neovim process (only one preview
--- session exists at a time) and anything older than a day from others
--- (crashed or killed sessions never reach VimLeavePre).
local function purge_stale()
  purge_glob(cache_dir() .. "/*lp-" .. vim.fn.getpid() .. "-*")
  local now = os.time()
  for _, f in ipairs(vim.fn.glob(cache_dir() .. "/*lp-*", true, true)) do
    local st = uv.fs_stat(f)
    if st and now - st.mtime.sec > 86400 then
      pcall(vim.fn.delete, f)
    end
  end
end

--- Kill a conversion that is still running for the current placement, so a
--- late `magick` write cannot resurrect a raster after purge.
local function abort_conversion()
  local img = S.placement and S.placement.img
  local conv = img and img._convert
  if conv and not conv:done() then
    pcall(conv.abort, conv)
  end
end

--- Copy the real PDF to a fresh snapshot. Returns the snapshot path.
---@return string?
local function snapshot()
  S.gen = S.gen + 1
  local dst = cache_dir() .. "/" .. stem_prefix() .. S.gen .. ".pdf"
  local ok, err = uv.fs_copyfile(S.pdf, dst)
  if not ok then
    notify("Copy failed: " .. tostring(err), vim.log.levels.ERROR)
    return nil
  end
  return dst
end

--- Page count and first-page size (PDF points).
---@param pdf string
---@param cb fun(n: integer?, size: {[1]: number, [2]: number}?)
local function pdf_info(pdf, cb)
  if vim.fn.executable("pdfinfo") == 1 then
    vim.system({ "pdfinfo", pdf }, { text = true }, function(res)
      local out = res.stdout or ""
      local n = tonumber(out:match("Pages:%s+(%d+)"))
      local w, h = out:match("Page size:%s+([%d%.]+)%s+x%s+([%d%.]+)")
      vim.schedule(function()
        cb(n, (w and h) and { tonumber(w), tonumber(h) } or nil)
      end)
    end)
  elseif vim.fn.executable("gs") == 1 then
    local f = (pdf:gsub("\\", "/"))
    local ps = ("(%s) (r) file runpdfbegin pdfpagecount == 1 pdfgetpage /MediaBox pget pop == quit"):format(f)
    vim.system({ "gs", "-q", "-dNODISPLAY", "-dNOSAFER", "-c", ps }, { text = true }, function(res)
      local out = res.stdout or ""
      local n = tonumber(out:match("^%s*(%d+)"))
      local x0, y0, x1, y1 = out:match("%[([%d%.%-]+)%s+([%d%.%-]+)%s+([%d%.%-]+)%s+([%d%.%-]+)%]")
      vim.schedule(function()
        cb(n, x1 and { tonumber(x1) - tonumber(x0), tonumber(y1) - tonumber(y0) } or nil)
      end)
    end)
  else
    cb(nil, nil)
  end
end

--- Map a tex position to a PDF page with `synctex view`.
---@param buf integer
---@param line integer 1-based
---@param col integer 1-based
---@param cb fun(page: integer?, err: string?)
local function synctex_page(buf, line, col, cb)
  if vim.fn.executable("synctex") ~= 1 then
    return cb(nil, "synctex not found")
  end
  local tex = api.nvim_buf_get_name(buf)
  if tex == "" or not S.pdf then
    return cb(nil, "no file")
  end
  vim.system(
    { "synctex", "view", "-i", ("%d:%d:%s"):format(line, col, tex), "-o", S.pdf },
    { text = true },
    function(res)
      local page = tonumber((res.stdout or ""):match("Page:(%d+)"))
      vim.schedule(function()
        cb(page, page == nil and "no synctex match" or nil)
      end)
    end
  )
end

local function set_lines(buf, lines)
  if not (buf and api.nvim_buf_is_valid(buf)) then
    return
  end
  vim.bo[buf].modifiable = true
  api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].modified = false
end

local function update_status()
  if not M.is_open() then
    return
  end
  local name = vim.fs.basename(S.pdf or "")
  local pages = S.pages and tostring(S.pages) or "?"
  local follow = S.follow and "  [follow]" or ""
  set_lines(S.sbuf, { (" %s  p. %d/%s%s   j/k page  r refresh  q close  ctrl+click jump"):format(name, S.page, pages, follow) })
end

--- Current status text (for tests and statuslines).
function M.status_text()
  if S.sbuf and api.nvim_buf_is_valid(S.sbuf) then
    return api.nvim_buf_get_lines(S.sbuf, 0, 1, false)[1] or ""
  end
  return ""
end

local function render()
  if not M.is_open() then
    return
  end
  Snacks.image.placement.clean(S.buf)
  S.placement = nil
  if not Snacks.image.supports_terminal() then
    set_lines(S.buf, {
      "LaTeX preview: this terminal does not support the kitty graphics protocol.",
      "Use WezTerm, kitty, or ghostty. See :checkhealth snacks.",
      "",
      "PDF: " .. tostring(S.pdf),
    })
    update_status()
    return
  end
  if not S.src then
    return
  end
  set_lines(S.buf, { "" })
  S.placement = Snacks.image.placement.new(S.buf, S.src .. "#page=" .. S.page, { conceal = true, auto_resize = true })
  update_status()
end

local function clamp_page(n)
  n = math.max(1, math.floor(n))
  if S.pages then
    n = math.min(n, S.pages)
  end
  return n
end

---@param n integer
function M.goto_page(n)
  if not M.is_open() then
    return
  end
  n = clamp_page(n)
  if n == S.page then
    update_status()
    return
  end
  S.page = n
  render()
end

function M.next_page()
  M.goto_page(S.page + 1)
end

function M.prev_page()
  M.goto_page(S.page - 1)
end

function M.first_page()
  M.goto_page(1)
end

function M.last_page()
  M.goto_page(S.pages or S.page)
end

--- Forward search for a tex buffer's cursor. Opens the preview if needed.
---@param opts? {buf?: integer, win?: integer, silent?: boolean}
function M.forward(opts)
  opts = opts or {}
  local buf = opts.buf or api.nvim_get_current_buf()
  local win = opts.win or api.nvim_get_current_win()
  if not is_tex(buf) then
    if not opts.silent then
      notify("Not a LaTeX buffer", vim.log.levels.WARN)
    end
    return
  end
  if not M.is_open() then
    M.open() -- open() performs the initial forward search itself
    return
  end
  local cur = api.nvim_win_get_cursor(win)
  S.last = { buf, cur[1] }
  synctex_page(buf, cur[1], cur[2] + 1, function(page, err)
    if page then
      M.goto_page(page)
    elseif not opts.silent then
      notify("Forward search failed: " .. tostring(err), vim.log.levels.WARN)
    end
  end)
end

--- CursorMoved hook: in follow mode, re-sync the page once the cursor rests
--- on a different line.
function M.follow_tick()
  if not (S.follow and M.is_open()) then
    return
  end
  local buf = api.nvim_get_current_buf()
  local win = api.nvim_get_current_win()
  if buf == S.buf or buf == S.sbuf or not is_tex(buf) then
    return
  end
  if not S.follow_timer then
    S.follow_timer = assert(uv.new_timer())
  end
  S.follow_timer:stop()
  S.follow_timer:start(M.config.follow_debounce, 0, function()
    vim.schedule(function()
      if not (S.follow and M.is_open()) then
        return
      end
      if not api.nvim_win_is_valid(win) or api.nvim_win_get_buf(win) ~= buf then
        return
      end
      local line = api.nvim_win_get_cursor(win)[1]
      if S.last and S.last[1] == buf and S.last[2] == line then
        return
      end
      M.forward({ buf = buf, win = win, silent = true })
    end)
  end)
end

-- After a rebuild the same line may land on a different page: re-run forward
-- search from the tex window that is visible (current window preferred).
local function resync_after_refresh()
  if not S.follow then
    return
  end
  local buf = api.nvim_get_current_buf()
  local win = api.nvim_get_current_win()
  if not is_tex(buf) then
    if not (S.tex_buf and api.nvim_buf_is_valid(S.tex_buf)) then
      return
    end
    win = vim.fn.bufwinid(S.tex_buf)
    if win == -1 then
      return
    end
    buf = S.tex_buf
  end
  M.forward({ buf = buf, win = win, silent = true })
end

---@param force boolean redraw even if the file's mtime is unchanged
---@param resync boolean re-run forward search afterwards (follow mode)
local function refresh_impl(force, resync)
  if not M.is_open() then
    return
  end
  local stat = uv.fs_stat(S.pdf)
  if not stat or stat.size == 0 then
    return -- mid-build; the watcher will call again
  end
  local ms = file_mtime_ms(stat)
  if not force and S.src and S.mtime == ms then
    return
  end
  local old = S.src
  local src = snapshot()
  if not src then
    return
  end
  S.src, S.mtime, S.last = src, ms, nil
  render()
  if old then
    purge(vim.fn.fnamemodify(old, ":t:r"))
  end
  pdf_info(src, function(n, size)
    if not M.is_open() or S.src ~= src then
      return
    end
    S.pages = n
    S.page_size = size or S.page_size
    local clamped = clamp_page(S.page)
    if clamped ~= S.page then
      S.page = clamped
      render()
    else
      update_status()
    end
  end)
  if resync then
    resync_after_refresh()
  end
end

--- Re-read the PDF from disk and redraw the current page.
---@param force? boolean redraw even if the file's mtime is unchanged
function M.refresh(force)
  refresh_impl(force == true, true)
end

local function schedule_refresh()
  if not S.timer then
    S.timer = assert(uv.new_timer())
  end
  S.timer:stop()
  S.timer:start(M.config.debounce, 0, function()
    vim.schedule(function()
      refresh_impl(false, true)
    end)
  end)
end

local function stop_watch()
  if S.watcher then
    pcall(S.watcher.stop, S.watcher)
    if not S.watcher:is_closing() then
      S.watcher:close()
    end
    S.watcher = nil
  end
  close_timer(S.timer)
  close_timer(S.follow_timer)
  S.timer, S.follow_timer = nil, nil
end

local function start_watch()
  stop_watch()
  local dir = vim.fs.dirname(S.pdf)
  local name = vim.fs.basename(S.pdf)
  local handle = uv.new_fs_event()
  if not handle then
    notify("File watcher unavailable; use r / <leader>lr to refresh", vim.log.levels.WARN)
    return
  end
  local ok, err = handle:start(dir, {}, function(e, fname)
    if e then
      return
    end
    if fname and fname ~= name then
      return
    end
    schedule_refresh()
  end)
  if not ok then
    notify("File watcher failed: " .. tostring(err), vim.log.levels.WARN)
    handle:close()
    return
  end
  S.watcher = handle
end

-- ---------------------------------------------------------------------------
-- Inverse search (pdf -> tex)
-- ---------------------------------------------------------------------------

--- Find or open `file` in a non-preview window and put the cursor on `line`.
local function jump_to(file, line)
  local target = vim.fs.normalize(vim.fn.fnamemodify(file, ":p")):lower()
  local buf ---@type integer?
  for _, b in ipairs(api.nvim_list_bufs()) do
    if api.nvim_buf_is_loaded(b) and vim.fs.normalize(api.nvim_buf_get_name(b)):lower() == target then
      buf = b
      break
    end
  end
  local win = buf and vim.fn.bufwinid(buf) or -1
  if win == -1 then
    win = (S.tex_buf and api.nvim_buf_is_valid(S.tex_buf)) and vim.fn.bufwinid(S.tex_buf) or -1
    if win == -1 then
      for _, w in ipairs(api.nvim_tabpage_list_wins(0)) do
        if w ~= S.win and w ~= S.swin and api.nvim_win_get_config(w).relative == "" then
          win = w
          break
        end
      end
    end
    if win == -1 then
      notify("No window to show " .. file, vim.log.levels.WARN)
      return false
    end
    api.nvim_set_current_win(win)
    if buf then
      api.nvim_win_set_buf(win, buf)
    else
      vim.cmd.edit(vim.fn.fnameescape(file))
      buf = api.nvim_get_current_buf()
    end
  else
    api.nvim_set_current_win(win)
  end
  line = math.max(1, math.min(line, api.nvim_buf_line_count(buf)))
  api.nvim_win_set_cursor(win, { line, 0 })
  vim.cmd("normal! zz")
  S.last = { buf, line }
  return true
end

--- Inverse search from a point on the current page.
---@param fx number 0..1 fraction of page width from the left
---@param fy number 0..1 fraction of page height from the top
---@param cb? fun(ok: boolean, file?: string, line?: integer)
function M.inverse(fx, fy, cb)
  cb = cb or function() end
  if not M.is_open() then
    return cb(false)
  end
  if vim.fn.executable("synctex") ~= 1 then
    notify("synctex not found; inverse search unavailable", vim.log.levels.WARN)
    return cb(false)
  end
  local size = S.page_size or DEFAULT_PAGE_SIZE
  local spec = ("%d:%.2f:%.2f:%s"):format(S.page, fx * size[1], fy * size[2], S.pdf)
  vim.system({ "synctex", "edit", "-o", spec }, { text = true }, function(res)
    local out = res.stdout or ""
    local input = out:match("Input:([^\r\n]+)")
    local line = tonumber(out:match("Line:(%d+)"))
    vim.schedule(function()
      if not (input and line) then
        notify("Inverse search: no match on page " .. S.page, vim.log.levels.WARN)
        return cb(false)
      end
      local ok = jump_to(input, line)
      cb(ok, input, line)
    end)
  end)
end

--- Screen rectangle of the rendered page: 0-based top-left row/col and size in cells.
local function image_rect()
  local pos = api.nvim_win_get_position(S.win)
  local loc = S.placement and S.placement._state and S.placement._state.loc
  return {
    row = pos[1],
    col = pos[2],
    width = loc and loc.width or api.nvim_win_get_width(S.win),
    height = loc and loc.height or api.nvim_win_get_height(S.win),
  }
end

--- Ctrl+click handler shared by tex buffers and the preview: dispatches on
--- where the mouse is, not on which window has focus.
function M.ctrl_click()
  local mp = vim.fn.getmousepos()
  if mp.winid == 0 then
    return
  end
  if M.is_open() and mp.winid == S.win then
    local r = image_rect()
    local fx = (mp.screencol - 1 - r.col) / r.width
    local fy = (mp.screenrow - 1 - r.row) / r.height
    if fx < 0 or fx >= 1 or fy < 0 or fy >= 1 then
      return
    end
    M.inverse(fx, fy)
    return
  end
  local buf = api.nvim_win_get_buf(mp.winid)
  if not is_tex(buf) then
    return
  end
  api.nvim_set_current_win(mp.winid)
  local line = mp.line > 0 and mp.line or api.nvim_buf_line_count(buf)
  api.nvim_win_set_cursor(mp.winid, { line, math.max(mp.column - 1, 0) })
  M.forward({ buf = buf, win = mp.winid })
end

-- ---------------------------------------------------------------------------
-- Windows
-- ---------------------------------------------------------------------------

local function set_keymaps(buf)
  local function map(lhs, rhs, desc)
    vim.keymap.set("n", lhs, rhs, { buffer = buf, nowait = true, silent = true, desc = "LaTeX preview: " .. desc })
  end
  map("j", M.next_page, "next page")
  map("<Down>", M.next_page, "next page")
  map("k", M.prev_page, "prev page")
  map("<Up>", M.prev_page, "prev page")
  map("gg", M.first_page, "first page")
  map("G", M.last_page, "last page")
  map("r", function()
    M.refresh(true)
  end, "refresh")
  map("q", M.close, "close")
  map("<C-LeftMouse>", M.ctrl_click, "inverse search")
end

local function scratch(ft, name)
  local buf = api.nvim_create_buf(false, true)
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.bo[buf].filetype = ft
  pcall(api.nvim_buf_set_name, buf, name)
  return buf
end

local function reset_state()
  S.buf, S.win, S.sbuf, S.swin = nil, nil, nil, nil
  S.pdf, S.src, S.tex_buf, S.placement = nil, nil, nil, nil
  S.pages, S.page_size, S.mtime, S.last = nil, nil, nil, nil
  S.page = 1
end

function M.close()
  stop_watch()
  if S.augroup then
    pcall(api.nvim_del_augroup_by_id, S.augroup)
    S.augroup = nil
  end
  local pattern = (S.pdf and has_snacks()) and (cache_dir() .. "/*" .. stem_prefix() .. "*") or nil
  abort_conversion()
  if S.buf and api.nvim_buf_is_valid(S.buf) and has_snacks() then
    Snacks.image.placement.clean(S.buf)
  end
  for _, w in ipairs({ S.swin, S.win }) do
    if w and api.nvim_win_is_valid(w) then
      pcall(api.nvim_win_close, w, true)
    end
  end
  for _, b in ipairs({ S.sbuf, S.buf }) do
    if b and api.nvim_buf_is_valid(b) then
      pcall(api.nvim_buf_delete, b, { force = true })
    end
  end
  if pattern then
    purge_glob(pattern)
    -- process kill is asynchronous; sweep once more after it has surely died
    vim.defer_fn(function()
      purge_glob(pattern)
    end, 1500)
  end
  reset_state()
end

--- Open the preview for the current tex buffer.
---@return boolean opened
function M.open()
  if M.is_open() then
    return true
  end
  local tex_buf = api.nvim_get_current_buf()
  local tex_win = api.nvim_get_current_win()
  if not is_tex(tex_buf) then
    notify("Not a LaTeX buffer", vim.log.levels.WARN)
    return false
  end
  if not has_snacks() then
    notify("snacks.nvim image module is not available", vim.log.levels.ERROR)
    return false
  end
  local pdf = M.pdf_path(tex_buf)
  if not pdf then
    notify("No compiled PDF found. Compile first (<leader>lc).", vim.log.levels.WARN)
    return false
  end

  reset_state()
  S.pdf, S.tex_buf = pdf, tex_buf
  purge_stale()

  local name = vim.fs.basename(pdf)
  S.buf = scratch("latex_preview", "latex-preview://" .. name)
  S.sbuf = scratch("latex_preview_status", "latex-preview-status://" .. name)
  set_keymaps(S.buf)
  set_keymaps(S.sbuf)

  local width = math.max(20, math.floor(vim.o.columns * M.config.width))
  S.win = api.nvim_open_win(S.buf, false, { split = "right", win = -1, width = width })
  vim.wo[S.win].winfixwidth = true
  S.swin = api.nvim_open_win(S.sbuf, false, { split = "below", win = S.win, height = 1 })
  vim.wo[S.swin].winfixheight = true
  vim.wo[S.swin].winfixwidth = true
  vim.wo[S.swin].number = false
  vim.wo[S.swin].relativenumber = false
  vim.wo[S.swin].cursorline = false
  vim.wo[S.swin].signcolumn = "no"
  vim.wo[S.swin].statuscolumn = ""
  vim.wo[S.swin].wrap = false
  vim.wo[S.swin].winhighlight = "Normal:WinBar,NormalNC:WinBarNC"
  api.nvim_win_set_height(S.swin, 1)

  S.augroup = api.nvim_create_augroup("latex_preview", { clear = true })
  api.nvim_create_autocmd("WinClosed", {
    group = S.augroup,
    pattern = { tostring(S.win), tostring(S.swin) },
    once = true,
    callback = function()
      vim.schedule(M.close)
    end,
  })
  api.nvim_create_autocmd("VimLeavePre", {
    group = S.augroup,
    callback = function()
      if S.pdf then
        purge()
      end
    end,
  })

  set_lines(S.buf, { "Loading …" })
  update_status()
  start_watch()

  require("snacks.image.terminal").detect(function()
    vim.schedule(function()
      if not M.is_open() then
        return
      end
      -- Initial page: cursor's page when synctex is available, else page 1.
      local cur = api.nvim_win_is_valid(tex_win) and api.nvim_win_get_cursor(tex_win) or { 1, 0 }
      synctex_page(tex_buf, cur[1], cur[2] + 1, function(page)
        if not M.is_open() then
          return
        end
        S.page = page or 1
        S.follow = M.config.follow
        refresh_impl(true, false)
        S.last = { tex_buf, cur[1] }
      end)
    end)
  end)
  return true
end

function M.toggle()
  if M.is_open() then
    M.close()
  else
    M.open()
  end
end

function M.toggle_follow()
  S.follow = not S.follow
  update_status()
  notify("Follow mode " .. (S.follow and "on" or "off"))
  if S.follow then
    resync_after_refresh()
  end
end

--- Read-only view of the session state (for tests and statuslines).
function M.state()
  return {
    open = M.is_open(),
    pdf = S.pdf,
    src = S.src,
    page = S.page,
    pages = S.pages,
    page_size = S.page_size,
    follow = S.follow,
    buf = S.buf,
    win = S.win,
    status_win = S.swin,
  }
end

return M
