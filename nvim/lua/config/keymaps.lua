vim.keymap.set('n', ';', ':')
vim.keymap.set('v', ';', ':')

-- Window navigation + resize (smart-splits.nvim)
vim.keymap.set('n', '<C-h>', require('smart-splits').move_cursor_left)
vim.keymap.set('n', '<C-j>', require('smart-splits').move_cursor_down)
vim.keymap.set('n', '<C-k>', require('smart-splits').move_cursor_up)
vim.keymap.set('n', '<C-l>', require('smart-splits').move_cursor_right)
vim.keymap.set('n', '<A-h>', require('smart-splits').resize_left)
vim.keymap.set('n', '<A-j>', require('smart-splits').resize_down)
vim.keymap.set('n', '<A-k>', require('smart-splits').resize_up)
vim.keymap.set('n', '<A-l>', require('smart-splits').resize_right)

-- Centre screen after search jumps
vim.keymap.set('n', 'n', 'nzz')
vim.keymap.set('n', 'N', 'Nzz')
vim.keymap.set('n', '*', '*zz')
vim.keymap.set('n', '#', '#zz')

vim.keymap.set('n', 'H', ':nohlsearch<CR>', { desc = 'Clear search highlight' })

vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, { desc = 'Show diagnostic float' })

-- Lua: source file / run line / run selection
vim.keymap.set('n', '<leader>lf', function()
  vim.cmd('source %')
  vim.notify('Sourced ' .. vim.fn.expand('%:t'))
end, { desc = 'Source current file' })

vim.keymap.set('n', '<leader>ll', ':.lua<CR>', { desc = 'Run current line as Lua' })
vim.keymap.set('v', '<leader>ll', ':lua<CR>',  { desc = 'Run selection as Lua' })

-- LSP format visual selection
vim.keymap.set('v', '<leader>=', function()
  vim.lsp.buf.format({ async = false })
end, { desc = 'Format selection' })

-- Yank helpers (to system clipboard)
vim.keymap.set('n', '<leader>yf', function()
  local name = vim.fn.expand('%:t:r')
  vim.fn.setreg('+', name)
  vim.notify('Yanked filename: ' .. name)
end, { desc = 'Yank filename (no extension)' })

vim.keymap.set('n', '<leader>yp', function()
  local path = vim.fn.expand('%:p')
  vim.fn.setreg('+', path)
  vim.notify('Yanked path: ' .. path)
end, { desc = 'Yank full file path' })
