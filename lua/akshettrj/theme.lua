-- Light/dark colorscheme switching, driven by ~/.local/bin/theme.
--
-- The script writes "light" or "dark" to ~/.local/state/theme/mode (on
-- cmd+shift+l in kitty, and at sunrise/sunset via launchd). Every running
-- Neovim watches that file and switches colorscheme live; new ones read it at
-- startup.
local M = {}

M.schemes = {
  dark = vim.g.akshettrj_colorscheme or "cyberdream",
  light = vim.g.akshettrj_colorscheme_light or "dayfox",
}

local state_dir = vim.fn.expand("~/.local/state/theme")
local mode_file = state_dir .. "/mode"

local function read_mode()
  local f = io.open(mode_file, "r")
  if not f then
    return nil
  end
  local mode = f:read("*l")
  f:close()
  if mode == "light" or mode == "dark" then
    return mode
  end
  return nil
end

function M.apply(mode)
  mode = mode or read_mode() or "dark"
  local scheme = M.schemes[mode]
  if mode == M.mode and vim.g.colors_name == scheme then
    return
  end
  local ok, err = pcall(vim.cmd.colorscheme, scheme)
  if not ok then
    vim.notify("theme: could not load " .. scheme .. ": " .. tostring(err), vim.log.levels.WARN)
    return
  end
  M.mode = mode
  if vim.o.background ~= mode then
    vim.o.background = mode
  end
end

function M.watch()
  if M.watcher then
    return
  end
  vim.fn.mkdir(state_dir, "p")
  local watcher = vim.uv.new_fs_event()
  if not watcher then
    return
  end
  -- Watch the directory: the script replaces the file with a rename.
  watcher:start(state_dir, {}, vim.schedule_wrap(function(err, filename)
    if err or (filename and filename ~= "mode") then
      return
    end
    M.apply()
  end))
  M.watcher = watcher
end

function M.setup()
  M.apply()
  if vim.g.vscode then
    return
  end
  M.watch()
  -- Fallback in case a file event was missed (e.g. after sleep).
  vim.api.nvim_create_autocmd("FocusGained", {
    group = vim.api.nvim_create_augroup("akshettrj_theme", { clear = true }),
    callback = function()
      M.apply()
    end,
  })
end

return M
