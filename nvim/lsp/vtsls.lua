-- noImplicitAny-family diagnostics. checkJs surfaces these in .js files where
-- they're usually just noise, but we still want to keep real type errors like
-- TS2304 "Cannot find name 'fs'".
local implicit_any_codes = {
  [7005] = true,
  [7006] = true,
  [7008] = true,
  [7010] = true,
  [7011] = true,
  [7019] = true,
  [7031] = true,
  [7034] = true,
  [7044] = true,
}

local js_filetypes = {
  ["javascript"] = true,
  ["javascriptreact"] = true,
  ["javascript.jsx"] = true,
}

local default_publish_diagnostics = vim.lsp.handlers["textDocument/publishDiagnostics"]

-- Point vtsls at the mise-managed global TypeScript install. Used as a
-- fallback for projects that don't ship their own `typescript` devDep
-- (vtsls otherwise can't find tsserver in those projects). `tsdk` wants the
-- directory containing tsserver.js, not the file itself.
local tsserver_bin = vim.fn.exepath("tsserver")
local tsdk = nil
if tsserver_bin ~= "" then
  tsdk = vim.fn.fnamemodify(vim.fn.resolve(tsserver_bin), ":h:h") .. "/lib"
end

-- vtsls only claims files inside real Node/TS projects (package.json,
-- tsconfig.json, jsconfig.json). Orphan JS/TS files are handled by deno LSP.
return {
  cmd = { "vtsls", "--stdio" },
  filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx" },
  root_markers = { "tsconfig.json", "jsconfig.json", "package.json" },
  workspace_required = true,
  settings = {
    typescript = {
      tsdk = tsdk,
      implicitProjectConfig = {
        checkJs = true,
      },
    },
    javascript = {
      implicitProjectConfig = {
        checkJs = true,
      },
    },
  },
  handlers = {
    ["textDocument/publishDiagnostics"] = function(err, result, ctx, config)
      if result and result.diagnostics and result.uri then
        local bufnr = vim.uri_to_bufnr(result.uri)
        if js_filetypes[vim.bo[bufnr].filetype] then
          result.diagnostics = vim.tbl_filter(function(d)
            return not implicit_any_codes[tonumber(d.code)]
          end, result.diagnostics)
        end
      end
      return default_publish_diagnostics(err, result, ctx, config)
    end,
  },
}
