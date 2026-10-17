return {
  -- VimTeX for advanced LaTeX support
  {
    "lervag/vimtex",
    ft = { "tex", "plaintex", "bib" },
    lazy = false, -- Load immediately to ensure commands are available
    init = function()
      -- Root cause: vimtex (since 2026-07-22) refuses to load on Neovim < 0.12.4
      -- and this machine runs 0.11.6, so nothing under b:vimtex exists without
      -- this. vimtex documents the override (:h vimtex_version_check).
      -- Remove once Neovim is upgraded to >= 0.12.4.
      vim.g.vimtex_version_check = 0
    end,
    config = function()
      -- VimTeX configuration
      vim.g.vimtex_mappings_disable = { ["n"] = { "K" } } -- disable `K` as it conflicts with LSP hover
      vim.g.vimtex_quickfix_method = vim.fn.executable("pplatex") == 1 and "pplatex" or "latexlog"

      -- PDF viewing is in-terminal (pdf_preview.lua); no external viewer.
      vim.g.vimtex_view_enabled = 0
      vim.g.vimtex_view_automatic = 0

      -- Disable some default mappings
      vim.g.vimtex_mappings_enabled = 0

      -- Disable conceal for math
      vim.g.vimtex_syntax_conceal_disable = 1

      -- Quick fix settings
      vim.g.vimtex_quickfix_mode = 0

      -- Enable folding
      vim.g.vimtex_fold_enabled = 1
      vim.g.vimtex_fold_types = {
        sections = { parse_levels = 1 },
        envs = { whitelist = { "figure", "table", "tikzpicture" } },
      }
    end,

    -- Keybindings for VimTeX commands
    keys = {
      { "<leader>lc", "<cmd>VimtexCompile<cr>",   desc = "Compile LaTeX (continuous)" },
      { "<leader>lC", "<cmd>VimtexCompileSS<cr>", desc = "Compile LaTeX (single shot)" },
      { "<leader>lt", "<cmd>VimtexTocToggle<cr>", desc = "Toggle TOC" },
      { "<leader>lq", "<cmd>VimtexErrors<cr>",    desc = "Show errors" },
      { "<leader>ls", "<cmd>VimtexStop<cr>",      desc = "Stop compilation" },
      { "<leader>lk", "<cmd>VimtexClean<cr>",     desc = "Clean auxiliary files" },
    },
  },

  -- Enhanced treesitter support for LaTeX
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "latex", "bibtex" })

      opts.highlight = opts.highlight or {}
      -- Disable treesitter highlighting for LaTeX (let VimTeX handle it)
      opts.highlight.disable = function(lang, buf)
        -- Disable treesitter for large LaTeX files
        if lang == "latex" then
          local max_filesize = 100 * 1024 -- 100 KB
          local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
          if ok and stats and stats.size > max_filesize then
            return true
          end
          -- Always disable treesitter highlighting for LaTeX (VimTeX handles it better)
          return true
        end
        return false
      end
    end,
  },

  -- LaTeX symbols and unicode
  {
    "joom/latex-unicoder.vim",
    ft = { "tex", "plaintex" },
    config = function()
      vim.g.unicoder_cancel_normal = 1
      vim.g.unicoder_cancel_insert = 1
      vim.g.unicoder_cancel_visual = 1
    end,
    keys = {
      { "<C-l>", "<Plug>Unicoder", mode = "i", desc = "Convert LaTeX to Unicode" },
    },
  },

  -- LaTeX-specific auto-pairs configuration
  {
    "windwp/nvim-autopairs",
    ft = { "tex", "plaintex" },
    opts = {},
    config = function(_, opts)
      local npairs = require("nvim-autopairs")
      npairs.setup(opts)

      -- Add LaTeX-specific pairs after setup
      local Rule = require("nvim-autopairs.rule")
      local cond = require("nvim-autopairs.conds")

      npairs.add_rules({
        -- Dollar sign for math mode
        Rule("$", "$", { "tex", "plaintex" })
            :with_pair(cond.not_inside_quote()),
        -- Display math
        Rule("\\[", "\\]", { "tex", "plaintex" }),
        -- Inline math alternative
        Rule("\\(", "\\)", { "tex", "plaintex" }),
      })
    end,
  },
}
