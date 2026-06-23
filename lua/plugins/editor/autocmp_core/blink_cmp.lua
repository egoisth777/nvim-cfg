return {
  -- Disable blink.cmp for plaintex files
  "saghen/blink.cmp",
  opts = {
    enabled = function()
      return not vim.tbl_contains({ "plaintex" }, vim.bo.filetype)
    end,
    sources = {
      default = { 'lsp', 'snippets', 'buffer', 'path' },
      per_filetype = {
        plaintex = { 'lsp', 'snippets', 'path' },
      },
    },
    snippets = {
      preset = 'luasnip'
    },

    -- Never show completions automatically. The menu only appears on manual
    -- trigger (see <C-space> below). All auto-trigger conditions are disabled.
    completion = {
      trigger = {
        prefetch_on_insert = false,
        show_in_snippet = false,
        show_on_keyword = false,
        show_on_backspace = false,
        show_on_backspace_in_keyword = false,
        show_on_backspace_after_accept = false,
        show_on_backspace_after_insert_enter = false,
        show_on_insert = false,
        show_on_trigger_character = false,
        show_on_accept_on_trigger_character = false,
        show_on_insert_on_trigger_character = false,
      },
    },

    keymap = {
      -- The 'default' preset provides many sane keybindings.
      -- We will build upon it.
      preset = 'default',

      -- Manual trigger: open the completion menu on demand.
      ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },

      -- The recommended mapping for Tab and Shift-Tab.
      ['<Tab>'] = { 'select_next', 'snippet_forward', 'fallback' },
      ['<S-Tab>'] = { 'select_prev', 'snippet_backward', 'fallback' },

      -- Set Enter to accept completion when menu is visible, otherwise insert newline
      ['<CR>'] = { 'accept', 'fallback' },
    },
  }
}
