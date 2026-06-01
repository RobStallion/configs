require("config.lazy")
require("config.theme")
require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.usercmds")
require("config.filetypes")

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
  "lua_ls",
  "ruff",
  "pyright",
  "gopls",
  "vtsls",
  "deno",
  "jsonls",
  "expert",
})
