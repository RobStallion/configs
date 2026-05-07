vim.keymap.set('n', ';', ':')
vim.keymap.set('v', ';', ':')

-- Window navigation
vim.keymap.set('n', '<C-h>', '<C-w>h')
vim.keymap.set('n', '<C-j>', '<C-w>j')
vim.keymap.set('n', '<C-k>', '<C-w>k')
vim.keymap.set('n', '<C-l>', '<C-w>l')

-- Window resize
vim.keymap.set('n', '<C-Up>',    '<cmd>resize +2<CR>',          { desc = 'Increase window height' })
vim.keymap.set('n', '<C-Down>',  '<cmd>resize -2<CR>',          { desc = 'Decrease window height' })
vim.keymap.set('n', '<C-Left>',  '<cmd>vertical resize -2<CR>', { desc = 'Decrease window width' })
vim.keymap.set('n', '<C-Right>', '<cmd>vertical resize +2<CR>', { desc = 'Increase window width' })

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
