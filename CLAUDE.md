# CLAUDE.md

Agent-facing registry for this Neovim configuration repository.
Human-readable documentation lives in `README.md` and `man/`.

## Repository Purpose

Personal Neovim configuration built on **LazyVim** (distro preset) with **lazy.nvim** (package manager). Contains editor settings, plugin configurations, language toolchains, custom snippets, and UI theming.

## Architecture

### Entry point

`init.lua` → loads `core/keymaps` then bootstraps lazy.nvim via `config/lazy`.

### Directory layout

```
nvim-cfg/
├── init.lua                    # Entry point
├── lazyvim.json                # LazyVim extras registry
├── lazy-lock.json              # Plugin version lockfile (do not hand-edit)
├── stylua.toml                 # Lua formatter config
├── CLAUDE.md                   # This file (agent instructions)
├── README.md                   # Human-readable overview
├── man/                        # User manual (SSOT for documentation)
│   └── plugins.md              # Full plugin inventory
├── Snippets/                   # Custom LuaSnip snippets
│   ├── loader.lua              # Snippet loader (integrates with LuaSnip)
│   └── tex/                    # LaTeX snippet files
├── lua/
│   ├── core/
│   │   └── keymaps.lua         # Global keybindings
│   ├── config/
│   │   ├── lazy.lua            # lazy.nvim bootstrap + plugin spec root
│   │   ├── options.lua         # Imports modular option files
│   │   ├── autocmds.lua        # Imports modular autocommand files
│   │   ├── options/            # Modular editor options
│   │   └── autocmds/           # Modular autocommands
│   ├── plugins/                # All plugin specs (lazy.nvim format)
│   │   ├── ai/                 # AI assistant plugins
│   │   ├── editor/             # Core editing (completion, motions, folding)
│   │   │   ├── autocmp_core/   # Completion engine (blink.cmp)
│   │   │   ├── operations/     # Motions, surround, multicursor, folding
│   │   │   └── facilitations/  # Visual aids (beacon, screenkey)
│   │   ├── ui/                 # Themes, file explorer, diagnostics, terminal
│   │   └── lang/               # Language-specific toolchains
│   │       ├── lang_cpp/       # C/C++ + CMake
│   │       ├── lang_asm/       # Assembly (MASM/NASM)
│   │       ├── lang_latex/     # LaTeX (full stack)
│   │       ├── lang_md/        # Markdown
│   │       ├── lang_glsl/      # GLSL shaders
│   │       └── lang_powershell/# PowerShell
│   └── utility/
│       ├── auto_import.lua     # Glob-based module loader
│       └── latex_preview.lua   # In-terminal PDF viewer (snacks.image + synctex)
```

### Plugin loading pattern

Plugin directories use one of two patterns for their `init.lua`:

1. **Auto-import** — `require("utility.auto_import").auto_import_modules("plugins.category.subcategory")` globs all `.lua` files (excluding `init.lua`) in the directory and returns `{import = "..."}` specs. Used by: `ai/`, `editor/autocmp_core/`, `editor/operations/`, `editor/facilitations/`, `ui/`, `lang_powershell/`.

2. **Explicit import** — manually lists `{import = "..."}` entries. Used by: `editor/` (top-level), `lang/`, `lang_cpp/`.

### Key design decisions

- **Shell**: `pwsh.exe` is the default shell (set in `config/options/editorsettings.lua`), with UTF-8 redirection flags. All `:!` commands and terminal buffers use PowerShell.
- **Active colorscheme**: `cyberdream` (set in `ui/colorscheme.lua` via LazyVim opts). Five other themes are installed but inactive.
- **Completion**: `blink.cmp` with LuaSnip backend. Sources: `lsp`, `snippets`, `buffer`, `path`.
- **Folding**: `nvim-ufo` with LSP → treesitter → indent fallback chain.
- **PowerShell LSP**: Uses `powershell.nvim` plugin (not raw `nvim-lspconfig`) because PSES requires a non-standard `bundle_path` startup that LazyVim's `vim.lsp.config`/`vim.lsp.enable` flow cannot handle.
- **LaTeX**: Full toolchain — vimtex + texlab LSP + latexindent + chktex + LuaSnip snippets + in-terminal PDF preview.
- **LaTeX PDF preview**: rendered inside Neovim via `snacks.image` (kitty graphics protocol), not an external app; vimtex's viewer is disabled (`vimtex_view_enabled = 0`). Logic lives in `lua/utility/latex_preview.lua`; `lang_latex/pdf_preview.lua` enables `snacks.image` (PDF pages rendered untrimmed so click coordinates map linearly) and binds keys; `config/autocmds/latex_preview.lua` wires events (a second `init` on the vimtex spec would clobber vimtex's own — lazy.nvim keeps only one). Sync: file watcher on the compiled PDF (any compiler); tex→pdf via `synctex view` on demand and in follow mode (debounced `CursorMoved`, never `CursorHold` — `updatetime` is 30 s here); pdf→tex via ctrl+click → cell→PDF-point mapping → `synctex edit`. Status lives in a 1-row split under the image, not a winbar: WezTerm has no unicode placeholders, so snacks paints the image from the window's top-left cell. Each refresh copies the PDF to a per-pid, per-generation file in the snacks image cache because snacks caches conversions by source path; close aborts in-flight `magick` and purges. Requires a kitty-graphics terminal (WezTerm/kitty/ghostty), `magick`, `gs`; optional `pdfinfo` (page count/size), `synctex` (forward/inverse/follow).
- **vimtex on Neovim 0.11**: vimtex ≥ 2026-07-22 refuses Neovim < 0.12.4 (`ftplugin/tex.vim` guard) and this machine runs 0.11.6, so `b:vimtex` never existed. `latex_features.lua` sets `vim.g.vimtex_version_check = 0` (vimtex-documented override) in `init`. Remove after upgrading Neovim.

## LazyVim Extras

Enabled in `lazyvim.json` — these add pre-configured language support and editor features on top of the base LazyVim distro:

- **Coding**: yanky
- **DAP**: core, nlua
- **Editor**: dial, fzf, inc-rename, snacks_explorer, snacks_picker
- **Formatting**: black, prettier
- **Lang**: typescript.biome, clangd, git, json, markdown, toml, yaml
- **Util**: mini-hipatterns
- **VSCode**: vscode integration layer

## Rules for Editing This Config

- **Do not hand-edit `lazy-lock.json`** — it is managed by `:Lazy`.
- **Do not add `nvim-lspconfig` server entries for PowerShell** — `powershell.nvim` manages PSES directly. Adding a duplicate `powershell_es` server causes double-start conflicts.
- New language modules go in `lua/plugins/lang/lang_<name>/` with an `init.lua` that uses `auto_import_modules`.
- Plugin specs must follow lazy.nvim format: `{ "author/plugin", opts = {...} }`.
- Colorscheme additions go in `ui/colorscheme.lua`. Set active theme via `LazyVim` opts at the bottom of that file.
- Keep filetype detection rules in `config/options/ftdetect.lua`.
- Custom snippets go in `Snippets/<filetype>/` and must be registered in `Snippets/loader.lua`.

## Documentation

- `README.md` — human-readable overview and quick reference
- `man/plugins.md` — complete plugin inventory with per-file descriptions (SSOT)
- `CLAUDE.md` — this file (agent context)
