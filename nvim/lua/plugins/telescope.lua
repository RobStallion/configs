-- Telescope for fuzzy finding
return {
  'nvim-telescope/telescope.nvim',
  tag = '0.1.8',
  enabled = false,
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons',
    'BurntSushi/ripgrep',
  },
  config = function()
    local builtin = require('telescope.builtin')
    -- Set up key mappings for Telescope
    vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Find files' })
    vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Live grep' })
    vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Find buffers' })
  end
}
