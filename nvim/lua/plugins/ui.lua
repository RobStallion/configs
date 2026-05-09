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
      vim.cmd.colorscheme("catppuccin-mocha") -- # Darkest
      -- vim.cmd.colorscheme("catppuccin-macchiato")  -- # Medium contrast
      -- vim.cmd.colorscheme("catppuccin-frappe")     -- # Less vibrant
      -- vim.cmd.colorscheme("catppuccin-latte")      -- # Light
    end
  },
}
