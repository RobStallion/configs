vim.api.nvim_create_user_command('LspReload', function()
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = bufnr })

  if #clients == 0 then
    vim.notify('LspReload: no clients attached', vim.log.levels.WARN)
    return
  end

  -- Re-read each server's config file to bust Neovim's cached config
  for _, client in ipairs(clients) do
    local path = vim.api.nvim_get_runtime_file('lsp/' .. client.name .. '.lua', false)[1]
    if path then
      local ok, new_config = pcall(dofile, path)
      if ok and type(new_config) == 'table' then
        vim.lsp.config[client.name] = new_config
      end
    end
  end

  local remaining = #clients

  vim.api.nvim_create_autocmd('LspDetach', {
    group = vim.api.nvim_create_augroup('lsp-reload-' .. bufnr, { clear = true }),
    buffer = bufnr,
    callback = function(_)
      remaining = remaining - 1
      if remaining == 0 then
        vim.api.nvim_del_augroup_by_name('lsp-reload-' .. bufnr)
        vim.cmd('edit')
      end
    end,
  })

  for _, client in ipairs(clients) do
    client:stop()
  end
end, { desc = 'Reload lsp/<name>.lua config from disk and reattach LSP clients for current buffer' })
