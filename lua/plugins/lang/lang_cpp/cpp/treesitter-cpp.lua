-- Setting up the highlighting for nvim-treesitter/nvim-treesitter

return
{
  "nvim-treesitter/nvim-treesitter", 
  opts = 
  {
    ensure_installed = {"cpp", "c"},
    highlight = {
      enable = true,
      -- Additional vim regex highlighting for compatibility
      additional_vim_regex_highlighting = false,
    },
    indent = {
      enable = true,
    },
  },
}
