return {
  {
    "folke/tokyonight.nvim",
    enabled = true,
    lazy = false,
    priority = 1000,
    config = function()
      -- vim.cmd.colorscheme("tokyonight-night")
      vim.cmd.colorscheme("tokyonight-day")
    end
  },
}
