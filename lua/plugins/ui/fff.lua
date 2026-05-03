return {
  {
    "dmtrKovalenko/fff.nvim",
    lazy = true,
    build = function()
      require("fff.download").download_or_build_binary()
    end,
    opts = {},
    keys = {
      {
        "<leader><space>",
        function()
          require("fff").find_files()
        end,
        desc = "Find Files (fff)",
      },
      {
        "<leader>/",
        function()
          require("fff").live_grep()
        end,
        desc = "Live Grep (fff)",
      },
      {
        "<leader>ff",
        function()
          require("fff").find_files()
        end,
        desc = "Find Files (fff)",
      },
      {
        "<leader>fF",
        function()
          local dir = vim.fn.expand("%:p:h")
          require("fff").find_files_in_dir(dir)
        end,
        desc = "Find Files (buffer dir, fff)",
      },
      {
        "<leader>fg",
        function()
          require("fff").live_grep()
        end,
        desc = "Live Grep (fff)",
      },
      {
        "<leader>fG",
        function()
          local dir = vim.fn.expand("%:p:h")
          require("fff").live_grep({ base_path = dir })
        end,
        desc = "Live Grep (buffer dir, fff)",
      },
      {
        "<leader>fc",
        function()
          require("fff").live_grep({ query = vim.fn.expand("<cword>") })
        end,
        desc = "Grep Word Under Cursor (fff)",
      },
    },
  },
}
