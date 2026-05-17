-- Deno LSP handles orphan JS/TS files (no surrounding Node project) and any
-- file inside a real Deno project (deno.json/deno.jsonc).
--
-- Routing rules (see root_dir below):
--   1. deno.json/deno.jsonc found upward     -> attach as Deno project
--   2. Node project markers found upward     -> bail; ts_ls owns it
--   3. Neither found (true orphan)           -> attach single-file
return {
  cmd = { "deno", "lsp" },
  filetypes = {
    "javascript",
    "javascriptreact",
    "javascript.jsx",
    "typescript",
    "typescriptreact",
    "typescript.tsx",
  },
  root_dir = function(bufnr, on_dir)
    local fname = vim.api.nvim_buf_get_name(bufnr)
    if fname == "" then return end

    local deno_root = vim.fs.root(fname, { "deno.json", "deno.jsonc" })
    if deno_root then
      on_dir(deno_root)
      return
    end

    local node_root = vim.fs.root(fname, { "package.json", "tsconfig.json", "jsconfig.json" })
    if node_root then
      return
    end

    on_dir(vim.fs.dirname(fname))
  end,
  settings = {
    deno = {
      enable = true,
      lint = true,
      suggest = {
        imports = {
          hosts = {
            ["https://deno.land"] = true,
            ["https://jsr.io"] = true,
          },
        },
      },
    },
  },
}
