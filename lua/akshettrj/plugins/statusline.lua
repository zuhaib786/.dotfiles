local utils = require("akshettrj.utils")

local palettes = {
  dark = {
    bg = "#1b1b1b",
    bg_alt = "#242321",
    bg_soft = "#2c2a26",
    fg = "#c8bda8",
    fg_dim = "#8f8678",
    orange = "#d3865b",
    charcoal = "#111111",
  },
  -- dayfox; "charcoal" is the text drawn on the accent
  light = {
    bg = "#e4dcd4",
    bg_alt = "#dbd1dd",
    bg_soft = "#d3c7bb",
    fg = "#3d2b5a",
    fg_dim = "#837a72",
    orange = "#ac5402",
    charcoal = "#f6f2ee",
  },
}

-- Filled in place from the palette matching 'background' (see set_palette).
local colors = {}

local function set_palette()
  for k, v in pairs(palettes[vim.o.background] or palettes.dark) do
    colors[k] = v
  end
end
set_palette()

local function has_nerd_font()
  return vim.g.have_nerd_font ~= false and vim.g.nerd_font_enabled ~= false
end

local function icon(nerd, fallback)
  if has_nerd_font() then
    return nerd
  end

  return fallback
end

local function file_icon()
  local ft = vim.bo.filetype
  local name = vim.fn.expand("%:t")

  if ft == "zig" or name:match("%.zig$") or name:match("%.zig%.zon$") then
    return icon("", "zig")
  end

  local ok, devicons = pcall(require, "nvim-web-devicons")
  if ok then
    local devicon = devicons.get_icon(name, vim.fn.expand("%:e"), { default = false })
    if devicon then
      return devicon
    end
  end

  return icon("", "file")
end

local function filename()
  local name = vim.fn.expand("%:t")
  if name == "" then
    return "[No Name]"
  end

  return name
end

local function modified()
  if vim.bo.modified then
    return icon("●", "+")
  end

  if not vim.bo.modifiable or vim.bo.readonly then
    return icon("", "ro")
  end

  return ""
end

local function buffer_count()
  local count = 0
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buflisted then
      count = count + 1
    end
  end

  return string.format("%s %d", icon("󰆧", "buf"), count)
end

local symbol_cache = {}
local symbol_group = vim.api.nvim_create_augroup("akshettrj_lualine_symbols", { clear = true })
local key_namespace = vim.api.nvim_create_namespace("akshettrj_lualine_keys")
local key_state = {
  text = "",
  last = 0,
  timer = vim.uv and vim.uv.new_timer() or vim.loop.new_timer(),
}

local function get_lsp_clients(bufnr)
  if vim.lsp.get_clients then
    return vim.lsp.get_clients({ bufnr = bufnr })
  end

  return vim.lsp.get_active_clients({ bufnr = bufnr })
end

local function client_supports_document_symbols(client)
  if client.supports_method then
    return client:supports_method("textDocument/documentSymbol")
  end

  return client.server_capabilities and client.server_capabilities.documentSymbolProvider
end

