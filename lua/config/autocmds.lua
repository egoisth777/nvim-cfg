-- #########################################################################################
-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
-- #########################################################################################


-- Auto-Saving for NVIM
require("config.autocmds.autosaving")


-- Auto applying color schemes for some plugins that are not working
require("config.autocmds.auto-snacks-colors") -- Snacks
require("config.autocmds.fzf-lua-colors")     -- fzf

-- Auto-format LaTeX files on save
require("config.autocmds.auto-format-latex")
