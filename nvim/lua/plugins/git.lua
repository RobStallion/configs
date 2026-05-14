return {
  "lewis6991/gitsigns.nvim",
  lazy = true,
  event = "BufReadPre",
  config = function()
    require('gitsigns').setup({
      current_line_blame = true,
      current_line_blame_opts = {
        delay = 250,
      },
      on_attach = function(bufnr)
        local gs = require('gitsigns')
        local map = function(mode, l, r, opts)
          vim.keymap.set(mode, l, r, vim.tbl_extend('force', { buffer = bufnr }, opts or {}))
        end

        -- Hunk navigation (respects vim diff mode)
        map('n', ']c', function()
          if vim.wo.diff then return ']c' end
          vim.schedule(gs.next_hunk)
          return '<Ignore>'
        end, { expr = true, desc = 'Next hunk' })

        map('n', '[c', function()
          if vim.wo.diff then return '[c' end
          vim.schedule(gs.prev_hunk)
          return '<Ignore>'
        end, { expr = true, desc = 'Prev hunk' })

        map('n', '<leader>hs', gs.stage_hunk,                { desc = 'Stage hunk' })
        map('n', '<leader>hr', gs.reset_hunk,                { desc = 'Reset hunk' })
        map('n', '<leader>hp', gs.preview_hunk,              { desc = 'Preview hunk' })
        map('n', '<leader>hb', gs.blame_line,                { desc = 'Blame line' })
        map('n', '<leader>hB', gs.toggle_current_line_blame, { desc = 'Toggle inline blame' })
      end,
    })
  end,
}
