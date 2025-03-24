-- Telescope for fuzzy finding
return {
  'nvim-telescope/telescope.nvim',
  tag = '0.1.8',
  enabled = true,
  dependencies = {
    'nvim-lua/plenary.nvim',
    -- 'BurntSushi/ripgrep',
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
  },
  config = function()
    local telescope = require('telescope')
    telescope.load_extension('fzf')

    telescope.setup {
      pickers = {
        find_files = {
          theme = "ivy",
        }
      },

      extensions = {
        fzf = {}
      }
    }

    local builtin = require('telescope.builtin')
    vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Search help docs' })
    vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Search in current project' })
    vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Live grep' })
    vim.keymap.set('n', '<leader>fr', builtin.lsp_references, { desc = 'Search references' })
    vim.keymap.set('n', '<leader>fn', function()
      builtin.find_files { cwd = vim.fn.stdpath('config') }
    end, { desc = 'Search in Neovim config' })

    -- vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Find buffers' })
  end
}
