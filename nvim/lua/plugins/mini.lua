return {
  "echasnovski/mini.nvim",
  version = "*",
  enabled = true,
  lazy = true,
  event = "BufReadPre",
  config = function()
    require("mini.statusline").setup()
    require("mini.ai").setup()
    require("mini.surround").setup()
    -- require("mini.pairs").setup()
    -- require("mini.operators").setup()
  end
}
