return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    -- registers the prefix labels shown in the popup
    spec = {
      { "<leader>f", group = "files" },
      { "<leader>s", group = "search" },
      { "<leader>y", group = "yank" },
      { "<leader>l", group = "lua" },
      { "<leader>r", group = "run" },
      { "<leader>h", group = "hunks" },
    },
  },
}
