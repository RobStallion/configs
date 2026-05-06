require("config.lazy")

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.splitright = true
vim.opt.clipboard = "unnamedplus"
vim.opt.wrap = false
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Tab settings
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.smartindent = true

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

-- Copy filename without extension to clipboard
vim.keymap.set('n', '<leader>fn', function()
  local filename = vim.fn.expand('%:t:r')
  vim.fn.setreg('+', filename)
  vim.notify('Copied filename: ' .. filename)
end, { desc = 'Copy filename without extension' })

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end
})

vim.lsp.enable({
  "lua",
  "ruff",
  "pyright"
})
