-- [[
-- latex-live-preview
-- Knap
-- ]]
return {
  -- PDF preview for LaTeX
  {
    "xuhdev/vim-latex-live-preview",
    -- what file types will trigger the plugin
    ft = { "tex", "plaintex", "bibtex"},
    config = function()
      -- Set the PDF viewer (change this based on your OS)
      if vim.fn.has("win32") == 1 then
        vim.g.livepreview_previewer = "SumatraPDF"
      elseif vim.fn.has("mac") == 1 then
        vim.g.livepreview_previewer = "open -a Preview"
      else
        vim.g.livepreview_previewer = "zathura"
      end
      
      -- Optional: Set custom compilation command
      vim.g.livepreview_engine = "pdflatex"
      
      -- Optional: Update time in milliseconds
      vim.g.livepreview_cursorhold_recompile = 0
    end,
    keys = {
      { "<leader>lp", "<cmd>LLPStartPreview<cr>", desc = "Start LaTeX preview" },
    },
  },
  
  -- Alternative: knap for more features
  {
    "frabjous/knap",
    ft = { "tex", "plaintex" },
    config = function()
      local knap = require("knap")
      
      -- Configure for Windows
      if vim.fn.has("win32") == 1 then
        vim.g.knap_settings = {
          texoutputext = "pdf",
          textopdf = "pdflatex -interaction=nonstopmode -synctex=1 %docroot%",
          textopdfviewerlaunch = "SumatraPDF %outputfile%",
          textopdfviewerrefresh = "none",
          textopdfforwardjump = "SumatraPDF -reuse-instance %outputfile% -forward-search %srcfile% %line%"
        }
      else
        -- Default settings for Linux/Mac
        vim.g.knap_settings = {
          texoutputext = "pdf",
          textopdf = "pdflatex -interaction=nonstopmode -synctex=1 %docroot%",
          textopdfviewerlaunch = "zathura --synctex-editor-command 'nvim --headless -es --cmd \"lua require('\"'\"'knap'\"'\"').jump_from_viewer('%{input}', %{line})\"' %outputfile%",
          textopdfviewerrefresh = "none",
        }
      end
    end,
    keys = {
      { "<F5>", function() require("knap").process_once() end, desc = "Compile LaTeX" },
      { "<F6>", function() require("knap").close_viewer() end, desc = "Close PDF viewer" },
      { "<F7>", function() require("knap").toggle_autopreviewing() end, desc = "Toggle auto preview" },
      { "<F8>", function() require("knap").forward_jump() end, desc = "Forward jump to PDF" },
    },
  },
}
