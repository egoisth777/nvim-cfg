# PSES Stdio Session File Conflict

**Date resolved:** 2026-04-02
**Affected components:** nvim-lspconfig, mason-lspconfig, powershell.nvim

## Problem

PowerShell autocomplete not working — no LSP client attaches to `.ps1` buffers.

## Root Cause

Two PSES instances race over the same session file (`{cache}/powershell_es.session.json`):

1. `mason-lspconfig` detects `powershell-editor-services` installed via Mason and calls
   `vim.lsp.enable("powershell_es")`, activating `nvim-lspconfig`'s built-in config.
2. That config (`nvim-lspconfig/lsp/powershell_es.lua`) starts PSES with **both** `-Stdio`
   and `-SessionDetailsPath`, writing a session file containing
   `{"languageServiceTransport":"Stdio"}` with **no `languageServicePipeName`**.
3. `powershell.nvim` starts its own PSES with `-SessionDetailsPath` (NamedPipe mode).
4. `powershell.nvim`'s `wait_for_session_file` finds the Stdio session file first.
5. It calls `vim.lsp.rpc.connect(session_details.languageServicePipeName)` with `nil`,
   causing `host_or_path: expected string, got nil`.

A secondary issue: lazy.nvim's `ft = "ps1"` trigger loads `powershell.nvim` after the
FileType event has already fired, so the plugin's internal FileType autocmd
(`plugin/autocmds.lua`) misses the initial buffer.

## Workarounds Applied

In `lua/plugins/lang/lang_powershell/powershell_nvim.lua`:

1. **Neutralize lspconfig's powershell_es:**
   ```lua
   vim.lsp.config("powershell_es", { filetypes = {} })
   ```
   Setting `filetypes = {}` prevents it from ever matching, regardless of when
   `mason-lspconfig` calls `vim.lsp.enable()`.

2. **Exclude from mason-lspconfig:**
   ```lua
   { "mason-org/mason-lspconfig.nvim", opts = { automatic_enable = { exclude = { "powershell_es" } } } }
   ```
   Belt-and-suspenders — tells mason-lspconfig not to auto-enable it.

3. **Manual initialize_or_attach:**
   ```lua
   config = function(_, opts)
     require("powershell").setup(opts)
     local buf = vim.api.nvim_get_current_buf()
     if vim.bo[buf].filetype == "ps1" then
       require("powershell").initialize_or_attach(buf)
     end
   end,
   ```
   Compensates for the missed FileType event on initial buffer.

## Upstream Fixes (Not Yet Filed)

### nvim-lspconfig (neovim/nvim-lspconfig)

`lsp/powershell_es.lua` passes `-SessionDetailsPath` alongside `-Stdio`. In Stdio mode
the session file is unnecessary and creates a poisonous artifact. The fix: remove
`-SessionDetailsPath '%s/powershell_es.session.json'` from the `-Stdio` command format
string, or don't write a session file at all when using Stdio transport.

### powershell.nvim (TheLeoP/powershell.nvim)

`lsp.lua:get_lsp_config` blindly passes `session_details.languageServicePipeName` to
`vim.lsp.rpc.connect()` without checking for `nil`. The fix: validate the session file's
`languageServiceTransport` field and reject Stdio sessions with an actionable error
message.
