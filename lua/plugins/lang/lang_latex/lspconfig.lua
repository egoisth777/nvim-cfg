return {
  -- Mason for installing texlab
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "texlab" })
    end,
  },

  -- LSP configuration for LaTeX
  {
    "neovim/nvim-lspconfig",
    ft = { "tex", "plaintex", "bib" },
    opts = {
      servers = {
        texlab = {
          settings = {
            texlab = {
              auxDirectory = ".",
              bibtexFormatter = "texlab",
              build = {
                executable = "latexmk",
                args = { "-pdf", "-interaction=nonstopmode", "-synctex=1", "%f" },
                onSave = false,
                forwardSearchAfter = false,
              },
              chktex = {
                onOpenAndSave = true,
                onEdit = true,
              },
              diagnosticsDelay = 300,
              formatterLineLength = 80,
              forwardSearch = {
                executable = nil,
                args = {},
              },
              latexFormatter = "latexindent",
              latexindent = {
                modifyLineBreaks = false,
              },
            },
          },
          -- Keys should be at the server level, not inside settings
          keys = {
            { "<Leader>K",  "<plug>(vimtex-doc-package)", desc = "Vimtex Docs",   silent = true },
            { "<leader>lb", "<cmd>TexlabBuild<CR>",       desc = "Build LaTeX" },
            { "<leader>lf", "<cmd>TexlabForward<CR>",     desc = "Forward search" },
          },
        },
      },
    },
  },
}
