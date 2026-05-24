local function resolve_theme()
  local f = vim.fn.expand("~/.config/theme")
  local ok, lines = pcall(vim.fn.readfile, f)
  if ok and lines[1] and lines[1] ~= "" then
    return lines[1]
  end
  return "catppuccin-mocha"
end

local function apply_theme()
  if vim.g.fixed_colorscheme then return end
  local theme = resolve_theme()
  if vim.g.colors_name ~= theme then
    vim.cmd.colorscheme(theme)
  end
end

apply_theme()

vim.api.nvim_create_autocmd("FocusGained", {
  group = vim.api.nvim_create_augroup("ThemeReload", { clear = true }),
  callback = apply_theme,
})
