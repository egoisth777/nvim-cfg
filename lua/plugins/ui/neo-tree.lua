return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    filesystem = {
      filtered_items = {
        visible = true, -- when true, they will be shown even if they are in the "hide" list
        hide_dotfiles = false,
        hide_gitignored = false,
        hide_by_name = {
          -- ".git",
          -- ".DS_Store",
          -- "thumbs.db",
        },
        never_show = {
          -- ".DS_Store",
          -- "thumbs.db",
        },
      },
    },
  },
}
