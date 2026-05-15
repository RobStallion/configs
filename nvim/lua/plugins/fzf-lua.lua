return {
  {
    "ibhagwan/fzf-lua",
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
        function() require("fzf-lua").files({ query = vim.fn.expand("<cword>") }) end,
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
          height = 0.5,
          width = 1.0,
          row = 1.0,
          col = 0.5,
          border = 'single',
        },
        fzf_opts = {
          ['--layout'] = 'reverse',
        },
        files = {
          fd_opts = "--color=never --type f --hidden --follow --exclude .git --no-ignore-vcs",
        },
        grep = {
          rg_opts = "--column --line-number --no-heading --color=always --smart-case --max-columns=4096 --hidden --glob=!.git",
        },
      })
    end,
  }
}
