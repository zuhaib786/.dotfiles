akshettrj_group = vim.api.nvim_create_augroup("akshettrj_group", { clear = true })

-- Remove extra spaces and newlines at end
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  group = akshettrj_group,
  callback = function()
    local curr_pos = vim.fn.getpos(".")
    vim.cmd([[%s/\s\+$//e]])  -- Clean extra whitespaces at the end
    -- vim.cmd([[%s/\n\+%$//e]]) -- Clean extra lines at the end
    vim.fn.setpos(".", curr_pos)
  end,
})

-- Highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
  pattern = "*",
  group = akshettrj_group,
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 40 })
  end,
})

-- Highlight cursor line in Insert mode
vim.api.nvim_create_autocmd("InsertEnter", {
  pattern = "*",
  group = akshettrj_group,
  callback = function()
    vim.opt_local.cursorline = true
  end,
})
vim.api.nvim_create_autocmd("InsertLeave", {
  pattern = "*",
  group = akshettrj_group,
  callback = function()
    vim.opt_local.cursorline = false
  end,
})

-- Do not wrap HTML files
vim.api.nvim_create_autocmd("FileType", {
  pattern = "html",
  group = akshettrj_group,
  callback = function()
    vim.opt.wrap = false
  end,
})

-- Misc settings
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*",
  group = akshettrj_group,
  callback = function()
    vim.opt_local.formatoptions:remove({ "c", "r", "o" })
  end,
})

vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  group = akshettrj_group,
  callback = function()
    vim.api.nvim_set_hl(0, "Normal", { bg = "NONE", ctermbg = "NONE" })
    -- teal-night selection colours; the light theme keeps its own
    if vim.o.background == "dark" then
      vim.api.nvim_set_hl(0, "Visual", { fg = "#e4eef8", bg = "#1e3a52", bold = true })
      vim.api.nvim_set_hl(0, "VisualNOS", { fg = "#c7d7e6", bg = "#16283a", bold = true })
    end

    -- Fix statusline colors
    vim.api.nvim_set_hl(0, "StatusLine", {reverse = false})
    vim.api.nvim_set_hl(0, "StatusLineNC", {reverse = false})
    vim.api.nvim_set_hl(0, "Winbar", {reverse = false})
    vim.api.nvim_set_hl(0, "WinbarNC", {reverse = false})
  end
})

vim.api.nvim_create_autocmd("InsertEnter", {
  group = akshettrj_group,
  callback = function()
    vim.opt.relativenumber = false
  end,
})

vim.api.nvim_create_autocmd("InsertLeave", {
  group = akshettrj_group,
  callback = function()
    vim.opt.relativenumber = true
  end,
})

local function set_tmux_status(visible)
  if vim.env.TMUX == nil then
    return
  end

  if visible then
    vim.fn.system({ "tmux", "set-option", "status", "on" })
    vim.fn.system({ "tmux", "run-shell", "-b", "sleep 0.1; tmux set-option status on" })
  else
    vim.fn.system({ "tmux", "set-option", "status", "off" })
  end
end

vim.api.nvim_create_autocmd({ "VimEnter", "FocusGained" }, {
  group = akshettrj_group,
  callback = function()
    set_tmux_status(false)
  end,
})

vim.api.nvim_create_autocmd({ "VimLeavePre", "VimLeave", "FocusLost" }, {
  group = akshettrj_group,
  callback = function()
    set_tmux_status(true)
  end,
})
