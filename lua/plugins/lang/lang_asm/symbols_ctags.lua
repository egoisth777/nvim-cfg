-- Symbol indexing for assembly via universal-ctags.
--
-- asm-lsp resolves go-to-definition/references only for symbols it parses, and
-- there is no treesitter grammar for MASM, so neither LSP nor treesitter can
-- supply a project-wide symbol index. ctags is language-agnostic and ships an
-- Asm parser (labels, PROCs, macros, EQU/= defines, STRUCs), which is the one
-- backend that actually sees MASM symbols. gutentags keeps the tags file fresh
-- so Nvim's native `<C-]>` jump and `<C-w>}` preview window work without a
-- plugin; tagbar renders the same ctags output as an outline.

return {
    {
        "ludovicchabant/vim-gutentags",
        -- masm and nasm are the only filetypes ftdetect.lua emits for assembly;
        -- scoping the load to them avoids spawning ctags in unrelated projects.
        ft = { "masm", "nasm" },
        init = function()
            -- A repo is the unit we want indexed; .git marks that boundary.
            vim.g.gutentags_project_root = { ".git" }
            -- Keep generated tag files out of the working tree so they never get
            -- committed or clutter `git status`.
            vim.g.gutentags_cache_dir = vim.fn.stdpath("cache") .. "/tags"
        end,
    },
    {
        "preservim/tagbar",
        -- aerial.nvim is the usual LazyVim outline, but its backends are
        -- treesitter/lsp/markdown only -- none of which see MASM. tagbar reads the
        -- ctags file directly, so it is the one outline that resolves asm symbols.
        cmd = "TagbarToggle",
        keys = {
            -- lazy.nvim `keys` register globally, so this must dodge every LazyVim
            -- default, not just the asm ones: <leader>cs is Trouble symbols and
            -- <leader>co is Organize Imports (guarded, but the global keymap would
            -- still shadow it in TS/Java buffers). <leader>tb ("tagbar") is unused.
            { "<leader>tb", "<cmd>TagbarToggle<cr>", desc = "Symbol outline (tagbar)" },
        },
        init = function()
            -- tagbar maps a Vim filetype to a ctags language by name, and it has no
            -- built-in entry for the `masm`/`nasm` filetypes we invented in ftdetect.
            -- Without these, tagbar can't tell ctags how to parse the buffer and the
            -- outline comes up empty. ctags parses both flavours with its single
            -- `asm` parser, whose enabled kinds are defines/labels/macros/types.
            local asm_type = {
                ctagstype = "asm",
                kinds = {
                    "d:defines",
                    "l:labels",
                    "m:macros",
                    "t:types",
                },
            }
            vim.g.tagbar_type_masm = asm_type
            vim.g.tagbar_type_nasm = asm_type
        end,
    },
}
