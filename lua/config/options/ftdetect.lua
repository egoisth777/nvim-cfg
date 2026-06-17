-- Assembly related (MASM, NASM, GAS)
-- .asm/.s/.S/.masm/.inc -> masm  (uses Nvim's builtin masm.vim syntax)
-- .nasm                 -> nasm  (treesitter nasm parser)
vim.filetype.add({
  extension = {
    asm = "masm",
    s = "masm",
    S = "masm",
    masm = "masm",
    inc = "masm", -- MASM include files
    nasm = "nasm",
  },
})

vim.filetype.add({
  extension = {
    tpp = "cpp",
    tpl = "cpp",
  }
})
