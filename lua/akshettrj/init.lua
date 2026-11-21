vim.g.akshettrj_colorscheme = "cyberdream"
-- vim.g.akshettrj_colorscheme = "gruvbox"
-- vim.g.akshettrj_colorscheme = "rose-pine"
-- vim.g.akshettrj_colorscheme = "rose-pine-main"
-- vim.g.akshettrj_colorscheme = "rose-pine-moon"
-- vim.g.akshettrj_colorscheme = "rose-pine-dawn"
vim.g.akshettrj_colorscheme_light = "dayfox" -- used when ~/.local/bin/theme says "light"

require("akshettrj.autocommands")
require("akshettrj.opts")
require("akshettrj.commands")
require("akshettrj.lazy")
require("akshettrj.vscode")

-- Picks the dark or light colorscheme above and follows ~/.local/bin/theme live
require("akshettrj.theme").setup()
