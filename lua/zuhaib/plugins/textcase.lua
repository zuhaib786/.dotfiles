return {
  "johmsalas/text-case.nvim",
  dependencies = { "nvim-telescope/telescope.nvim" },
  config = function()
    require("textcase").setup({
      default_keymappings_enabled = true,
      prefix = "ga",
    })
    require("telescope").load_extension("textcase")
  end,
  keys = {
    { "ga.", "<cmd>TextCaseOpenTelescope<CR>", mode = { "n", "v" }, desc = "Telescope Text Case" },
    -- Quick change commands
    { "gaa", "<cmd>TextCaseOpenTelescopeQuickChange<CR>", mode = { "n", "v" }, desc = "Quick Change" },
    -- Specific case conversions (examples)
    { "gau", "<cmd>lua require('textcase').current_word('to_upper_case')<CR>", mode = "n", desc = "To UPPER" },
    { "gal", "<cmd>lua require('textcase').current_word('to_lower_case')<CR>", mode = "n", desc = "To lower" },
    { "gas", "<cmd>lua require('textcase').current_word('to_snake_case')<CR>", mode = "n", desc = "To snake_case" },
    { "gad", "<cmd>lua require('textcase').current_word('to_dash_case')<CR>", mode = "n", desc = "To dash-case" },
    { "gan", "<cmd>lua require('textcase').current_word('to_constant_case')<CR>", mode = "n", desc = "To CONSTANT" },
    { "gac", "<cmd>lua require('textcase').current_word('to_camel_case')<CR>", mode = "n", desc = "To camelCase" },
    { "gap", "<cmd>lua require('textcase').current_word('to_pascal_case')<CR>", mode = "n", desc = "To PascalCase" },
  },
  cmd = {
    "Subs",
    "TextCaseOpenTelescope",
    "TextCaseOpenTelescopeQuickChange",
    "TextCaseOpenTelescopeLSPChange",
  },
}
