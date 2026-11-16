-- Statusline. Replaced feline.nvim on 2026-07-28 (archived upstream Sept 2023, and calling
-- APIs deprecated out of Neovim 0.12). This is a deliberate port of the previous feline
-- layout -- same one_monokai palette, same component order -- with the data sources fixed.
--
-- Feline's git providers read gitsigns.nvim's b:gitsigns_head / b:gitsigns_status_dict, and
-- its diagnostic providers read vim.diagnostic / vim.lsp. This config has none of those: git
-- signs come from vim-gitgutter, and coc.nvim keeps diagnostics in its own store rather than
-- vim.diagnostic. So those nine components silently rendered empty for as long as they
-- existed. They are wired to the real sources here. See the vault: "feline to lualine port".

local ok, lualine = pcall(require, 'lualine')
if not ok then
  return
end

-- Palette carried over verbatim from the previous feline config.
-- Source: https://github.com/Hitesh-Aggarwal/feline_theme.nvim
local c = {
  fg = '#abb2bf',
  bg = '#1e2024',
  green = '#98c379',
  yellow = '#e5c07b',
  purple = '#c678dd',
  orange = '#d19a66',
  peanut = '#f6d5a4',
  red = '#e06c75',
  aqua = '#61afef',
  darkblue = '#282c34',
  dark_red = '#f75f5f',
}

-- Feline coloured the mode *name* and kept a constant background. lualine themes only
-- distinguish normal/insert/visual/replace/command, which would collapse feline's separate
-- V-Line (orange) and V-Block (dark red). Colour the component directly off mode() instead,
-- so all of feline's vi_mode_colors survive.
local mode_color = {
  n = c.green,
  no = c.green, -- operator-pending, feline's OP
  nov = c.green,
  noV = c.green,
  niI = c.green,
  niR = c.green,
  niV = c.green,
  i = c.yellow,
  ic = c.yellow,
  ix = c.yellow,
  v = c.purple,
  vs = c.purple,
  V = c.orange, -- feline's LINES
  Vs = c.orange,
  ['\22'] = c.dark_red, -- <C-v>, feline's BLOCK
  ['\22s'] = c.dark_red,
  s = c.purple,
  S = c.orange,
  ['\19'] = c.dark_red,
  R = c.red,
  Rc = c.red,
  Rv = c.red,
  Rx = c.red,
  c = c.aqua,
  cv = c.aqua,
  ce = c.aqua,
  r = c.aqua,
  rm = c.aqua,
  ['r?'] = c.aqua,
  ['!'] = c.green,
  t = c.green,
}

-- Only `normal` and `inactive` are defined; lualine falls back to `normal` for every other
-- mode, which is what we want since the mode colour is applied per-component above.
local theme = {
  normal = {
    a = { fg = c.green, bg = c.darkblue, gui = 'bold' },
    b = { fg = c.fg, bg = c.darkblue },
    c = { fg = c.fg, bg = c.bg },
  },
  inactive = {
    a = { fg = c.fg, bg = c.darkblue },
    b = { fg = c.fg, bg = c.darkblue },
    c = { fg = c.fg, bg = c.bg },
  },
}

-- vim-gitgutter's equivalent of the gitsigns status dict feline expected.
-- GitGutterGetHunkSummary() is documented as [added, modified, removed].
local function gitgutter_diff()
  local got, summary = pcall(vim.fn.GitGutterGetHunkSummary)
  if not got or type(summary) ~= 'table' then
    return nil
  end
  return { added = summary[1], modified = summary[2], removed = summary[3] }
end

-- coc.nvim publishes b:coc_diagnostic_info = { error, warning, information, hint }.
-- It only populates vim.diagnostic when `diagnostic.displayByVimDiagnostic` is enabled,
-- which this config deliberately leaves off so coc keeps drawing its own signs.
local function coc_diagnostic(key, icon)
  return function()
    local info = vim.b.coc_diagnostic_info
    if not info or (info[key] or 0) == 0 then
      return ''
    end
    return icon .. info[key]
  end
end

local function coc_status()
  local status = vim.g.coc_status
  if not status or status == '' then
    return ''
  end
  return status
end

