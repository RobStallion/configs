return {
  "neovim/nvim-lspconfig",
  enabled = false,
  lazy = true,
  event = "BufReadPre",
  dependencies = {
    {
      "folke/lazydev.nvim",
      ft = "lua", -- only load on lua files
      opts = {
        library = {
          -- See the configuration section for more details
          -- Load luvit types when the `vim.uv` word is found
          { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        },
      },
    }
  },


  config = function()
    local lspconfig = require('lspconfig')
    -- local capabilities = require('blink.cmp').get_lsp_capabilities()

    -- lspconfig.lua_ls.setup { capabilities = capabilities } -- lua
    lspconfig.lua_ls.setup {}   -- lua
    lspconfig.ruff.setup {}     -- python
    lspconfig.marksman.setup {} -- markdown

    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not client then return end
        print("lsp", client.name, "attached")

        if client.supports_method('textDocument/formatting') then
          vim.api.nvim_create_autocmd('BufWritePre', {
            buffer = args.buf,
            callback = function()
              vim.lsp.buf.format({ bufnr = args.buf, id = client.id })
            end
          })
        end
      end,
    })
  end
}
