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
    local builtin = require('telescope.builtin')
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

    vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Search help docs' })
    vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Search in current project' })
    vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Live grep' })
    vim.keymap.set('n', '<leader>fr', builtin.lsp_references, { desc = 'Search references' })

    vim.keymap.set('n', '<leader>fn', function()
      builtin.find_files({
        cwd = vim.fn.stdpath('config')
      })
    end, { desc = 'Search in Neovim config' })

    telescope.setup {
      defaults = {
        mappings = {
          i = {
            ["<CR>"] = function(prompt_bufnr)
              local state = require('telescope.actions.state')
              local picker = state.get_current_picker(prompt_bufnr)
              local cwd = picker.cwd or vim.fn.getcwd() -- Fallback to current dir if cwd not set
              local selections = picker:get_multi_selection()

              -- If no multi-selections, fall back to the current single selection
              if #selections == 0 then
                local single_selection = state.get_selected_entry()
                if single_selection then
                  table.insert(selections, single_selection)
                end
              end

              -- Close Telescope
              require('telescope.actions').close(prompt_bufnr)

              -- Get the absolute path of the picker's cwd (Neovim config directory)

              -- If there are selections, replace the current buffer with the first file
              if #selections > 0 then
                -- Construct the full path for the first file
                local first_file = cwd .. '/' .. selections[1][1]
                vim.cmd('edit ' .. vim.fn.fnameescape(first_file))
                -- Remove the first selection since it's already open
                table.remove(selections, 1)
              end

              -- Open remaining selected files in vertical splits
              for _, entry in ipairs(selections) do
                if entry and entry[1] then
                  -- Construct the full path for each subsequent file
                  local full_path = cwd .. '/' .. entry[1]
                  vim.cmd('vsplit ' .. vim.fn.fnameescape(full_path))
                end
              end
            end,
          },
        },
      },
    }

    -- vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Find buffers' })
  end
}
