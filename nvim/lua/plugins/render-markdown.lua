return {
  "MeanderingProgrammer/render-markdown.nvim",
  ft = { "markdown" },
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  ---@module 'render-markdown'
  ---@type render.md.UserConfig
  opts = {
    heading = {
      sign = false,
      icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
    },
    code = {
      width = "block",
      right_pad = 4,
    },
    checkbox = {
      enabled = true,
      unchecked = { icon = '󰄱 ' },
      checked = { icon = '󰄵 ' },
    },
    pipe_table = {
      preset = "round",
    },
    winopts = {
      conceallevel = {
        default = 2,
        rendered = 2,
      },
    },
    anti_conceal = {
      enabled = true,
    },
  },
}
