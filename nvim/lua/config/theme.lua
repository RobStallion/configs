local function resolve_variant()
  local f = vim.fn.expand("~/.config/ghostty/theme.conf")
  if vim.fn.filereadable(f) == 1 then
    local line = vim.fn.readfile(f)[1] or ""
    local m = line:match("Catppuccin (%a+)")
    local valid = { mocha = true, macchiato = true, frappe = true, latte = true }
    if m and valid[m:lower()] then return m:lower() end
  end
  return "mocha"
end

local ok, variant = pcall(resolve_variant)
if not ok then variant = "mocha" end
vim.cmd.colorscheme("catppuccin-" .. variant)
