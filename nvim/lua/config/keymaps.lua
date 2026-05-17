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

-- LSP format visual selection
vim.keymap.set('v', '<leader>=', function()
  vim.lsp.buf.format({ async = false })
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
