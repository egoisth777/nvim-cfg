return
{
  "Civitasv/cmake-tools.nvim",
  lazy = true,

  -- Initialization
  init = function()
    local loaded = false
    local function check()
      local cwd = vim.uv.cwd()
      if vim.fn.filereadable(cwd .. "/CMakeLists.txt") == 1 then
        require("lazy").load({ plugins = { "cmake-tools.nvim" } })
        loaded = true
      end
    end
    check()
    vim.api.nvim_create_autocmd("DirChanged", {
      callback = function()
        if not loaded then
          check()
        end
      end,
    })
  end,

  opts = {
    -- Configure Build Directory
    cmake_kits_path =
        vim.fn.stdpath("config") .. "/lua/plugins/lang/lang_cpp/cmake/Cmake-Kits-Global/ninja-clang.json",
    cmake_soft_link_compile_commands = true, -- Create symlink to project root
    cmake_generate_options = { "-G", "Ninja", "-A", "x64" },
    cmake_build_directory = function()
      if vim.fn.has("win32") == 1 then
        return "nvim-cmake-build\\x86\\${variant:buildType}"
      elseif vim.fn.has("win64") == 1 then
        return "nvim-cmake-build\\x64\\${variant:buildType}"
      end
      return "nvim-cmake-build/unix/${variant:buildType}"
    end,
  },
}
