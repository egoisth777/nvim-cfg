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
│   │       ├── lang_md/        # Markdown + Obsidian
│   │       ├── lang_glsl/      # GLSL shaders
│   │       └── lang_powershell/# PowerShell
│   └── utility/
│       └── auto_import.lua     # Glob-based module loader
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
- **LaTeX**: Full toolchain — vimtex + texlab LSP + latexindent + chktex + LuaSnip snippets + PDF preview (SumatraPDF on Windows).

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
