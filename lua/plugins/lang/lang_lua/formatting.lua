return {
    -- stylua via conform.nvim. Picks up stylua.toml at repo root automatically.
    {
        "stevearc/conform.nvim",
        opts = {
            formatters_by_ft = {
                lua = { "stylua" },
            },
        },
    },

    -- Ensure stylua binary installed via Mason
    {
        "mason-org/mason.nvim",
        opts = { ensure_installed = { "stylua" } },
    },
}
