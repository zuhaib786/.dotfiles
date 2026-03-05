local utils = require("akshettrj.utils")
return {
  {
    "https://github.com/nvim-treesitter/nvim-treesitter",
    enabled = function()
      return not utils.is_inside_vscode()
    end,
    build = ":TSUpdate",
    lazy = false,
    opts = {
      auto_install = true,
      sync_install = true,
      ignore_install = {},
      highlight = {
        enable = true,
        disable = { "vimwiki", "latex" },
        additional_vim_regex_highlighting = false,
      },
      indent = { enable = false },
      matchup = { enable = false },
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ["af"] = { query = "@function.outer", desc = "Select around current function" },
            ["if"] = { query = "@function.inner", desc = "Select inside current function" },
            ["ac"] = { query = "@class.outer", desc = "Select around current class" },
            ["ic"] = { query = "@class.inner", desc = "Select inside current class" },
          },
        },
        move = {
          enable = true,
          set_jumps = true,
          goto_next_start = {
            ["]f"] = { query = "@function.outer", desc = "Next function start" },
            ["]p"] = { query = "@parameter.outer", desc = "Next function parameter start" },
          },
          goto_next_end = {
            ["]F"] = { query = "@function.outer", desc = "Next function end" },
            ["]P"] = { query = "@parameter.outer", desc = "Next function parameter end" },
          },
          goto_previous_start = {
            ["[f"] = { query = "@function.outer", desc = "Previous function start" },
            ["[p"] = { query = "@parameter.outer", desc = "Previous function parameter start" },
          },
          goto_previous_end = {
            ["[F"] = { query = "@function.outer", desc = "Previous function end" },
            ["[P"] = { query = "@parameter.outer", desc = "Previous function parameter end" },
          },
        },
      },
    },
  },
  {
    "https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
    enabled = function()
      return not utils.is_inside_vscode()
    end,
    lazy = false,
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  },
  {
    "https://github.com/nvim-treesitter/nvim-treesitter-context",
    enabled = false,
    event = { "VeryLazy" },
    config = function()
      require("treesitter-context").setup({
        enable = true,
        max_lines = 0,
        multiline_threshold = 2,
      })
      local highlight_settings = {
        underline = true,
        sp = "Grey",
        bg = "Black",
      }
      vim.api.nvim_set_hl(0, "TreesitterContext", highlight_settings)
      vim.api.nvim_set_hl(0, "TreesitterContextLineNumber", highlight_settings)
    end,
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  }
}
