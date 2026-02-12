--[[
    WHY: Need to Know what exactly key that I pressed
    CAN:Show keystroke on a small window at the Right-Lower
        Bottom of the Screen
    DEP: Nein
    REQ: Nvim -v > 1.0
--]]

return
{
    "NStefan002/screenkey.nvim",
    lazy = false,
    version = "*", -- or branch = "main", to use the latest commit
    config = function()
        require("screenkey").setup({
            disable = {
                buftypes = {
                    "terminal",
                },
            },
        })
    end
}
