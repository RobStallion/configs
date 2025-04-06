return {
  cmd = { "ruff", "server" },
  filetypes = { "python" },
  root_markers = { "pyproject.toml", "ruff.toml", ".git/" },
  single_file_support = true,
  settings = {
  },
  on_attach = function(client, bufnr)
    print("Ruff LSP attached")
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.format({ async = false })
      end,
    })
  end,
}
-- moved out of settings
-- lint = { select = { "E", "F" } },
-- format = { preview = true },
