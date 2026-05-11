vim.filetype.add({
  pattern = {
    [".*/ghostty/config"] = "ghostty",
  },
})

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
    if not client or not client:supports_method('textDocument/formatting') then return end
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

