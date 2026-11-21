-- Hide tmux's status bar while Neovim runs; bring it back when Neovim exits or
-- is suspended with Ctrl-Z. The pane-focus-in hook in ~/.tmux.conf handles
-- switching panes and windows; this handles starting and quitting in place.
local pane = vim.env.TMUX_PANE
if not (vim.env.TMUX and pane) or vim.g.vscode or vim.g.started_by_firenvim then
  return
end

local function set_status(value)
  -- Headless runs (scripts, tests) have no UI and shouldn't touch tmux.
  if #vim.api.nvim_list_uis() == 0 then
    return
  end
  -- Wait for tmux so the "on" lands before Neovim exits.
  pcall(function()
    vim.system({ "tmux", "set-option", "-t", pane, "status", value }):wait(1000)
  end)
end

local group = vim.api.nvim_create_augroup("zuhaib_tmux_status", { clear = true })

vim.api.nvim_create_autocmd({ "VimEnter", "VimResume" }, {
  group = group,
  callback = function()
    set_status("off")
  end,
})

vim.api.nvim_create_autocmd({ "VimLeavePre", "VimSuspend" }, {
  group = group,
  callback = function()
    set_status("on")
  end,
})
