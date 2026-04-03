# Plugin Inventory

Single source of truth for every plugin and configuration file in this Neovim setup.

---

## Table of Contents

- [Framework](#framework)
- [AI](#ai)
- [Editor — Completion](#editor--completion)
- [Editor — Operations](#editor--operations)
- [Editor — Facilitations](#editor--facilitations)
- [UI — Themes](#ui--themes)
- [UI — Components](#ui--components)
- [Language — C/C++](#language--cc)
- [Language — Assembly](#language--assembly)
- [Language — LaTeX](#language--latex)
- [Language — Markdown](#language--markdown)
- [Language — GLSL](#language--glsl)
- [Language — PowerShell](#language--powershell)
- [LazyVim Extras](#lazyvim-extras)
- [Configuration Files](#configuration-files)
- [Custom Snippets](#custom-snippets)

---

## Framework

| Plugin | Purpose |
|--------|---------|
| `folke/lazy.nvim` | Plugin manager. Bootstrapped in `config/lazy.lua`. |
| `LazyVim/LazyVim` | Distro preset. Provides default plugin specs, keymaps, and LSP integration. Active colorscheme set here (`cyberdream`). |

---

## AI

**Directory**: `lua/plugins/ai/`

| File | Plugin | Purpose |
|------|--------|---------|
| `claude_code.lua` | `greggh/claude-code.nvim` | Claude Code AI integration. Eager-loaded (`lazy = false`). |

---

## Editor — Completion

**Directory**: `lua/plugins/editor/autocmp_core/`

| File | Plugin | Purpose |
|------|--------|---------|
| `blink_cmp.lua` | `saghen/blink.cmp` | Primary completion engine. Sources: `lsp`, `snippets`, `buffer`, `path`. LuaSnip snippet backend. Disabled for `plaintex` filetype. Tab/S-Tab to navigate, Enter to accept. |

---

## Editor — Operations

**Directory**: `lua/plugins/editor/operations/`

| File | Plugin | Purpose |
|------|--------|---------|
| `flash.lua` | `folke/flash.nvim` | Jump-to-character motion. VSCode-compatible. |
| `surround.lua` | `kylechui/nvim-surround` | Add/change/delete surrounding delimiters. |
| `multicursors.lua` | `jake-stewart/multicursor.nvim` | Multi-cursor editing. `<leader>k/j` add cursors above/below, `<leader>n/N` match word, `<c-leftmouse>` click-add, `<c-q>` toggle. |
| `advancedfolding.lua` | `kevinhwang91/nvim-ufo` | Advanced code folding. Provider chain: LSP → treesitter → indent. Custom fold text showing line count. Per-filetype overrides for Python and Lua. |

---

## Editor — Facilitations

**Directory**: `lua/plugins/editor/facilitations/`

| File | Plugin | Purpose |
|------|--------|---------|
| `beacon.lua` | `danilamihailov/beacon.nvim` | Visual flash on cursor jumps. |
| `screenkey.lua` | `NStefan002/screenkey.nvim` | On-screen keystroke display (bottom-right). Disabled in terminal buffers. |

---

## UI — Themes

**Directory**: `lua/plugins/ui/colorscheme.lua`

All themes installed in a single file. Only one is active at a time.

| Plugin | Name | Status |
|--------|------|--------|
| `scottmckendry/cyberdream.nvim` | cyberdream | **Active**. Transparent bg, auto variant, italic comments. Custom highlight overrides for Snacks picker transparency. |
| `catppuccin/nvim` | catppuccin | Installed. Mocha flavor, transparent bg. |
| `barrientosvctor/abyss.nvim` | abyss | Installed. Dark theme, transparent bg. |
| `rebelot/kanagawa.nvim` | kanagawa | Installed. Transparent bg. |
| `EdenEast/nightfox.nvim` | nightfox | Installed. Transparent bg. |
| `ilof2/posterpole.nvim` | posterpole | Installed. |

To switch active theme: change `colorscheme = "cyberdream"` in the `LazyVim` opts block at the bottom of `colorscheme.lua`.

---

## UI — Components

**Directory**: `lua/plugins/ui/`

| File | Plugin | Purpose |
|------|--------|---------|
| `snacks.lua` | `folke/snacks.nvim` | UI toolkit (notifications, picker, dashboard, explorer). Explorer shows hidden/ignored files. |
| `neo-tree.lua` | `nvim-neo-tree/neo-tree.nvim` | File explorer sidebar. Shows dotfiles and gitignored files. |
| `trouble.lua` | `folke/trouble.nvim` | Diagnostics list (bottom panel, height 10). |
| `floaterm.lua` | `nvzone/floaterm` | Floating terminal window. |

---

## Language — C/C++

**Directory**: `lua/plugins/lang/lang_cpp/`

### C++ (`lang_cpp/cpp/`)

| File | Plugin / Tool | Purpose |
|------|--------------|---------|
| `treesitter-cpp.lua` | `nvim-treesitter` | Syntax highlighting for C/C++. |
| `cpp_autoformatting.lua` | `stevearc/conform.nvim` | Formatting via `clang-format`. Style config: `lang_cpp/cpp/.clang-format`. |
| `.clang-format` | — | clang-format style definition (co-located with the plugin spec). |

### CMake (`lang_cpp/cmake/`)

| File | Plugin / Tool | Purpose |
|------|--------------|---------|
| `cmaketools.lua` | `Civitasv/cmake-tools.nvim` | CMake build integration. Ninja generator, clang compiler kit. Build dir: `nvim-cmake-build\x64\${variant:buildType}`. |
| `cmake_lspconfig.lua` | `neovim/nvim-lspconfig` | `neocmake` LSP server. |
| `cmake_synx_hl.lua` | `nvim-treesitter`, `mason.nvim` | CMake syntax highlighting + Mason install of `cmakelang`, `cmakelint`. |
| `cmake_nvim_lint.lua` | `mfussenegger/nvim-lint` | CMake linting via `cmakelint`. |
| `cmake_no_ls.lua` | `nvimtools/none-ls.nvim` | `cmake_lint` diagnostics via null-ls. |
| `Cmake-Kits-Global/` | — | Compiler kit definitions (`ninja-clang.json`, `ninja-msvc.json`). |

---

## Language — Assembly

**Directory**: `lua/plugins/lang/lang_asm/`

| File | Plugin / Tool | Purpose |
|------|--------------|---------|
| `syntax_highlighting.lua` | `nvim-treesitter` | Treesitter grammar for `asm`, `nasm`. |
| `lspconfig_asm.lua` | `neovim/nvim-lspconfig`, `mason.nvim` | `asm-lsp` server. MASM assembler, x86/x86-64 instruction set. Hover docs enabled. |

Filetype detection: `.asm`, `.s`, `.S`, `.masm`, `.inc` → `nasm` (in `config/options/ftdetect.lua`).

---

## Language — LaTeX

**Directory**: `lua/plugins/lang/lang_latex/`

Full-stack LaTeX toolchain with LSP, formatting, linting, snippets, and PDF preview.

| File | Plugin / Tool | Purpose |
|------|--------------|---------|
| `lspconfig.lua` | `neovim/nvim-lspconfig`, `mason.nvim` | `texlab` LSP. Build: latexmk → PDF. Formatter: latexindent. chktex diagnostics on open/save/edit. Keys: `<leader>lb` build, `<leader>lf` forward search. |
| `latex_features.lua` | `lervag/vimtex` | VimTeX integration. Folds enabled. Keys: `<leader>lc` compile, `<leader>lv` view PDF, `<leader>lt` TOC. Also configures treesitter (latex, bibtex), `latex-unicoder.vim` (`<C-l>` in insert), and nvim-autopairs rules for `$...$`, `\[...\]`, `\(...\)`. |
| `latex_formatting.lua` | `stevearc/conform.nvim`, `mfussenegger/nvim-lint` | Formatting via latexindent (config: `.latexindent.yaml`). Linting via chktex. |
| `luasnip.lua` | `L3MON4D3/LuaSnip` | Custom LaTeX snippets loaded from `Snippets/tex/`. Keys: `<C-k>` expand, `<C-j>` backward, `<C-l>` choice. |
| `pdf_preview.lua` | `xuhdev/vim-latex-live-preview`, `frabjous/knap` | Dual PDF preview options. Viewer: SumatraPDF (Windows) / zathura (Linux). Keys: `<leader>lp` live preview, `<F5>`–`<F8>` knap controls. |
| `.latexindent.yaml` | — | latexindent formatter config (co-located). |

---

## Language — Markdown

**Directory**: `lua/plugins/lang/lang_md/`

| File | Plugin / Tool | Purpose |
|------|--------------|---------|
| `obsidian_nvim.lua` | `obsidian-nvim/obsidian.nvim` | Obsidian vault integration. Workspaces from `$OBS_KNOWLEDGE_BASE` and `$OBS_META_BASE` env vars. UI disabled. |
| `linting.lua` | `mfussenegger/nvim-lint` | Disables markdown linting (empty linter list). |

---

## Language — GLSL

**Directory**: `lua/plugins/lang/lang_glsl/`

| File | Plugin / Tool | Purpose |
|------|--------------|---------|
| `glsl-lsp.lua` | `neovim/nvim-lspconfig`, `mason.nvim`, `nvim-treesitter` | `glsl_analyzer` LSP + treesitter grammar. Filetypes: `.glsl`, `.vert`, `.tesc`, `.tese`, `.frag`, `.geom`, `.comp`. Filetype detection configured inline. |

---

## Language — PowerShell

**Directory**: `lua/plugins/lang/lang_powershell/`

| File | Plugin / Tool | Purpose |
|------|--------------|---------|
| `powershell_nvim.lua` | `TheLeoP/powershell.nvim`, `mason.nvim`, `nvim-treesitter` | PowerShell LSP via PSES (PowerShell Editor Services). This plugin manages the LSP lifecycle directly — do **not** add a separate `powershell_es` entry in `nvim-lspconfig`, as that causes conflicts. Mason auto-installs PSES. Treesitter provides syntax highlighting for `.ps1`/`.psm1`/`.psd1`. |

---

## LazyVim Extras

Enabled in `lazyvim.json`. These are pre-configured plugin bundles from the LazyVim distro:

| Extra | What it adds |
|-------|-------------|
| `coding.yanky` | Yank history with `yanky.nvim` |
| `dap.core` | Debug Adapter Protocol base (nvim-dap + UI) |
| `dap.nlua` | Lua debugging with one-small-step-for-vimkind |
| `editor.dial` | Increment/decrement with `dial.nvim` |
| `editor.fzf` | Fuzzy finder via `fzf-lua` |
| `editor.inc-rename` | Incremental LSP rename |
| `editor.snacks_explorer` | Snacks file explorer |
| `editor.snacks_picker` | Snacks picker (replaces telescope) |
| `formatting.black` | Python formatting via black |
| `formatting.prettier` | JS/TS/HTML/CSS formatting via prettier |
| `lang.typescript.biome` | TypeScript linting/formatting via biome |
| `lang.clangd` | C/C++ via clangd (supplements custom lang_cpp config) |
| `lang.git` | Git integration (gitsigns, etc.) |
| `lang.json` | JSON LSP + SchemaStore |
| `lang.markdown` | Markdown preview + render-markdown.nvim |
| `lang.toml` | TOML LSP |
| `lang.yaml` | YAML LSP |
| `util.mini-hipatterns` | Highlight patterns (color codes, TODOs) |
| `vscode` | VSCode integration layer |

---

## Configuration Files

**Directory**: `lua/config/`

### Options (`config/options/`)

| File | Purpose |
|------|---------|
| `editorsettings.lua` | Tab size (4 spaces), shell (`pwsh.exe` with UTF-8 flags), word wrap, cursor line, auto-save/read. |
| `statuscolumn.lua` | Custom status column with absolute/relative line numbers and color-coded separators. |
| `ftdetect.lua` | Filetype detection rules: assembly (`.asm`→`nasm`), C++ (`.tpp`/`.tpl`→`cpp`). |
| `cursor.lua` | Custom cursor shapes and colors per mode (block/beam, blinking). |

### Autocommands (`config/autocmds/`)

| File | Purpose |
|------|---------|
| `autosaving.lua` | Auto-save on `BufLeave`/`FocusLost` (skips LaTeX aux files). 30s updatetime. |
| `auto-snacks-colors.lua` | CyberDream-specific color fixes for Snacks notifications, dashboard, backdrops. |
| `fzf-lua-colors.lua` | CyberDream-specific highlight links for fzf-lua. Reapplied on `ColorScheme` event. |
| `auto-format-latex.lua` | Auto-format `.tex` and `.bib` on save via conform.nvim (10s timeout). |

---

## Custom Snippets

**Directory**: `Snippets/`

Loaded by `Snippets/loader.lua` into LuaSnip. Currently LaTeX-only.

| File | Content |
|------|---------|
| `tex/document_structure.lua` | Document templates (`template`), sections (`sec`, `sub`, `ssub`), environments (`beg`). |
| `tex/math.lua` | Equations (`eq`, `align`), fractions (`frac`), calculus (`sum`, `int`, `lim`), matrices (`mat`). |
| `tex/environments.lua` | Lists (`item`, `enum`), figures (`fig`), tables (`tab`). |
| `tex/formatting.lua` | Text styles (`textbf`, `textit`, `emph`), cross-references (`ref`, `cite`, `label`). |
| `tex/symbols.lua` | Greek letters, math operators, arrows. |
| `tex/theorems.lua` | Theorem environments (`proof`, `theorem`, `lemma`, `definition`). |
