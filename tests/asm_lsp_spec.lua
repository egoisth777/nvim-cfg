-- Guards the asm-lsp client spec. The two bugs this config was created to fix
-- were (1) the server's filetypes not matching what ftdetect produces, so it
-- never attached, and (2) a `settings` block that asm-lsp silently ignores
-- (it reads .asm-lsp.toml, not LSP settings). Both are easy to reintroduce, so
-- they get explicit assertions.

return function(H)
    local specs = dofile(H.path("lua/plugins/lang/lang_asm/lspconfig_asm.lua"))

    local lsp = H.find_spec(specs, "neovim/nvim-lspconfig")
    H.test("asm_lsp: lspconfig spec present", function()
        H.is_true(lsp ~= nil)
    end)

    local asm = lsp and lsp.opts and lsp.opts.servers and lsp.opts.servers.asm_lsp
    H.test("asm_lsp: server entry present", function()
        H.is_true(asm ~= nil)
    end)

    if asm then
        -- The filetypes here MUST be a superset of what ftdetect emits, or the
        -- server never starts. masm and nasm are the two we actually produce.
        H.test("asm_lsp: filetypes include masm", function()
            H.contains(asm.filetypes, "masm")
        end)
        H.test("asm_lsp: filetypes include nasm", function()
            H.contains(asm.filetypes, "nasm")
        end)

        -- Regression guard: asm-lsp ignores LSP `settings`, so its presence means
        -- someone mistakenly believed config lived here instead of the TOML file.
        H.test("asm_lsp: no dead settings block", function()
            H.eq(asm.settings, nil)
        end)

        H.test("asm_lsp: cmd is asm-lsp", function()
            H.eq(asm.cmd[1], "asm-lsp")
        end)

        -- Asserting `type == function` is not enough: the broken old-signature
        -- closure (`root_dir(fname) -> path`) is also a function and would pass
        -- while silently no-op'ing under native vim.lsp.config. Exercise the
        -- contract instead -- a real call must hand a string root to on_dir.
        H.test("asm_lsp: root_dir calls on_dir with a path", function()
            local buf = vim.api.nvim_create_buf(false, true)
            vim.api.nvim_buf_set_name(buf, vim.fn.getcwd() .. "/main.asm")
            local got
            asm.root_dir(buf, function(dir)
                got = dir
            end)
            H.eq(type(got), "string", "on_dir must receive a path string")
        end)
    end

    -- mason must be told to install the server, else cmd resolves to nothing on a
    -- fresh machine.
    local mason = H.find_spec(specs, "mason-org/mason.nvim")
    H.test("asm_lsp: mason spec present", function()
        H.is_true(mason ~= nil)
    end)
    if mason then
        H.test("asm_lsp: mason installs asm-lsp", function()
            H.contains(mason.opts.ensure_installed, "asm-lsp")
        end)
    end
end
