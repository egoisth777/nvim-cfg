# LaTeX Formatting and Linting Setup

## Overview
Your Neovim configuration now includes automatic LaTeX formatting and linting that runs every time you save a `.tex` or `.bib` file.

## What Was Added

### 1. **Formatting with `latexindent`** (`latex_formatting.lua`)
   - Automatically formats LaTeX files using `latexindent` on save
   - Formats BibTeX files using `bibtex-tidy` on save
   - Installed via Mason package manager

### 2. **Linting with `chktex`** (enabled in `lspconfig.lua`)
   - Provides real-time LaTeX syntax checking and style warnings
   - Integrated into texlab LSP server
   - Runs on file open, save, and edit

### 3. **Auto-format on Save** (`latex_format_on_save.lua`)
   - Automatically triggers formatting when you save any `.tex` or `.bib` file
   - Uses `conform.nvim` for formatting
   - 3-second timeout to prevent hanging on large files

### 4. **Configuration File** (`.latexindent.yaml`)
   - Customizes how `latexindent` formats your files
   - Uses 4 spaces for indentation (matching your editor settings)
   - Preserves your line breaks (respects soft wrap)
   - Removes trailing whitespace

## Setup Instructions

After restarting Neovim, the following will happen automatically:

1. **Mason will install required tools:**
   - `latexindent` - LaTeX formatter
   - `bibtex-tidy` - BibTeX formatter  
   - `chktex` - LaTeX linter
   - `texlab` - LaTeX LSP server

2. **Formatting will trigger on save:**
   - Open any `.tex` file
   - Make some changes
   - Save (`:w` or `Ctrl+S`)
   - File will be automatically formatted

## Manual Formatting

If you want to format without saving, you can use:
- `:lua require("conform").format()` - Format current buffer
- Or set up a keybinding in your keymaps

## Customization

### Adjust Formatting Rules
Edit `.latexindent.yaml` in your config directory to customize:
- Indentation depth
- Line breaking behavior
- Alignment rules
- And more

### Disable Auto-format for Specific Files
Add this at the top of a `.tex` file:
```tex
% !TEX nolint
```

### Adjust Linting Strictness
Edit `lspconfig.lua` and modify the `chktex` settings:
```lua
chktex = {
  onOpenAndSave = true,  -- Set to false to disable
  onEdit = true,         -- Set to false for less frequent checks
}
```

## Troubleshooting

### Formatters not installing
Run manually in Neovim:
```vim
:Mason
```
Then search for and install: `latexindent`, `bibtex-tidy`, `chktex`

### Formatting not working
1. Check if conform is loaded: `:Lazy`
2. Check for errors: `:checkhealth conform`
3. Manually format: `:ConformInfo`

### Linting not showing
1. Check LSP status: `:LspInfo`
2. Ensure texlab is running
3. Check if chktex is installed: `:Mason`

## Files Modified/Created

1. **Created:** `lua/plugins/lang/lang_latex/latex_formatting.lua`
2. **Created:** `lua/config/autocmds/latex_format_on_save.lua`
3. **Created:** `.latexindent.yaml`
4. **Modified:** `lua/config/autocmds.lua` - Added latex format on save
5. **Modified:** `lua/plugins/lang/lang_latex/lspconfig.lua` - Enabled chktex

## Testing

1. Restart Neovim
2. Open a `.tex` file
3. Add some poorly formatted LaTeX code:
   ```tex
   \begin{document}
   \section{Test}
   This is a test.
           This line has weird spacing.
   \end{document}
   ```
4. Save the file - it should be automatically formatted
5. You should also see linting warnings/errors in the diagnostics

Enjoy your automated LaTeX workflow! 🎉
