require("akshettrj.utils")

return {
  {
    "https://github.com/scottmckendry/cyberdream.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      transparent = false,
      italic_comments = true,
      hide_fillchars = false,
      borderless_pickers = false,
      terminal_colors = true,
      cache = false,
      variant = "default",
      -- palette aligned with kitty teal-night: deep navy bg, mint-teal keywords
      colors = {
        bg = "#0f1e2d",
        bg_alt = "#14263a",
        bg_highlight = "#1e3a52",
        fg = "#c7d7e6",
        grey = "#55708a",
        cyan = "#56c8e0",
        green = "#6ee8cd",
        blue = "#7aa8e0",
        orange = "#4fd6b8",
        red = "#ff7a85",
        yellow = "#e8d48a",
        purple = "#a89ceb",
        magenta = "#c07ae0",
        pink = "#ff8ab0",
      },
      -- match the reference: periwinkle types, cyan methods, mint keywords
      highlights = {
        Type = { fg = "#7aa8e0" },
        Structure = { fg = "#7aa8e0" },
        ["@type"] = { fg = "#7aa8e0" },
        ["@type.builtin"] = { fg = "#7aa8e0" },
        ["@type.definition"] = { fg = "#7aa8e0" },
        ["@constructor"] = { fg = "#7aa8e0" },
        ["@lsp.type.struct"] = { fg = "#7aa8e0" },
        ["@lsp.type.enum"] = { fg = "#7aa8e0" },
        ["@lsp.type.interface"] = { fg = "#7aa8e0" },
        Function = { fg = "#56c8e0" },
        ["@function"] = { fg = "#56c8e0" },
        ["@function.call"] = { fg = "#56c8e0" },
        ["@function.method"] = { fg = "#56c8e0" },
        ["@function.method.call"] = { fg = "#56c8e0" },
        ["@lsp.type.method"] = { fg = "#56c8e0" },
        Number = { fg = "#56c8e0" },
        ["@number"] = { fg = "#56c8e0" },
      },
    },
  },
  {
    -- provides "dayfox", the light colorscheme (see lua/akshettrj/theme.lua)
    "https://github.com/EdenEast/nightfox.nvim",
    priority = 1000,
    lazy = true,
  },
  {
    "https://github.com/ellisonleao/gruvbox.nvim",
    priority = 1000,
    lazy = true,
    opts = {
      terminal_colors = true, -- add neovim terminal colors
      undercurl = true,
      underline = true,
      bold = true,
      italic = {
        strings = false,
        emphasis = true,
        comments = true,
        operators = true,
        folds = true,
      },
      strikethrough = true,
      invert_selection = true,
      invert_signs = false,
      invert_tabline = false,
      invert_intend_guides = false,
      inverse = true,   -- invert background for search, diffs, statuslines and errors
      contrast = "hard", -- can be "hard", "soft" or empty string
      palette_overrides = {},
      overrides = {},
      dim_inactive = false,
      transparent_mode = false,
    },
  },
}
