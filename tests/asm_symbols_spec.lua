-- Guards the symbol-navigation plugins (gutentags, tagbar, glance). These are
-- structural assertions on the lazy.nvim specs -- the plugins themselves are
-- exercised by hand in Nvim. The point is to catch a spec that stops loading
-- the plugin at all (wrong name, dropped lazy-load trigger) before it ships.

return function(H)
    local ctags = dofile(H.path("lua/plugins/lang/lang_asm/symbols_ctags.lua"))

    -- gutentags drives the native `<C-]>`/`<C-w>}` flow; it is scoped to asm
    -- filetypes so it does not spawn ctags for unrelated projects.
    local gutentags = H.find_spec(ctags, "ludovicchabant/vim-gutentags")
    H.test("symbols: gutentags present", function()
        H.is_true(gutentags ~= nil)
    end)
    if gutentags then
        H.test("symbols: gutentags scoped to asm", function()
            H.contains(gutentags.ft, "masm")
        end)
        -- vim.g settings must run before the plugin loads, hence init (not config).
        H.test("symbols: gutentags configures via init", function()
            H.eq(type(gutentags.init), "function")
        end)
    end

    -- tagbar is the ctags-backed outline (aerial has no ctags backend, and MASM
    -- has no treesitter parser, so this is the only outline that resolves).
    local tagbar = H.find_spec(ctags, "preservim/tagbar")
    H.test("symbols: tagbar present", function()
        H.is_true(tagbar ~= nil)
    end)
    if tagbar then
        H.test("symbols: tagbar lazy-loads on command", function()
            H.eq(tagbar.cmd, "TagbarToggle")
        end)
        -- The tagbar_type_masm/nasm mapping is the part that makes the outline
        -- actually populate; run init and confirm it wires the ctags `asm` parser,
        -- so a dropped/renamed type definition fails the suite instead of silently
        -- producing an empty outline.
        H.test("symbols: tagbar maps masm to ctags asm parser", function()
            tagbar.init()
            H.eq(vim.g.tagbar_type_masm.ctagstype, "asm")
            H.eq(vim.g.tagbar_type_nasm.ctagstype, "asm")
        end)
    end

    -- glance gives the non-destructive peek over asm-lsp results.
    local glance = dofile(H.path("lua/plugins/lang/lang_asm/peek_glance.lua"))
    H.test("symbols: glance spec name", function()
        H.eq(glance[1], "dnlhc/glance.nvim")
    end)
    -- Assert the actual peek bindings exist rather than just a non-empty list, so
    -- replacing them with an unrelated key would be caught.
    H.test("symbols: glance binds gpd peek", function()
        local has_gpd = false
        for _, k in ipairs(glance.keys) do
            if k[1] == "gpd" then
                has_gpd = true
            end
        end
        H.is_true(has_gpd, "expected a gpd peek-definitions mapping")
    end)
end
