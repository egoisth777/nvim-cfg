return {
  "greggh/claude-code.nvim",
    lazy = false,
  dependencies = {
    "nvim-lua/plenary.nvim", -- Required for git operations
  },
  config = function()
    require("claude-code").setup()
  end
}
