return
{
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    picker = {
      sources = {
        explorer = {
          hidden = true,  -- Show dotfiles (e.g., .gitignore, .config)
          ignored = true, -- Optional: Show files ignored by git (e.g., node_modules)
        },
        -- Optional: Apply the same to the file fuzzy finder
        files = {
          hidden = true,
        },
      },
    },
  },
}
