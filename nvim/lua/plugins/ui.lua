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
      vim.cmd.colorscheme("catppuccin-mocha")
      -- vim.cmd.colorscheme("catppuccin-macchiato")
      -- vim.cmd.colorscheme("catppuccin-frappe")
      vim.cmd.colorscheme("catppuccin-latte")
    end
  },
}
