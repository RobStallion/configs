return {
  {
    "ibhagwan/fzf-lua",
    enabled = true,
    -- lazy = true,
    -- event = { "VeryLazy" },
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
        desc = "Search nvim config"
      },
    },
    config = function()
      require('fzf-lua').setup({
        winopts = {
          height = 0.5,      -- Adjust height as needed
          width = 1.0,       -- Full width
          row = 1.0,         -- Anchor to bottom (1.0 = bottom of screen)
          col = 0.5,         -- Center horizontally
          border = 'single', -- Optional: matches Telescope ivy's look
        },
        fzf_opts = {
          ['--layout'] = 'reverse', -- Matches ivy's bottom-up style
        },
      })
    end,
  }
}
