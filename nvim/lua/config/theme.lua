local function resolve_variant()
  local variant = "mocha"
  local f = vim.fn.expand("~/.config/ghostty/theme.conf")
  local ok, lines = pcall(vim.fn.readfile, f)
  if ok then
    local m = (lines[1] or ""):match("Catppuccin (%a+)")
    local valid = { mocha = true, macchiato = true, frappe = true, latte = true }
    if m and valid[m:lower()] then variant = m:lower() end
  end
  return variant
end

vim.cmd.colorscheme("catppuccin-" .. resolve_variant())