local function request_document_symbols(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  local cached = symbol_cache[bufnr]
  if cached and cached.pending then
    return
  end

  local has_symbol_client = false
  for _, client in ipairs(get_lsp_clients(bufnr)) do
    if client_supports_document_symbols(client) then
      has_symbol_client = true
      break
    end
  end

  if not has_symbol_client then
    symbol_cache[bufnr] = { symbols = nil, pending = false }
    return
  end

  symbol_cache[bufnr] = vim.tbl_extend("force", symbol_cache[bufnr] or {}, { pending = true })
  vim.lsp.buf_request(bufnr, "textDocument/documentSymbol", {
    textDocument = vim.lsp.util.make_text_document_params(bufnr),
  }, function(err, result)
    if err or not vim.api.nvim_buf_is_valid(bufnr) then
      symbol_cache[bufnr] = { symbols = nil, pending = false }
      return
    end

    symbol_cache[bufnr] = { symbols = result, pending = false }
    pcall(vim.cmd, "redrawstatus")
  end)
end

local function range_contains(range, row, col)
  if not range then
    return false
  end

  local start = range.start
  local finish = range["end"]
  if row < start.line or row > finish.line then
    return false
  end

  if row == start.line and col < start.character then
    return false
  end

  if row == finish.line and col > finish.character then
    return false
  end

  return true
end

local function range_size(range)
  return ((range["end"].line - range.start.line) * 100000) + (range["end"].character - range.start.character)
end

local function current_function_symbol()
  local bufnr = vim.api.nvim_get_current_buf()
  local cached = symbol_cache[bufnr]

  if cached == nil then
    request_document_symbols(bufnr)
    return ""
  end

  if not cached.symbols then
    return ""
  end

  local cursor = vim.api.nvim_win_get_cursor(0)
  local row = cursor[1] - 1
  local col = cursor[2]
  local function_kinds = {
    [6] = true, -- Method
    [9] = true, -- Constructor
    [12] = true, -- Function
  }
  local best

  local function visit(symbols)
    for _, symbol in ipairs(symbols or {}) do
      local range = symbol.range or (symbol.location and symbol.location.range)
      if range and range_contains(range, row, col) then
        if function_kinds[symbol.kind] then
          if not best or range_size(range) <= range_size(best.range) then
            best = { name = symbol.name, range = range }
          end
        end

        if symbol.children then
          visit(symbol.children)
        end
      end
    end
  end

  visit(cached.symbols)

  if not best then
    return ""
  end

  return string.format("%s %s", icon("󰊕", "fn"), best.name)
end

local function pressed_keys()
  if key_state.text == "" then
    return ""
  end

  return string.format("%s %s", icon("󰌌", "keys"), key_state.text)
end

-- With cmdheight=0 the "recording @q" message has nowhere to go, so show it here.
local function recording()
  local reg = vim.fn.reg_recording()
  if reg == "" then
    return ""
  end

  return string.format("%s @%s", icon("󰑋", "rec"), reg)
end

local function trim_key_text(text)
  local max_chars = 18
  local chars = vim.fn.strchars(text)
  if chars <= max_chars then
    return text
  end

  return "…" .. vim.fn.strcharpart(text, chars - max_chars + 1, max_chars - 1)
end

local function redraw_status()
  vim.schedule(function()
    pcall(vim.cmd, "redrawstatus")
  end)
end

local function mode_name()
  local mode = vim.fn.mode(1)
  local names = {
    n = "NORMAL",
    no = "O-PENDING",
    nov = "O-PENDING",
    noV = "O-PENDING",
    ["no\22"] = "O-PENDING",
    niI = "NORMAL",
    niR = "NORMAL",
    niV = "NORMAL",
    nt = "NORMAL",
    v = "VISUAL",
    V = "V-LINE",
    ["\22"] = "V-BLOCK",
    s = "SELECT",
    S = "S-LINE",
    ["\19"] = "S-BLOCK",
    i = "INSERT",
    ic = "INSERT",
    ix = "INSERT",
    R = "REPLACE",
    Rc = "REPLACE",
    Rv = "V-REPLACE",
    Rx = "REPLACE",
    c = "COMMAND",
    cv = "EX",
    ce = "EX",
    r = "PROMPT",
    rm = "MORE",
    ["r?"] = "CONFIRM",
    ["!"] = "SHELL",
    t = "TERMINAL",
  }

  return names[mode] or mode:upper()
end

local function spell_status()
  if utils.is_spell_mode_on() then
    return icon("󰓆", "spell")
  end

  return ""
end

local function clock()
  return os.date("%H:%M")
end

local function make_theme()
  return {
  normal = {
    a = { fg = colors.charcoal, bg = colors.orange, gui = "bold" },
    b = { fg = colors.orange, bg = colors.bg_soft },
    c = { fg = colors.fg, bg = colors.bg },
    x = { fg = colors.fg_dim, bg = colors.bg },
    y = { fg = colors.fg, bg = colors.bg_soft },
    z = { fg = colors.charcoal, bg = colors.orange, gui = "bold" },
  },
  insert = { a = { fg = colors.charcoal, bg = colors.orange, gui = "bold" } },
  visual = { a = { fg = colors.charcoal, bg = colors.orange, gui = "bold" } },
  replace = { a = { fg = colors.charcoal, bg = colors.orange, gui = "bold" } },
  command = { a = { fg = colors.charcoal, bg = colors.orange, gui = "bold" } },
  inactive = {
    a = { fg = colors.fg_dim, bg = colors.bg_alt },
    b = { fg = colors.fg_dim, bg = colors.bg_alt },
    c = { fg = colors.fg_dim, bg = colors.bg },
    x = { fg = colors.fg_dim, bg = colors.bg },
    y = { fg = colors.fg_dim, bg = colors.bg_alt },
    z = { fg = colors.fg_dim, bg = colors.bg_alt },
  },
  }
end

local spec
spec = {
  "https://github.com/nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  init = function()
    vim.opt.showcmd = false

    pcall(vim.on_key, nil, key_namespace)
    vim.on_key(function(key)
      if key == "" then
        return
      end

      local now = vim.loop.hrtime() / 1000000
      local translated = vim.fn.keytrans(key)
      if translated == "" then
        return
      end

      if now - key_state.last > 900 then
        key_state.text = translated
      else
        key_state.text = trim_key_text(key_state.text .. translated)
      end

      key_state.last = now
      redraw_status()

      key_state.timer:stop()
      key_state.timer:start(1500, 0, function()
        key_state.text = ""
        redraw_status()
      end)
    end, key_namespace)

    vim.api.nvim_create_autocmd({ "LspAttach", "BufEnter", "BufWritePost", "TextChanged", "TextChangedI" }, {
      group = symbol_group,
      callback = function(args)
        vim.defer_fn(function()
          request_document_symbols(args.buf)
        end, 80)
      end,
    })

    vim.api.nvim_create_autocmd({ "RecordingEnter", "RecordingLeave" }, {
      group = symbol_group,
      callback = redraw_status, -- scheduled, so RecordingLeave sees the register cleared
    })

    vim.api.nvim_create_autocmd({ "LspDetach", "BufDelete", "BufWipeout" }, {
      group = symbol_group,
      callback = function(args)
        symbol_cache[args.buf] = nil
      end,
    })
  end,
  opts = function()
    return {
    options = {
      theme = make_theme(),
      globalstatus = false,
      disabled_filetypes = { statusline = { "dashboard", "alpha", "starter" } },
      component_separators = { left = icon("", "|"), right = icon("", "|") },
      section_separators = { left = icon("", " "), right = icon("", " ") },
      refresh = {
        statusline = 1000,
      },
    },
    extensions = {},
    sections = {
      lualine_a = {
        {
          mode_name,
          padding = { left = 1, right = 1 },
        },
      },
      lualine_b = {
        {
          file_icon,
          color = { fg = colors.orange, bg = colors.bg_soft, gui = "bold" },
          separator = { left = icon("", " "), right = "" },
          padding = { left = 2, right = 2 },
        },
        {
          filename,
          color = { fg = colors.fg, bg = colors.bg_soft },
          separator = { left = "", right = "" },
          padding = { left = 0, right = 1 },
        },
        {
          modified,
          color = { fg = colors.orange, bg = colors.bg_soft },
          separator = { left = "", right = icon("", " ") },
          padding = { left = 0, right = 1 },
        },
        {
          "branch",
          icon = icon("", "git"),
          color = { fg = colors.fg_dim, bg = colors.bg },
          separator = { left = "", right = "" },
          padding = { left = 1, right = 1 },
        },
        {
          current_function_symbol,
          color = { fg = colors.fg_dim, bg = colors.bg },
          separator = { left = icon("", "|"), right = "" },
          padding = { left = 1, right = 1 },
        },
      },
      lualine_c = {
        "%=",
        {
          "diff",
          symbols = {
            added = icon(" ", "+"),
            modified = icon(" ", "~"),
            removed = icon(" ", "-"),
          },
          colored = false,
          color = { fg = colors.orange, bg = colors.bg },
        },
      },
      lualine_x = {
        {
          recording,
          color = { fg = colors.orange, bg = colors.bg, gui = "bold" },
          padding = { left = 1, right = 1 },
        },
        {
          -- [3/7] for the last search; hidden after :noh. Replaces the count
          -- Neovim would echo in the (now hidden) cmdline, see shortmess+=S.
          "searchcount",
          maxcount = 999,
          timeout = 250,
          color = { fg = colors.fg, bg = colors.bg },
          padding = { left = 1, right = 1 },
        },
        {
          pressed_keys,
          color = { fg = colors.orange, bg = colors.bg },
          padding = { left = 1, right = 1 },
        },
        {
          spell_status,
          color = { fg = colors.orange, bg = colors.bg },
          padding = { left = 1, right = 0 },
        },
        {
          "diagnostics",
          symbols = {
            error = icon(" ", "E"),
            warn = icon(" ", "W"),
            info = icon(" ", "I"),
            hint = icon(" ", "H"),
          },
          colored = false,
          color = { fg = colors.orange, bg = colors.bg },
        },
        {
          buffer_count,
          color = { fg = colors.fg, bg = colors.bg_soft },
          separator = { left = icon("", " "), right = "" },
          padding = { left = 1, right = 1 },
        },
      },
      lualine_y = {
        {
          "progress",
          color = { fg = colors.fg, bg = colors.bg_alt },
          separator = { left = icon("", " "), right = "" },
          padding = { left = 1, right = 1 },
        },
      },
      lualine_z = {
        {
          "location",
          separator = { left = icon("", " "), right = "" },
          padding = { left = 1, right = 1 },
        },
        {
          clock,
          icon = icon("󰥔", "time"),
          color = { fg = colors.charcoal, bg = colors.orange, gui = "bold" },
          separator = { left = icon("", " "), right = "" },
          padding = { left = 1, right = 1 },
        },
      },
    },
    inactive_sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = {
        {
          filename,
          color = { fg = colors.fg_dim, bg = colors.bg },
          padding = { left = 1, right = 1 },
        },
      },
      lualine_x = {
        {
          "location",
          color = { fg = colors.fg_dim, bg = colors.bg },
          padding = { left = 1, right = 1 },
        },
      },
      lualine_y = {},
      lualine_z = {},
    },
    }
  end,
  config = function(_, opts)
    local lualine = require("lualine")
    lualine.setup(opts)
    -- Rebuild colours when the light/dark theme switches (lua/akshettrj/theme.lua)
    vim.api.nvim_create_autocmd("ColorScheme", {
      group = vim.api.nvim_create_augroup("akshettrj_lualine_theme", { clear = true }),
      callback = function()
        set_palette()
        lualine.setup(spec.opts())
      end,
    })
  end,
  dependencies = {
    "https://github.com/nvimdev/lspsaga.nvim",
    "https://github.com/nvim-tree/nvim-web-devicons",
  },
}

return spec