-- feline's file_info with type = 'relative-short', including its readonly/modified markers.
local function filename()
  local name = vim.api.nvim_buf_get_name(0)
  if name == '' then
    name = '[No Name]'
  else
    name = vim.fn.pathshorten(vim.fn.fnamemodify(name, ':~:.'))
  end
  -- A literal % would otherwise be read as a statusline item.
  name = name:gsub('%%', '%%%%')
  local readonly = vim.bo.readonly and ' ' or ''
  local modified = vim.bo.modified and ' ●' or ''
  return readonly .. name .. modified
end

-- feline's cursor.position: column counted in characters, not bytes, with tabs expanded.
-- The single-argument vim.str_utfindex(s) feline used was deprecated out of Neovim 0.12;
-- this is the current spelling of the same thing.
local function position()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  local before_cursor = vim.api.nvim_get_current_line():sub(1, col)
  before_cursor = (before_cursor:gsub('\t', string.rep(' ', vim.bo.tabstop)))
  return string.format('%d:%d', line, vim.str_utfindex(before_cursor, 'utf-32') + 1)
end

-- feline's cursor.line_percentage, behaviour for behaviour.
local function line_percentage()
  local current = vim.api.nvim_win_get_cursor(0)[1]
  local total = vim.api.nvim_buf_line_count(0)
  if current == 1 then
    return 'Top'
  elseif current == total then
    return 'Bot'
  end
  -- %% renders as a literal percent sign in a statusline.
  return string.format('%2d%%%%', math.ceil(current / total * 99))
end

-- feline's cursor.scroll_bar.
local scroll_blocks = { '▁', '▂', '▃', '▄', '▅', '▆', '▇', '█' }
local function scroll_bar()
  local total = vim.api.nvim_buf_line_count(0)
  if total == 0 then
    return ''
  end
  local current = vim.api.nvim_win_get_cursor(0)[1]
  local index = math.floor(current / total * 7) + 1
  return string.rep(scroll_blocks[math.min(index, 8)], 2)
end

lualine.setup({
  options = {
    theme = theme,
    -- feline used "block" separators almost everywhere, which are just padding.
    section_separators = { left = '', right = '' },
    component_separators = { left = '', right = '' },
    globalstatus = false,
  },
  sections = {
    lualine_a = {
      {
        'mode',
        color = function()
          return { fg = mode_color[vim.fn.mode()] or c.green, bg = c.darkblue, gui = 'bold' }
        end,
      },
    },
    lualine_b = {
      { 'branch', icon = '', color = { fg = c.peanut, bg = c.darkblue, gui = 'bold' } },
      {
        'diff',
        source = gitgutter_diff,
        symbols = { added = ' ', modified = ' ', removed = ' ' },
        diff_color = {
          added = { fg = c.green, bg = c.darkblue },
          modified = { fg = c.fg, bg = c.darkblue },
          removed = { fg = c.red, bg = c.darkblue },
        },
        color = { bg = c.darkblue },
      },
    },
    -- The leading '%=' gives lualine a second fill point, which centres this section the way
    -- feline's three-way left/middle/right split did.
    lualine_c = {
      { '%=', padding = 0 },
      { 'filetype', icon_only = true, colored = true, padding = { left = 1, right = 0 } },
      { filename, color = { gui = 'bold' } },
      { coc_diagnostic('error', '  '), color = { fg = c.red } },
      { coc_diagnostic('warning', '  '), color = { fg = c.yellow } },
      { coc_diagnostic('information', '  '), color = { fg = c.fg } },
      { coc_diagnostic('hint', '  '), color = { fg = c.aqua } },
    },
    lualine_x = {
      { coc_status, icon = '', color = { fg = c.purple, bg = c.darkblue, gui = 'bold' } },
      {
        'filetype',
        icon_only = false,
        fmt = function(str)
          return str:sub(1, 1):upper() .. str:sub(2)
        end,
        color = { fg = c.red, bg = c.darkblue, gui = 'bold' },
      },
      { 'encoding', color = { fg = c.orange, bg = c.darkblue, gui = 'italic' } },
    },
    lualine_y = {
      { position, color = { fg = c.green, bg = c.darkblue, gui = 'bold' } },
      { line_percentage, color = { fg = c.aqua, bg = c.darkblue, gui = 'bold' } },
    },
    lualine_z = {
      { scroll_bar, color = { fg = c.yellow, bg = c.darkblue, gui = 'bold' } },
    },
  },
})
