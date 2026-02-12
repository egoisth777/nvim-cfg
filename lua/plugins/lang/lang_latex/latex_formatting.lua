return {
    -- Conform.nvim for LaTeX formatting
    {
        "stevearc/conform.nvim",
        opts = function(_, opts)
            -- Ensure formatters_by_ft exists
            opts.formatters_by_ft = opts.formatters_by_ft or {}

            -- Add LaTeX formatters
            opts.formatters_by_ft.tex = { "latexindent" }
            opts.formatters_by_ft.plaintex = { "latexindent" }
            -- Note: bibtex-tidy may not be available in Mason, install via npm if needed

            -- Configure latexindent formatter
            opts.formatters = opts.formatters or {}

            -- Path to the .latexindent.yaml config file
            local config_path = vim.fs.joinpath(
                vim.fn.stdpath("config"),
                "lua", "plugins", "lang", "lang_latex", ".latexindent.yaml"
            )

            opts.formatters.latexindent = {
                prepend_args = {
                    "-g", "NUL",          -- Don't create log files (Windows: NUL instead of /dev/null)
                    "-m",                 -- Modify line breaks
                    "-l=" .. config_path, -- Use our config file
                },
                timeout_ms = 10000,       -- Increase timeout to 10 seconds
            }
            return opts
        end,
    },

    -- Mason to ensure formatters are installed
    {
        "mason-org/mason.nvim",
        opts = function(_, opts)
            opts.ensure_installed = opts.ensure_installed or {}
            vim.list_extend(opts.ensure_installed, {
                "latexindent",
            })
        end,
    },

    -- nvim-lint for LaTeX linting with chktex
    {
        "mfussenegger/nvim-lint",
        optional = true,
        opts = function(_, opts)
            opts.linters_by_ft = opts.linters_by_ft or {}
            opts.linters_by_ft.tex = { "chktex" }
            opts.linters_by_ft.plaintex = { "chktex" }

            -- Configure chktex linter for better Windows compatibility
            opts.linters = opts.linters or {}
            opts.linters.chktex = {
                cmd = "chktex",
                stdin = true,
                args = { "-q", "-v0" }, -- Quiet mode, minimal verbosity
                stream = "stdout",
                ignore_exitcode = true,
            }

            return opts
        end,
    },
}
