-- Headless entry point:  nvim --headless -l tests/run.lua  (from repo root)
--
-- Runs every *_spec.lua in this directory and exits non-zero on any failure so
-- the suite is usable as a pre-commit / CI gate. Specs are plain functions of
-- the harness rather than auto-registering globals, so loading order is
-- explicit and a spec can be run in isolation while debugging.

-- Resolve paths from this script's own location rather than the cwd, so the
-- suite runs the same whether launched from the repo root or elsewhere.
local here = debug.getinfo(1, "S").source:sub(2) -- strip leading "@"
local tests_dir = vim.fn.fnamemodify(here, ":p:h")

local H = dofile(tests_dir .. "/helpers.lua")
-- ROOT is the repo (parent of tests/); specs join paths against it.
H.ROOT = vim.fn.fnamemodify(tests_dir, ":h")

local specs = {
    "ftdetect_spec.lua",
    "asm_lsp_spec.lua",
    "asm_symbols_spec.lua",
}

for _, spec in ipairs(specs) do
    dofile(tests_dir .. "/" .. spec)(H)
end

local ok = H.report()
vim.cmd(ok and "cq 0" or "cq 1")
