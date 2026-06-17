-- Floating "peek" UI for the symbols asm-lsp can resolve.
--
-- The plain `gd`/`gr` maps (set in lspconfig_asm.lua) jump the cursor away from
-- the current buffer, which loses your place when you only want to glance at a
-- definition. glance.nvim renders the same LSP results in a preview float, so
-- the `gp*` maps below are the non-destructive counterparts to `gd`/`gr`.

return {
    "dnlhc/glance.nvim",
    -- Loading on the command/keys keeps it out of startup; it is only needed the
    -- moment you ask to peek.
    cmd = "Glance",
    keys = {
        { "gpd", "<cmd>Glance definitions<cr>", desc = "Peek definitions" },
        { "gpr", "<cmd>Glance references<cr>", desc = "Peek references" },
        { "gpt", "<cmd>Glance type_definitions<cr>", desc = "Peek type definitions" },
    },
    opts = {},
}
