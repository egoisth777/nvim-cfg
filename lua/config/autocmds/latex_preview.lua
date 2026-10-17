-- Event wiring for the in-terminal LaTeX PDF preview (lua/utility/latex_preview.lua).
-- Lives here, not in a plugin spec `init`, because lazy.nvim lets only one
-- `init` per plugin survive fragment merging and vimtex already owns one.
local group = vim.api.nvim_create_augroup("latex_preview_follow", { clear = true })

-- Follow mode: CursorMoved, not CursorHold — updatetime is 30 s in this config
-- (config/autocmds/autosaving.lua). The module debounces internally.
vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
    group = group,
    pattern = { "*.tex", "*.ltx", "*.latex" },
    callback = function()
        local ok, mod = pcall(require, "utility.latex_preview")
        if ok then
            mod.follow_tick()
        end
    end,
})

-- Ctrl+click in a tex buffer -> preview page. The same handler also serves
-- clicks that land on the preview window (inverse search), whichever window
-- has focus.
vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = { "tex", "plaintex" },
    callback = function(ev)
        vim.keymap.set("n", "<C-LeftMouse>", function()
            require("utility.latex_preview").ctrl_click()
        end, { buffer = ev.buf, silent = true, desc = "LaTeX preview: forward search at click" })
    end,
})
