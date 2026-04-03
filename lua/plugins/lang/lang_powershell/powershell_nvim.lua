-- PowerShell development support via powershell.nvim
-- This plugin manages the PSES (PowerShell Editor Services) LSP lifecycle
-- directly, bypassing nvim-lspconfig. This is necessary because LazyVim's
-- vim.lsp.config/vim.lsp.enable flow does not handle PSES's non-standard
-- startup (bundle_path → cmd translation via on_new_config).
--
-- Provides: LSP (completions, diagnostics via PSScriptAnalyzer, hover,
--           go-to-definition), integrated terminal, and DAP support.

-- Neutralize nvim-lspconfig's built-in powershell_es server. It uses -Stdio
-- and writes a session file that conflicts with powershell.nvim's NamedPipe
-- flow. Clearing filetypes prevents it from ever attaching, regardless of
-- when mason-lspconfig calls vim.lsp.enable().
vim.lsp.config("powershell_es", { filetypes = {} })

return {
  {
    "TheLeoP/powershell.nvim",
    ft = "ps1",
    ---@type powershell.user_config
    opts = {
      bundle_path = vim.fs.joinpath(
        vim.fn.stdpath("data"),
        "mason",
        "packages",
        "powershell-editor-services"
      ),
    },
    config = function(_, opts)
      require("powershell").setup(opts)
      -- lazy.nvim's ft trigger loads the plugin after FileType fires,
      -- so the autocmd in plugin/autocmds.lua misses the initial buffer.
      local buf = vim.api.nvim_get_current_buf()
      if vim.bo[buf].filetype == "ps1" then
        require("powershell").initialize_or_attach(buf)
      end
    end,
  },

  -- Mason: ensure powershell-editor-services is installed
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = { "powershell-editor-services" },
    },
  },

  -- Prevent mason-lspconfig from auto-enabling powershell_es via nvim-lspconfig.
  {
    "mason-org/mason-lspconfig.nvim",
    opts = {
      automatic_enable = {
        exclude = { "powershell_es" },
      },
    },
  },

  -- Treesitter: syntax highlighting for .ps1/.psm1/.psd1
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "powershell" },
    },
  },
}
