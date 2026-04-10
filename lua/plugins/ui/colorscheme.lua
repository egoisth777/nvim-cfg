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
                borderless_pickers = true, -- 
                terminal_colors = true,
                hide_fillchars = true,
                cache = false,
                -- Add theme customizations for specific syntax elements
                highlights = {
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
