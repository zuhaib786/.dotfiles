local utils = require("akshettrj.utils")

vim.opt.number = true
vim.opt.inccommand = "split"
vim.opt.relativenumber = true
vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"
vim.opt.mouse = "a"
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.completeopt = { "menu", "menuone", "noselect" }
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel = 99 -- open files unfolded; za / zc / zM to close
vim.opt.title = true
vim.opt.showmode = false
vim.opt.cmdheight = 0 -- no empty row under the statusline; it appears for ':' and messages
vim.opt.shortmess:append("S") -- search count lives in lualine instead of the cmdline
vim.opt.virtualedit = "block"
vim.opt.signcolumn = "yes"
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
-- vim.opt.winbar = "%=%m %f"
vim.opt.termguicolors = true
vim.opt_global.termguicolors = true
vim.opt.list = true
vim.opt.fillchars = { eob = " " }
-- vim.opt.ignorecase = true
-- vim.opt.smartcase = true

if not utils.is_inside_vscode() then
  vim.opt.scrolloff = 10
end

if vim.g.started_by_firenvim == true then
  vim.opt_global.laststatus = 0
else
  vim.opt_global.laststatus = 2
end
