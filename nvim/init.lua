require("config.lazy")
require("config.options")
require("config.keymaps")
require("config.autocmds")

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
  "pyright",
  "gopls",
  "ts_ls",
})
