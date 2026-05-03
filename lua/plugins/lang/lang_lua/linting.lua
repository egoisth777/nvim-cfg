return {
    -- selene linter via nvim-lint. Activates only if selene.toml exists at repo root.
    {
        "mfussenegger/nvim-lint",
        opts = {
            linters_by_ft = {
                lua = { "selene" },
            },
        },
    },

    -- Ensure selene binary installed via Mason
    {
        "mason-org/mason.nvim",
        opts = { ensure_installed = { "selene" } },
    },
}
