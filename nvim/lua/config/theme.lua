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

-- Watch ~/.config/theme for changes to hot-reload instantly
local theme_file = vim.fn.expand("~/.config/theme")
local resolved_path = vim.fn.resolve(theme_file)
local watcher = vim.uv.new_fs_event()
if watcher then
  local function start_watch()
    watcher:start(resolved_path, {}, vim.schedule_wrap(function(err, fname, status)
      if not err then
        apply_theme()
      end
      watcher:stop()
      start_watch()
    end))
  end
  start_watch()
end
