local utils = require("zuhaib.utils")

return {
  {
    "https://github.com/Julian/lean.nvim",
    enabled = function()
      return not utils.is_inside_vscode()
    end,
    -- main targets neovim 0.12.x; we are on 0.11.x, so pin the compatibility
    -- tag. After upgrading neovim (brew upgrade neovim), drop this `tag` line
    -- to track main again.
    tag = "nvim-0.11",
    -- Neovim detects the `lean` filetype natively, but load on the buffer read
    -- instead so the LSP starts before the first render, as upstream suggests.
    event = { "BufReadPre *.lean", "BufNewFile *.lean" },
    dependencies = {
      -- Lean-specific pickers (:Telescope loogle, etc.)
      "https://github.com/nvim-telescope/telescope.nvim",
    },
    -- lean.nvim shells out to `lake serve`, so elan must be on PATH. A shell
    -- gets that from ~/.zshenv, but a GUI-launched nvim does not inherit it.
    init = function()
      local elan = vim.env.HOME .. "/.elan/bin"
      if not vim.env.PATH:find(elan, 1, true) then
        vim.env.PATH = elan .. ":" .. vim.env.PATH
      end
    end,
    ---@type lean.Config
    opts = {
      -- <LocalLeader>-prefixed Lean bindings: see :h lean.nvim-mappings
      mappings = true,
    },
  },
}
