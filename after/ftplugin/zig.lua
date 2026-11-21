vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.zig", "*.zon" },
  group = vim.api.nvim_create_augroup("zig-lsp-autofmt", { clear = true }),
  callback = function()
    vim.lsp.buf.format()
  end,
})
