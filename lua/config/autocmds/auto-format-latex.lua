-- Auto-format LaTeX files on save using conform.nvim
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = { "*.tex", "*.bib" },
    callback = function(args)
        -- Use conform.nvim to format if available
        local conform = require("conform")
        if conform then
            conform.format({
                bufnr = args.buf,
                lsp_fallback = true,
                timeout_ms = 10000 -- Increased to 10 seconds for larger LaTeX files
            })
        end
    end,
    desc = "Format LaTeX files on save",
})
