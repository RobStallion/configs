return {
  {
    "ibhagwan/fzf-lua",
    enabled = true,
    -- lazy = true,
    -- event = { "VeryLazy" },
    dependencies = {},
    opts = {},
    keys = {
      { "<leader>f.", "<cmd>FzfLua resume<CR>", desc = "Resume last picker" },

      -- Files
      { "<leader>ff", "<cmd>FzfLua files<CR>",    desc = "Find files" },
      { "<leader>fb", "<cmd>FzfLua buffers<CR>",  desc = "Find buffers" },
      { "<leader>fr", "<cmd>FzfLua oldfiles<CR>", desc = "Recent files" },
      {
        "<leader>fc",
        function() require("fzf-lua").files({ cwd = "~/.config/nvim" }) end,
        desc = "Find in nvim config",
      },
      {
        "<leader>fw",
        function() require("fzf-lua").files({ query = vim.fn.expand("<cfile>") }) end,
        desc = "Find file matching word under cursor",
      },

      -- Search
      { "<leader>sg", "<cmd>FzfLua live_grep<CR>",            desc = "Live grep" },
      { "<leader>sw", "<cmd>FzfLua grep_cword<CR>",           desc = "Grep word under cursor" },
      { "<leader>sh", "<cmd>FzfLua helptags<CR>",             desc = "Search help tags" },
      { "<leader>sr", "<cmd>FzfLua lsp_references<CR>",       desc = "LSP references" },
      { "<leader>ss", "<cmd>FzfLua lsp_document_symbols<CR>", desc = "Document symbols" },
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
        grep = {
          -- Include dotfiles and respect .gitignore; mirrors FZF_DEFAULT_COMMAND.
          rg_opts = "--column --line-number --no-heading --color=always --smart-case --max-columns=4096 --hidden --glob=!.git",
        },
      })
    end,
  }
}
