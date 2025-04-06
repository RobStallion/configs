return {
  cmd = { "pyright-langserver", "--stdio" },
  filetypes = { "python" },
  root_markers = { "pyproject.toml", "setup.py", ".git/" },
  single_file_support = true,
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
      },
    },
    pyright = {
      -- disableOrganizeImports = true,
    },
  },
  on_attach = function(client, bufnr)
    print("Pyright LSP attached")
    client.server_capabilities.document_formatting = false
    client.server_capabilities.document_range_formatting = false
  end,
}
