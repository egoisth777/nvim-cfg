return {
    "linux-cultist/venv-selector.nvim",
    branch = "regexp",
    event = "VeryLazy",
    opts = {
        options = {
            picker = "fzf-lua",
            debug = true,
            notify_user_on_venv_activation = true,
            enable_default_searches = false, -- Disable default searches to use custom paths
        },
        search = {
            anaconda_envs = {
                command = "fd python.exe$ E:/dev/envs/anaconda3/envs --no-ignore-vcs --full-path -a -E Lib",
                type = "anaconda",
            },
            anaconda_base = {
                command = "fd python.exe$ E:/dev/envs/anaconda3 --no-ignore-vcs --full-path -a --color never -d 1",
                type = "anaconda",
            },
            workspace = {
                command = "fd Scripts/python.exe$ $WORKSPACE_PATH --full-path --color never -HI -a -L",
            },
            cwd = {
                command = "fd Scripts/python.exe$ $CWD --full-path --color never -HI -a -L",
            },
        },
    },
    keys = {
        { "<leader>vs", "<cmd>VenvSelect<cr>",       desc = "Select VirtualEnv" },
        { "<leader>vc", "<cmd>VenvSelectCached<cr>", desc = "Select Cached VirtualEnv" },
    },
}
