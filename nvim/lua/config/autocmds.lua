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

-- BufWritePre fires just before the file is saved to disk.
-- pattern scopes it to .json files only.
-- The augroup name is arbitrary; clear=true prevents the autocmd stacking
-- if this file is re-sourced (e.g. via <leader><leader>x).
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = { '*.json' },
  group = vim.api.nvim_create_augroup('jq-format', { clear = true }),
  callback = function(args)
    -- Read every line of the buffer into a Lua table, then join into one string
    -- so we can pipe the whole thing to jq as stdin.
    local input = table.concat(vim.api.nvim_buf_get_lines(args.buf, 0, -1, false), '\n')

    -- Run `jq .` as a shell command, passing input as stdin.
    -- `jq .` with no filter is the identity transform — it just pretty-prints.
    local output = vim.fn.system('jq .', input)

    -- shell_error is 0 on success, non-zero if jq failed (e.g. invalid JSON).
    -- We only replace the buffer if jq succeeded — silently skip on bad JSON
    -- so we don't corrupt a file mid-edit.
    if vim.v.shell_error == 0 then
      -- jq output is a single string; split it back into a line table.
      local lines = vim.split(output, '\n', { plain = true })

      -- jq always appends a trailing newline, which split turns into a final
      -- empty string. Remove it so we don't add a blank line at end of file.
      if lines[#lines] == '' then table.remove(lines) end

      -- Replace the entire buffer content with the formatted lines.
      vim.api.nvim_buf_set_lines(args.buf, 0, -1, false, lines)
    end
  end,
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

