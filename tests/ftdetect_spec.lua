-- Filetype routing is the linchpin of the whole asm setup: asm-lsp only attaches
-- when the buffer's filetype is in its `filetypes` list, and the chosen filetype
-- also decides which syntax/parser highlights the file. A wrong mapping here
-- silently kills completion, hover, and highlighting -- exactly the regression
-- this spec guards against.

return function(H)
    -- Loading the config file registers the rules via vim.filetype.add; after this
    -- vim.filetype.match reflects exactly what a real buffer would resolve to.
    dofile(H.path("lua/config/options/ftdetect.lua"))

    local function ft(filename)
        return vim.filetype.match({ filename = filename })
    end

    -- MASM is the active assembler, so the common asm extensions route to `masm`
    -- (which pulls Nvim's builtin masm.vim syntax, the only one that knows MASM
    -- directives like PROC/ENDP).
    H.test("ftdetect: .asm -> masm", function()
        H.eq(ft("main.asm"), "masm")
    end)
    H.test("ftdetect: .s -> masm", function()
        H.eq(ft("main.s"), "masm")
    end)
    H.test("ftdetect: .S -> masm", function()
        H.eq(ft("main.S"), "masm")
    end)
    H.test("ftdetect: .masm -> masm", function()
        H.eq(ft("main.masm"), "masm")
    end)
    H.test("ftdetect: .inc -> masm", function()
        H.eq(ft("defs.inc"), "masm")
    end)

    -- .nasm stays NASM so the nasm treesitter parser (which exists) can highlight
    -- it; conflating it with masm would lose that parser.
    H.test("ftdetect: .nasm -> nasm", function()
        H.eq(ft("main.nasm"), "nasm")
    end)

    -- Sanity check that the second, unrelated rule block in the same file still
    -- applies -- a malformed edit could drop it.
    H.test("ftdetect: .tpp -> cpp", function()
        H.eq(ft("vec.tpp"), "cpp")
    end)
end
