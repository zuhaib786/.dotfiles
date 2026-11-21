-- lean.nvim starts its own LSP client, so it never goes through the shared
-- on_attach in lua/zuhaib/plugins/lsp.lua. Re-bind the same navigation keys
-- here so Lean buffers behave like every other LSP buffer.
local map = function(lhs, rhs, desc)
  vim.keymap.set("n", lhs, rhs, { buffer = 0, silent = true, desc = "[LSP] " .. desc })
end

map("gd", vim.lsp.buf.definition, "Go to definition")
map("gD", vim.lsp.buf.declaration, "Go to declaration")
map("gr", vim.lsp.buf.references, "See references")
-- `K` is deliberately not mapped here: lean.nvim binds it to :LeanHover, an
-- interactive hover that beats the generic vim.lsp.buf.hover for Lean.
map("gi", vim.lsp.buf.implementation, "Go to implementation")
map("[d", vim.diagnostic.goto_prev, "Go to previous diagnostic")
map("]d", vim.diagnostic.goto_next, "Go to next diagnostic")
map("<leader>a", vim.lsp.buf.code_action, "Perform code actions")

-- Lean has no formatter, so there is deliberately no format-on-save autocmd
-- here (unlike the go/rust/zig ftplugins).

-- Proofs are indented in 2-space steps and Mathlib style is spaces-only.
vim.opt_local.expandtab = true
vim.opt_local.shiftwidth = 2
vim.opt_local.tabstop = 2

-- Mathlib's linter enforces a 100-column limit.
vim.opt_local.textwidth = 100
vim.opt_local.colorcolumn = "101"

-- Unicode identifiers (α, ↦, ∀) must render as themselves, never be hidden.
vim.opt_local.conceallevel = 0

vim.b.undo_ftplugin = (vim.b.undo_ftplugin and vim.b.undo_ftplugin .. " | " or "")
  .. "setlocal expandtab< shiftwidth< tabstop< textwidth< colorcolumn< conceallevel<"
