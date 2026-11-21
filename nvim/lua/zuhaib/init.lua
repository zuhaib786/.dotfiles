vim.g.zuhaib_colorscheme = "cyberdream"
-- vim.g.zuhaib_colorscheme = "gruvbox"
-- vim.g.zuhaib_colorscheme = "rose-pine"
-- vim.g.zuhaib_colorscheme = "rose-pine-main"
-- vim.g.zuhaib_colorscheme = "rose-pine-moon"
-- vim.g.zuhaib_colorscheme = "rose-pine-dawn"
vim.g.zuhaib_colorscheme_light = "dayfox" -- used when ~/.local/bin/theme says "light"

require("zuhaib.autocommands")
require("zuhaib.opts")
require("zuhaib.commands")
require("zuhaib.lazy")
require("zuhaib.vscode")
require("zuhaib.tmux")

-- Picks the dark or light colorscheme above and follows ~/.local/bin/theme live
require("zuhaib.theme").setup()
