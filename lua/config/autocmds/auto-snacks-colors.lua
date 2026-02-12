-- Function to apply snacks highlights
local function apply_snacks_highlights()
    vim.api.nvim_set_hl(0, "SnacksNormal", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "SnacksNormalNC", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "SnacksWinBar", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "SnacksBackdrop", { bg = "#000000", blend = 60 })
    vim.api.nvim_set_hl(0, "SnacksNotifierInfo", { fg = "#5ea1ff" })
    vim.api.nvim_set_hl(0, "SnacksNotifierWarn", { fg = "#ffbd5e" })
    vim.api.nvim_set_hl(0, "SnacksNotifierError", { fg = "#ff5ea0" })
    vim.api.nvim_set_hl(0, "SnacksNotifierDebug", { fg = "#77aa77" })
    vim.api.nvim_set_hl(0, "SnacksDashboardHeader", { fg = "#5eff6c", bold = true })
    vim.api.nvim_set_hl(0, "SnacksDashboardFooter", { fg = "#77aa77", italic = true })
    vim.api.nvim_set_hl(0, "SnacksDashboardIcon", { fg = "#ff5ef1" })
    vim.api.nvim_set_hl(0, "SnacksDashboardKey", { fg = "#ffbd5e", bold = true })
    vim.api.nvim_set_hl(0, "SnacksDashboardDesc", { fg = "#ffffff" })
end

-- Apply on ColorScheme change
vim.api.nvim_create_autocmd("ColorScheme", {
    pattern = "cyberdream",
    callback = apply_snacks_highlights,
})

-- Apply immediately after snacks loads
vim.api.nvim_create_autocmd("User", {
    pattern = "LazyLoad",
    callback = function(event)
        if event.data == "snacks.nvim" then
            -- Delay slightly to ensure snacks is fully initialized
            vim.defer_fn(apply_snacks_highlights, 50)
        end
    end,
})

-- Apply on VimEnter as fallback
vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        vim.defer_fn(apply_snacks_highlights, 100)
    end,
})
