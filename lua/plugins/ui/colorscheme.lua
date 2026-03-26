-- START
-- Currently Contains All Colorscheme set up for nvim
--[[
    1. catppuccin
    2. abyss
    4. kanagawa
    3. cyberdream
    5. nightfox
--]]

-- END- - - - - - - - - - - - - - - - - - - - - -

return
{
    -- Catppuccin configuration
    {
        "catppuccin/nvim",
        name = "catppuccin",
        opts =
        {
            flavour = "mocha",
            transparent_background = true, -- Enables full transparency for backgrounds
        },
    },

    -- abyss colorscheme
    {
        "barrientosvctor/abyss.nvim",
        name = "abyss",
        lazy = true,
        priority = 1000,
        opts = {},
        config = function()
            -- Setup MUST happen before applying colorscheme
            require("abyss").setup({
                italic_comments = true,
                italic = false,
                bold = true,
                transparent_background = true,
                treesitter = true,
                overrides = {},
            })
            -- Apply colorscheme AFTER setup
            vim.cmd.colorscheme("abyss")
        end,
    },
    {
        "scottmckendry/cyberdream.nvim",
        name = "cyberdream",
        lazy = false,
        priority = 2000,
        config = function()
            require("cyberdream").setup({
                variant = "auto",
                transparent = true,
                italic_comments = true,
                borderless_telescope = true, -- This affects fzf-lua too
                borderless_pickers = true,
                terminal_colors = false,
                cache = false,
                -- Add theme customizations for specific syntax elements
                highlights = {

                    -- Global Settings----------------------------------------------------------
                    -- White
                    Identifier = { fg = "#ffffff", bold = true },

                    -- Yellow (Face Value)

                    Number = { fg = "#f1ff5e", italic = true },
                    String = { fg = "#f1ff5e", italic = true },

                    -- Your current subtle green
                    Comment = { fg = "#77aa77", bold = false, italic = true },

                    -- Orange
                    Keyword = { fg = "#ffbd5e", bold = false },

                    -- Magenta
                    Type = { fg = "#ff5ef1", bold = false },

                    -- Neon Green
                    Function = { fg = "#5eff6c", bold = true, italic = true },
                    PreProc = { fg = "#5eff6c", bold = true, italic = true },
                    Operator = { fg = "#5eff6c" },

                    -- Neon Pink
                    Special = { fg = "#ff5ea0", italic = true },

                    -- Blue
                    Delimiter = { fg = "#5ea1ff", bold = true },


                    -- END OF GLOBAL SETTINGS ---------------------------------------------------

                    -- LSP and Language Settings

                    -- General Language Settings
                    ["@variable"] = { fg = "#ffffff", bold = true },
                    ["@keyword.type"] = { link = "Keyword" },
                    ["@constructor"] = { link = "Function" },
                    ["@type.builtin"] = { link = "Type" },
                    ["@module"] = { fg = "#5ef1ff" },

                    -- cpp settings
                    ["@keyword.conditional.ternary.cpp"] = { link = "Operator" },
                    ["@lsp.mod.constructorOrDestructor.cpp"] = { link = "Function" },
                    ["@lsp.typemod.class.constructorOrDestructor.cpp"] = { link = "Function" },


                    -- Cursor related ----------------------------------------------------------
                    

                    CursorLine           = { bg = "#354456", bold = true },
                    Visual               = { bg = "#507789", italic = true, bold = true, undercurl = true },

                    -- Word under cursor (via LSP/illuminate)
                    LspReferenceText     = { bg = "#507789" },
                    LspReferenceRead     = { bg = "#507789" },
                    LspReferenceWrite    = { bg = "#507789" },

                    IlluminatedWordText  = { bg = "#507789" },
                    IlluminatedWordRead  = { bg = "#507789" },
                    IlluminatedWordWrite = { bg = "#507789" },

                    -- Settings for snacks.nvim
                    -- Make the main picker window (explorer) transparent
                    SnacksPickerNormal = { bg = "NONE" },
                    SnacksPickerBorder = { bg = "NONE" },
                    SnacksPickerTitle = { bg = "NONE" },
                    
                    -- Optional: specific parts of the layout
                    SnacksPickerList = { bg = "NONE" },
                    SnacksPickerInput = { bg = "NONE" },
                },
            })
        end,
    },
    {
  "ilof2/posterpole.nvim",
  priority=1000,
  config = function ()
    local posterpole = require("posterpole")

    posterpole.setup({
      -- config here
    })
    vim.cmd("colorscheme posterpole")
    
  end
},
    {
        -- Install Kanagawa.nvim
        "rebelot/kanagawa.nvim",
        name = "kanagawa",
        opts = {
            transparent = true,
        },

    },
    {
        "EdenEast/nightfox.nvim",
        opts = {
            transparent = true,
        }

    },
    -- LazyVim core configuration
    {
        "LazyVim/LazyVim",
        opts = {
            colorscheme = "cyberdream",
        },
    },
}
