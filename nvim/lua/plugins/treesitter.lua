return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").install({
        "bash",
        "c",
        "diff",
        "elixir",
        "go",
        "gowork",
        "html",
        "javascript",
        "jsdoc",
        "json",
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
      })

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("ts-start", { clear = true }),
        callback = function(args)
          local buf = args.buf
          local lang = vim.treesitter.language.get_lang(args.match)
          if not lang or not pcall(vim.treesitter.get_parser, buf, lang) then return end

          local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
          if ok and stats and stats.size > 100 * 1024 then return end

          pcall(vim.treesitter.start, buf, lang)
          vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    event = "VeryLazy",
    init = function() vim.g.no_plugin_maps = true end,
    config = function()
      require("nvim-treesitter-textobjects").setup({
        select = { lookahead = true },
        move = { set_jumps = true },
      })

      local sel = require("nvim-treesitter-textobjects.select")
      local mv  = require("nvim-treesitter-textobjects.move")

      -- am/im = function/method, ac/ic = class
      vim.keymap.set({ "x", "o" }, "am", function() sel.select_textobject("@function.outer", "textobjects") end)
      vim.keymap.set({ "x", "o" }, "im", function() sel.select_textobject("@function.inner", "textobjects") end)
      vim.keymap.set({ "x", "o" }, "ac", function() sel.select_textobject("@class.outer", "textobjects") end)
      vim.keymap.set({ "x", "o" }, "ic", function() sel.select_textobject("@class.inner", "textobjects") end)

      -- ]m/[m/]M/[M = function, ]]/[[/][/[] = class
      vim.keymap.set({ "n", "x", "o" }, "]m", function() mv.goto_next_start("@function.outer", "textobjects") end)
      vim.keymap.set({ "n", "x", "o" }, "]M", function() mv.goto_next_end("@function.outer", "textobjects") end)
      vim.keymap.set({ "n", "x", "o" }, "[m", function() mv.goto_previous_start("@function.outer", "textobjects") end)
      vim.keymap.set({ "n", "x", "o" }, "[M", function() mv.goto_previous_end("@function.outer", "textobjects") end)
      vim.keymap.set({ "n", "x", "o" }, "]]", function() mv.goto_next_start("@class.outer", "textobjects") end)
      vim.keymap.set({ "n", "x", "o" }, "][", function() mv.goto_next_end("@class.outer", "textobjects") end)
      vim.keymap.set({ "n", "x", "o" }, "[[", function() mv.goto_previous_start("@class.outer", "textobjects") end)
      vim.keymap.set({ "n", "x", "o" }, "[]", function() mv.goto_previous_end("@class.outer", "textobjects") end)
    end,
  },
  {
    "bezhermoso/tree-sitter-ghostty",
    ft = "ghostty",
    build = function(plugin)
      vim.system({
        "cc", "-o", plugin.dir .. "/ghostty.so",
        "-shared", "-fPIC", "-Os",
        "-I", plugin.dir .. "/src",
        plugin.dir .. "/src/parser.c",
      }):wait()
    end,
    config = function(plugin)
      vim.treesitter.language.add("ghostty", { path = plugin.dir .. "/ghostty.so" })
    end,
  },
}
