return {

    -- ensure install the asm-lsp language server
    {
        "mason-org/mason.nvim",
        opts = {
            ensure_installed = {
                "asm-lsp",
            },
        },
    },
    -- Configure asm-lsp server
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                asm_lsp = {
                    cmd = { "asm-lsp" },
                    -- These are the only two filetypes ftdetect.lua produces for
                    -- assembly. The list must cover them exactly, because the
                    -- server attaches by filetype match -- a buffer whose
                    -- filetype is absent here gets no completion or hover.
                    filetypes = { "masm", "nasm" },
                    -- Neovim 0.11's native vim.lsp.config (which LazyVim now
                    -- drives) calls root_dir as (bufnr, on_dir) and ignores the
                    -- return value -- the resolved root must be handed back by
                    -- invoking on_dir. The older `root_dir(fname) -> path` form
                    -- silently no-ops and the server falls back to single-file
                    -- mode, breaking project-wide definition/reference lookups.
                    root_dir = function(bufnr, on_dir)
                        local fname = vim.api.nvim_buf_get_name(bufnr)
                        on_dir(vim.fs.root(fname, ".git") or vim.fn.getcwd())
                    end,
                    -- asm-lsp does NOT read LSP `settings`. Assembler /
                    -- instruction_set / diagnostics live in the global TOML at
                    -- %APPDATA%\asm-lsp\.asm-lsp.toml (or a per-project
                    -- .asm-lsp.toml). Do not re-add a `settings` block here.
                    --
                    -- No on_attach keymaps: LazyVim already binds K/gd/gr/
                    -- <leader>ca with capability guards, and glance.nvim
                    -- (peek_glance.lua) supplies the peek variants. Re-binding
                    -- them here would only shadow the guarded defaults.
                },
            },
        },
    },
}
