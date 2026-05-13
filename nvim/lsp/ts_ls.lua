local tsserver_bin = vim.fn.resolve(vim.fn.exepath("tsserver"))
return {
  cmd = { "typescript-language-server", "--stdio" },
  filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx" },
  root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git/" },
  single_file_support = true,
  init_options = {
    tsserver = {
      path = vim.fn.fnamemodify(tsserver_bin, ":h:h") .. "/lib/tsserver.js",
    },
  },
}
