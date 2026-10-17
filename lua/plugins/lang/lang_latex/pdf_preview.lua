-- In-terminal PDF preview for LaTeX.
-- Logic: lua/utility/latex_preview.lua. This file only enables snacks.image
-- and binds keys. Follow-mode / ctrl+click autocmds: config/autocmds/latex_preview.lua
-- (a plugin `init` here would clobber vimtex's own `init`; lazy.nvim keeps one).
--
-- Requires a terminal with the kitty graphics protocol (WezTerm, kitty,
-- ghostty), plus `magick` and `gs`. Optional: `pdfinfo`, `synctex`.
local function preview()
  return require("utility.latex_preview")
end

return {
  {
    "folke/snacks.nvim",
    opts = {
      image = {
        enabled = true,
        convert = {
          magick = {
            -- snacks' default adds `-trim`, which crops page margins and would
            -- break the click -> PDF-point mapping used by inverse search.
            pdf = { "-density", 192, "{src}[{page}]", "-background", "white", "-alpha", "remove" },
          },
        },
      },
    },
  },

  -- Keys hang off vimtex so they exist exactly when LaTeX does (keys merge across fragments).
  {
    "lervag/vimtex",
    keys = {
      { "<leader>lv", function() preview().forward() end,       desc = "View PDF (in terminal, at cursor)" },
      { "<leader>lp", function() preview().toggle() end,        desc = "Toggle PDF preview (in terminal)" },
      { "<leader>lf", function() preview().forward() end,       desc = "Forward search (preview page)" },
      { "<leader>lF", function() preview().toggle_follow() end, desc = "Toggle preview follow mode" },
      { "<leader>lr", function() preview().refresh(true) end,   desc = "Refresh PDF preview" },
    },
  },
}
