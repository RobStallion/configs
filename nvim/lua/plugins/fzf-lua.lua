return {
  {
    "ibhagwan/fzf-lua",
    enabled = true,
    lazy = true,
    event = { "VeryLazy" },
    dependencies = {},
    opts = {},
    keys = {
      { "<leader>ff", "<cmd>FzfLua files<CR>",          desc = "Find Files in current project" },
      { "<leader>fg", "<cmd>FzfLua live_grep<CR>",      desc = "Live grep in current project" },
      { "<leader>fh", "<cmd>FzfLua helptags<CR>",       desc = "Search help tags" },
      { "<leader>fr", "<cmd>FzfLua lsp_references<CR>", desc = "Search references" },
      {
        "<leader>fs",
        function()
          require("fzf-lua").files({ query = vim.fn.expand("<cfile>") })
        end,
        desc = "Search file under cursor"
      },
      {
        "<leader>en",
        function()
          require("fzf-lua").files({ cwd = '~/.config/nvim' })
        end,
        desc = "Search file under cursor"
      },
    },
  }
}
