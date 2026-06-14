local library = {
  vim.env.VIMRUNTIME,
  '${3rd}/luv/library',
}

-- Dynamically add all lazy.nvim plugins to workspace library for autocompletion
local lazy_path = vim.fn.stdpath('data') .. '/lazy'
local ok, list = pcall(vim.fn.readdir, lazy_path)
if ok then
  for _, dir in ipairs(list) do
    table.insert(library, lazy_path .. '/' .. dir .. '/lua')
  end
end

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
        library = library,
      },
      telemetry = { enable = false },
    },
  },
}
