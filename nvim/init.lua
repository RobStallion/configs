require("config.lazy")

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.splitright = true
vim.opt.clipboard = "unnamedplus"
vim.opt.wrap = false
vim.opt.smartcase = true

-- Mappings
vim.keymap.set('n', ';', ':')
vim.keymap.set('v', ';', ':')

-- Improve navigation between windows
vim.keymap.set('n', '<C-h>', '<C-w>h')
vim.keymap.set('n', '<C-j>', '<C-w>j')
vim.keymap.set('n', '<C-k>', '<C-w>k')
vim.keymap.set('n', '<C-l>', '<C-w>l')

-- Centers screen vertically after search commands
vim.keymap.set('n', 'n', 'nzz')
vim.keymap.set('n', 'N', 'Nzz')
vim.keymap.set('n', '*', '*zz')
vim.keymap.set('n', '#', '#zz')

-- quickly source a file, line or selected lines
vim.keymap.set('n', '<leader><leader>x', '<cmd>source %<CR>')
vim.keymap.set('n', '<leader>x', ':.lua<CR>')
vim.keymap.set('v', '<leader>x', ':lua<CR>')

-- Add mapping to quickly stop search highlighting
vim.keymap.set('n', 'H', ':nohlsearch<CR>')

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end
})

vim.lsp.enable({ "lua" })
