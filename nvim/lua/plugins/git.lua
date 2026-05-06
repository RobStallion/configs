return {
  "lewis6991/gitsigns.nvim",
  enabled = true,
  lazy = true,
  event = "BufReadPre",
  config = function()
    require('gitsigns').setup()
  end

}
