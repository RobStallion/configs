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

-- Add mapping to quickly stop search highlighting
vim.keymap.set('n', 'H', ':nohlsearch<CR>')

-- Lua: source file / run line / run selection
vim.keymap.set('n', '<leader>lf', function()
  vim.cmd('source %')
  vim.notify('Sourced ' .. vim.fn.expand('%:t'))
end, { desc = 'Source current file' })
vim.keymap.set('n', '<leader>ll', ':.lua<CR>',         { desc = 'Run current line as Lua' })
vim.keymap.set('v', '<leader>ll', ':lua<CR>',          { desc = 'Run selection as Lua' })

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

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end
})

-- Fires when any LSP connects to a buffer. Centralising format-on-save here
-- means each lsp/*.lua file doesn't need its own on_attach boilerplate.
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('lsp-format-on-save', { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    -- Only register format-on-save if this client actually supports formatting.
    -- e.g. pyright skips this, ruff takes it.
    if not client or not client.supports_method('textDocument/formatting') then return end
    -- Buffer-scoped group with clear=true prevents stacking callbacks if the
    -- LSP restarts and re-attaches to the same buffer.
    vim.api.nvim_create_autocmd('BufWritePre', {
      buffer = args.buf,
      group = vim.api.nvim_create_augroup('lsp-format-buf-' .. args.buf, { clear = true }),
      callback = function()
        vim.lsp.buf.format({ bufnr = args.buf, async = false })
      end,
    })
  end,
})

vim.diagnostic.config({
  virtual_text = true,
  severity_sort = true,
  float = { border = "rounded" },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "✘",
      [vim.diagnostic.severity.WARN]  = "▲",
      [vim.diagnostic.severity.HINT]  = "⚑",
      [vim.diagnostic.severity.INFO]  = "»",
    },
  },
})

vim.lsp.enable({
  "lua",
  "ruff",
  "pyright"
})
