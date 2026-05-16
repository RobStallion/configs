return {
  {
    "folke/tokyonight.nvim",
    enabled = false,
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("tokyonight-moon")
      -- vim.cmd.colorscheme("tokyonight-storm")
      -- vim.cmd.colorscheme("tokyonight-night")
      -- vim.cmd.colorscheme("tokyonight-day")
    end
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    enabled = true,
    lazy = false,
    priority = 1000,
    config = function()
      -- Reads active variant from theme.conf; single-theme syntax only (not "light:X,dark:Y").
      -- Use the `theme` shell function to switch; theme.conf is gitignored.
      local variant = "mocha"
      pcall(function()
        local f = vim.fn.expand("~/.config/ghostty/theme.conf")
        if vim.fn.filereadable(f) == 1 then
          local line = vim.fn.readfile(f)[1] or ""
          local m = line:match("Catppuccin (%a+)")
          local valid = { mocha = true, macchiato = true, frappe = true, latte = true }
          if m and valid[m:lower()] then variant = m:lower() end
        end
      end)
      vim.cmd.colorscheme("catppuccin-" .. variant)
    end
  },
}
