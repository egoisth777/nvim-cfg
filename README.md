# Neovim Configuration

Personal Neovim setup built on [LazyVim](https://www.lazyvim.org/) with [lazy.nvim](https://github.com/folke/lazy.nvim).

## Quick Start

1. Clone this repo to your Neovim config path (`$XDG_CONFIG_HOME/nvim` or `~\AppData\Local\nvim` on Windows).
2. Launch `nvim` — lazy.nvim bootstraps itself and installs all plugins.
3. Run `:Mason` to verify language servers are installed.

## What's Inside

### Core Stack

| Component | Plugin | Notes |
|-----------|--------|-------|
| Package Manager | lazy.nvim | Auto-bootstraps on first launch |
| Distro Preset | LazyVim | Provides sane defaults, extras system |
| Completion | blink.cmp | Sources: LSP, snippets, buffer, path |
| Snippet Engine | LuaSnip | Custom LaTeX snippets in `Snippets/tex/` |
| Fuzzy Finder | fzf-lua | Via LazyVim extra |
| File Explorer | snacks.nvim + neo-tree | Both configured to show hidden files |
| Diagnostics | trouble.nvim | Bottom panel |
| Folding | nvim-ufo | LSP → treesitter → indent fallback |
| Theme | cyberdream | Transparent background, 5 other themes available |

### Language Support

| Language | LSP | Formatter | Linter | Extra |
|----------|-----|-----------|--------|-------|
| C/C++ | clangd (LazyVim extra) | clang-format | — | cmake-tools.nvim, neocmake LSP |
| LaTeX | texlab | latexindent | chktex | vimtex, LuaSnip snippets, in-terminal PDF preview |
| PowerShell | PSES via powershell.nvim | built-in (PSES) | PSScriptAnalyzer (PSES) | Treesitter highlighting |
| Assembly | asm-lsp | — | — | MASM/NASM/GAS, x86/x86-64 |
| GLSL | glsl_analyzer | — | — | Shader filetypes (.vert, .frag, etc.) |
| Markdown | (LazyVim extra) | prettier | — | — |
| TypeScript | biome (LazyVim extra) | prettier, biome | biome | — |
| Python | (LazyVim default) | black | — | — |
| JSON/YAML/TOML | (LazyVim extras) | prettier | — | SchemaStore |

### Editor Features

| Feature | Plugin | Key Bindings |
|---------|--------|-------------|
| Multi-cursor | multicursor.nvim | `<leader>k/j` add above/below, `<leader>n` match word, `<c-q>` toggle |
| Surround | nvim-surround | `ys`, `cs`, `ds` (standard) |
| Flash motions | flash.nvim | `s` to search-jump |
| Yank history | yanky.nvim | Via LazyVim extra |
| Increment/decrement | dial.nvim | `<C-a>`/`<C-x>` enhanced |
| Keystroke display | screenkey.nvim | Bottom-right overlay |
| Cursor beacon | beacon.nvim | Flash on jump |
| AI assistant | claude-code.nvim | Claude Code integration |

### LaTeX Workflow

Full-stack LaTeX editing with dedicated keymaps under `<leader>l`:

| Key | Action |
|-----|--------|
| `<leader>lc` | Compile (continuous) |
| `<leader>lv` | View PDF in terminal (opens at cursor's page) |
| `<leader>lb` | Build (texlab) |
| `<leader>lt` | Toggle TOC |
| `<leader>lp` | Toggle in-terminal PDF preview |
| `<leader>lf` | Forward search (jump preview to cursor's page) |
| `<leader>lF` | Toggle follow mode (preview tracks cursor) |
| `<leader>lr` | Refresh preview |
| `Ctrl+click` | Two-way jump: click in tex → preview page; click on the preview → tex line |
| `<C-k>` | Expand snippet |
| `<C-l>` | LaTeX unicode input |

Custom snippets cover document structure, math notation, environments, formatting, symbols, and theorem blocks. See `Snippets/tex/`.

#### In-terminal PDF preview

`<leader>lv` (or `<leader>lp`) opens the compiled PDF in a split on the right, rendered as an image inside Neovim (no external viewer). It refreshes by itself whenever the PDF on disk changes, so pair it with `<leader>lc` (vimtex continuous build) for save → rebuild → redraw. With follow mode on (default), resting the cursor on a new line moves the preview to that line's page via SyncTeX. `Ctrl+click` works both ways: on a tex line it shows that line's page; on the rendered page it puts the cursor on the matching tex line.

Inside the preview window: `j`/`k` next/prev page, `gg`/`G` first/last page, `r` refresh, `q` close. The row under the page shows `p. N/M` and whether follow mode is on.

Requirements:

- A terminal that speaks the kitty graphics protocol: WezTerm, kitty, or ghostty. Windows Terminal and Warp (Windows) do not; the preview shows a plain-text notice there.
- `magick` (ImageMagick) and `gs` (Ghostscript) to turn PDF pages into images.
- Optional: `pdfinfo` (poppler) for the page count and page size, `synctex` (TeX Live) for forward search, follow mode, and ctrl+click.
- Ctrl+click needs the terminal to pass ctrl-modified mouse events through to Neovim (WezTerm does by default; it only intercepts ctrl+click on hyperlinks).

Check with `:checkhealth snacks`.

## Configuration

### Shell

Default shell is `pwsh.exe` (PowerShell Core) with UTF-8 encoding. Set in `lua/config/options/editorsettings.lua`.

### Changing the Theme

Edit `lua/plugins/ui/colorscheme.lua` — change the `colorscheme` value in the `LazyVim` opts block at the bottom. Available: `cyberdream`, `catppuccin`, `abyss`, `kanagawa`, `nightfox`, `posterpole`.

### Adding a New Language

1. Create `lua/plugins/lang/lang_<name>/`
2. Add `init.lua`:
   ```lua
   return require("utility.auto_import").auto_import_modules("plugins.lang.lang_<name>")
   ```
3. Add plugin spec files (LSP, treesitter, formatting, etc.)
4. Register in `lua/plugins/lang/init.lua`:
   ```lua
   { import = "plugins.lang.lang_<name>" },
   ```

## Documentation

| File | Audience | Content |
|------|----------|---------|
| `README.md` | Humans | This file — overview and quick reference |
| `man/plugins.md` | Humans | Complete plugin inventory with per-file details |
| `CLAUDE.md` | AI agents | Machine-readable registry and editing rules |
