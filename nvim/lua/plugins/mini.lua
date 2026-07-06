return {
  "echasnovski/mini.nvim",
  version = "*",
  enabled = true,
  lazy = true,
  event = "BufReadPre",
  config = function()
    require("mini.statusline").setup({
      content = {
        active = function()
          local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
          local diagnostics   = MiniStatusline.section_diagnostics({ trunc_width = 75 })
          local filename      = MiniStatusline.section_filename({ trunc_width = 140 })
          local fileinfo      = MiniStatusline.section_fileinfo({ trunc_width = 120 })
          local location      = MiniStatusline.section_location({ trunc_width = 75 })

          return MiniStatusline.combine_groups({
            { hl = mode_hl,                 strings = { mode } },
            { hl = "MiniStatuslineDevinfo", strings = { diagnostics } },
            "%<",
            { hl = "MiniStatuslineFilename", strings = { filename } },
            "%=",
            { hl = "MiniStatuslineFileinfo", strings = { fileinfo } },
            { hl = mode_hl,                  strings = { location } },
          })
        end,
      },
    })
    require("mini.ai").setup()
    require("mini.surround").setup()
    require("mini.pairs").setup()
    require("mini.icons").setup()
    require("mini.files").setup({
      mappings = {
        go_in_plus = '<CR>',
      },
    })

    local map_split = function(buf_id, lhs, direction)
      local rhs = function()
        -- Get current entry under cursor
        local entry = MiniFiles.get_fs_entry()
        if not entry or entry.fs_type ~= 'file' then
          -- If not a file (e.g. a directory), just do normal navigation
          MiniFiles.go_in()
          return
        end

        -- If it is a file, split and open
        local cur_target = MiniFiles.get_explorer_state().target_window
        local new_target = vim.api.nvim_win_call(cur_target, function()
          vim.cmd(direction)
          return vim.api.nvim_get_current_win()
        end)

        MiniFiles.set_target_window(new_target)
        MiniFiles.go_in()
      end

      vim.keymap.set('n', lhs, rhs, { buffer = buf_id, desc = 'Split ' .. direction })
    end

    vim.api.nvim_create_autocmd('User', {
      pattern = 'MiniFilesBufferCreate',
      callback = function(args)
        local buf_id = args.data.buf_id
        map_split(buf_id, 'gs', 'split')
        map_split(buf_id, 'gv', 'vsplit')
      end,
    })

    -- require("mini.operators").setup()
  end
}
