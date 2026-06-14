local ss = require('smart-splits')

vim.keymap.set({ 'n', 'v' }, ';', ':', { desc = 'Enter command-line' })

-- Window navigation + resize (smart-splits.nvim)
for _, m in ipairs({
  { '<C-h>', ss.move_cursor_left,  'Move to left split'  },
  { '<C-j>', ss.move_cursor_down,  'Move to below split' },
  { '<C-k>', ss.move_cursor_up,    'Move to above split' },
  { '<C-l>', ss.move_cursor_right, 'Move to right split' },
  { '<A-h>', ss.resize_left,       'Resize split left'   },
  { '<A-j>', ss.resize_down,       'Resize split down'   },
  { '<A-k>', ss.resize_up,         'Resize split up'     },
  { '<A-l>', ss.resize_right,      'Resize split right'  },
}) do
  vim.keymap.set('n', m[1], m[2], { desc = m[3] })
end

-- Centre screen after search jumps
for _, m in ipairs({
  { 'n', 'nzz', 'Next match (centred)'           },
  { 'N', 'Nzz', 'Previous match (centred)'       },
  { '*', '*zz', 'Search word forward (centred)'  },
  { '#', '#zz', 'Search word backward (centred)' },
}) do
  vim.keymap.set('n', m[1], m[2], { desc = m[3] })
end

vim.keymap.set('n', 'H', '<Cmd>nohlsearch<CR>', { desc = 'Clear search highlight' })

vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, { desc = 'Show diagnostic float' })

-- Lua: source file / run line / run selection
vim.keymap.set('n', '<leader>lf', function()
  vim.cmd('source %')
  vim.notify('Sourced ' .. vim.fn.expand('%:t'))
end, { desc = 'Source current file' })

vim.keymap.set('n', '<leader>ll', ':.lua<CR>', { desc = 'Run current line as Lua' })
vim.keymap.set('v', '<leader>ll', ':lua<CR>', { desc = 'Run selection as Lua' })

-- Format file / selection
vim.keymap.set('n', '<leader>=', function()
  require('config.formatter').format_file()
end, { desc = 'Format file' })

vim.keymap.set('v', '<leader>=', function()
  require('config.formatter').format_selection()
end, { desc = 'Format selection' })

vim.keymap.set('n', '<leader>rf', function()
  require('config.keymaps.file_runner').run()
end, { desc = 'Run current file' })

-- Yank helpers (to system clipboard)
local function yank(value, label)
  vim.fn.setreg('+', value)
  vim.notify('Yanked ' .. label .. ': ' .. value)
end

vim.keymap.set('n', '<leader>yf', function()
  yank(vim.fn.expand('%:t:r'), 'filename')
end, { desc = 'Yank filename (no extension)' })

vim.keymap.set('n', '<leader>yp', function()
  yank(vim.fn.expand('%:p'), 'path')
end, { desc = 'Yank full file path' })

vim.keymap.set('n', '<leader>yl', function()
  local file = vim.fn.expand('%:.')
  if file == '' then
    vim.notify('No file name associated with buffer', vim.log.levels.WARN)
    return
  end
  local line = vim.fn.line('.')
  local result = string.format('%s:%d', file, line)
  yank(result, 'file with line number')
end, { desc = 'Yank filename with line number' })

vim.keymap.set('v', '<leader>yl', function()
  local file = vim.fn.expand('%:.')
  if file == '' then
    vim.notify('No file name associated with buffer', vim.log.levels.WARN)
    return
  end
  local start_line = vim.fn.line('v')
  local end_line = vim.fn.line('.')
  local min_line = math.min(start_line, end_line)
  local max_line = math.max(start_line, end_line)
  local result
  if min_line == max_line then
    result = string.format('%s:%d', file, min_line)
  else
    result = string.format('%s:%d-%d', file, min_line, max_line)
  end
  yank(result, 'file with line number(s)')
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', true)
end, { desc = 'Yank filename with line numbers' })

vim.keymap.set('v', '<leader>yc', function()
  local file = vim.fn.expand('%:.')
  if file == '' then
    vim.notify('No file name associated with buffer', vim.log.levels.WARN)
    return
  end
  local start_line = vim.fn.line('v')
  local end_line = vim.fn.line('.')
  local min_line = math.min(start_line, end_line)
  local max_line = math.max(start_line, end_line)
  local ft = vim.bo.filetype
  local lines = vim.api.nvim_buf_get_lines(0, min_line - 1, max_line, false)
  local content = table.concat(lines, '\n')
  local result = string.format('### %s:%d-%d\n```%s\n%s\n```', file, min_line, max_line, ft, content)
  yank(result, 'markdown code block')
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', true)
end, { desc = 'Yank code block with file/line info' })

-- Go to file shortcuts (gs opens file under cursor in vertical split)
vim.keymap.set('n', 'gs', '<Cmd>vertical wincmd f<CR>', { desc = 'Go to file in vertical split' })

-- File Manager (mini.files)
vim.keymap.set('n', '-', function()
  local mf = require('mini.files')
  if not mf.close() then mf.open(vim.api.nvim_buf_get_name(0)) end
end, { desc = 'Open file manager' })

