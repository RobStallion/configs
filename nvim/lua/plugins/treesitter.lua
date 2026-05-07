return {
  "nvim-treesitter/nvim-treesitter",
  enabled = true,
  lazy = true,
  event = { "VeryLazy" },
  build = ":TSUpdate",
  dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
  config = function()
    require 'nvim-treesitter.configs'.setup {
      ensure_installed = {
        "bash",
        "c",
        "diff",
        "elixir",
        "html",
        "javascript",
        "jsdoc",
        "json",
        "jsonc",
        "lua",
        "luadoc",
        "luap",
        "markdown",
        "markdown_inline",
        "printf",
        "python",
        "query",
        "regex",
        "sql",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "xml",
        "yaml",
      },
      auto_install = false,
      sync_install = false,
      ignore_install = {},
      modules = {},
      -- disable = { "python" } can be added if treesitter indent misbehaves for a filetype
      indent = { enable = true },
      highlight = {
        enable = true,
        -- to disable slow treesitter highlight for large files
        disable = function(_, buf)
          local max_filesize = 100 * 1024 -- 100 KB
          local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
          if ok and stats and stats.size > max_filesize then
            return true
          end
        end,
        additional_vim_regex_highlighting = false,
      },
      textobjects = {
        -- am/im = function/method definition (af/if kept for mini.ai function calls)
        -- ac/ic = class
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ["am"] = "@function.outer",
            ["im"] = "@function.inner",
            ["ac"] = "@class.outer",
            ["ic"] = "@class.inner",
          },
        },
        move = {
          enable = true,
          goto_next_start     = { ["]m"] = "@function.outer", ["]]"] = "@class.outer" },
          goto_next_end       = { ["]M"] = "@function.outer", ["]["] = "@class.outer" },
          goto_previous_start = { ["[m"] = "@function.outer", ["[["] = "@class.outer" },
          goto_previous_end   = { ["[M"] = "@function.outer", ["[]"] = "@class.outer" },
        },
      },
    }
  end
}
