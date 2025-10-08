-- Assembly related (MASM, NASM, GAS)
vim.filetype.add({
  extension = {
    asm = "nasm",
    s = "nasm",
    S = "nasm",
    masm = "nasm", -- MASM specific
    inc = "nasm",  -- MASM include files
  },
})

vim.filetype.add({
  extension = {
    tpp = "cpp",
    tpl = "cpp",
  }
})
