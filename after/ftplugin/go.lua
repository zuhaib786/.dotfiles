-- Format with the LSP on save. This file is an ftplugin, so it already runs
-- once per Go buffer: scope the autocmd to the buffer instead of re-registering
-- a global "*.go" pattern each time.
local group = vim.api.nvim_create_augroup("go-lsp-autofmt", { clear = false })
vim.api.nvim_clear_autocmds({ group = group, buffer = 0 })
vim.api.nvim_create_autocmd("BufWritePre", {
    group = group,
    buffer = 0,
    callback = function()
        vim.lsp.buf.format()
    end,
})

-- gofmt indents with hard tabs, so the default listchars ("tab:> ") marks every
-- indent level with a ">". Render tabs as blank space here, but keep the
-- trailing-whitespace and nbsp markers that make `list` worth having.
vim.opt_local.listchars = { tab = "  ", trail = "-", nbsp = "+" }

-- listchars is window-local and the autocmd is buffer-local, so undo both when
-- the filetype changes.
vim.b.undo_ftplugin = (vim.b.undo_ftplugin and vim.b.undo_ftplugin .. " | " or "")
    .. "setlocal listchars< | exe 'au! go-lsp-autofmt * <buffer>'"
