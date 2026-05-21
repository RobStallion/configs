return {
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
  root_markers = { '.luarc.json', '.luarc.jsonc', 'lazy-lock.json', '.git/' },
  single_file_support = true,
  settings = {
    Lua = {
      runtime = { version = 'LuaJIT' },
      diagnostics = { globals = { 'vim' } },
      workspace = {
        checkThirdParty = false,
        library = {
          vim.env.VIMRUNTIME,
          '${3rd}/luv/library',
          vim.fn.stdpath('data') .. '/lazy/blink.cmp/lua',
          vim.fn.stdpath('data') .. '/lazy/render-markdown.nvim/lua',
        },
      },
      telemetry = { enable = false },
    },
  },
}
