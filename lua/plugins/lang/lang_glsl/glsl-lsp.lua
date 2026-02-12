return {
    -- configure tree-sitter
    {
        "nvim-treesitter/nvim-treesitter",
        opts = {
            ensure_installed = { "glsl" },
        },
    },

    -- Configure LSP for GLSL
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                glsl_analyzer = {
                    filetypes = { "glsl", "vert", "tesc", "tese", "frag", "geom", "comp" },
                },
            },
        },
    },

    -- Mason to ensure install the GLSL Language server
    {
        "mason-org/mason.nvim",
        opts = {
            ensure_installed = { "glsl_analyzer" }
        }
    },

    -- Filetype detection for GLSL files
    {
        "lazy.nvim",
        priority = 10000,
        config = function()
            vim.filetype.add({
                extension = {
                    vert = "glsl",
                    tesc = "glsl",
                    tese = "glsl",
                    frag = "glsl",
                    geom = "glsl",
                    comp = "glsl",
                    glsl = "glsl",
                },
            })
        end,
    },
}
