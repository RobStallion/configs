# Candidate Packages

Reference list of plugins considered but not installed. Review when the current setup feels limiting. Sorted roughly by likely value.

## Discoverability

### which-key.nvim
Popup menu that shows available keymaps when you pause on a leader prefix. Zero behavior change if you don't pause — purely additive. Helpful once `<leader>*` bindings grow past ~10.
- Repo: `folke/which-key.nvim`
- Effort: low, ~10 lines of config.

## Navigation & file management

### oil.nvim
Edit your filesystem like a buffer. Open a directory, edit file names in place, save to apply rename/delete/create. Much more ergonomic than a tree view.
- Repo: `stevearc/oil.nvim`
- Alternative to: netrw, nvim-tree.

### mini.files
Same concept as oil but lives inside the `mini.nvim` you already have — zero new deps. Columnar miller-style navigation.
- Enable by adding `require('mini.files').setup()` to `lua/plugins/mini.lua`.
- Effort: 1 line.

### flash.nvim
Label-based motion. Type `s` + two chars, jump anywhere visible. Replaces easymotion/hop. Also enhances `f`/`t`/`/` searches.
- Repo: `folke/flash.nvim`

## Git

### diffview.nvim
Side-by-side git diffs and file history in a single buffer. `:DiffviewOpen` shows working changes, `:DiffviewFileHistory` scrolls through commits for a file.
- Repo: `sindrets/diffview.nvim`
- Pair with gitsigns (already installed) or neogit.

### neogit
Magit-style git UI. Stage/unstage/commit/rebase/push from a dedicated buffer with single-key actions. The heavyweight option — only worth it if you drive git from inside nvim.
- Repo: `NeogitOrg/neogit`
- Alternative: `tpope/vim-fugitive` (older, smaller, command-driven rather than UI-driven).

## Code manipulation

### conform.nvim
Explicit formatter framework. Use when you want to run formatters that aren't tied to an LSP (prettier, stylua, black, shfmt), or want per-filetype formatter chains with fallbacks.
- Repo: `stevearc/conform.nvim`
- Skip unless: you have >2 non-LSP formatters to coordinate.

### nvim-lint
Asynchronous linter runner for tools that aren't LSPs (eslint-d, shellcheck, markdownlint).
- Repo: `mfussenegger/nvim-lint`
- Skip unless: you need a linter with no LSP equivalent.

## Diagnostics UX

### trouble.nvim
Pretty, navigable list of LSP diagnostics, references, symbols, and quickfix entries in a side panel.
- Repo: `folke/trouble.nvim`
- Alternative: `:FzfLua diagnostics_workspace` already covers 80% of this without a new plugin.

## UI

### indent-blankline.nvim
Vertical lines showing indent levels. Useful in Python/YAML-heavy work.
- Repo: `lukas-reineke/indent-blankline.nvim`

### noice.nvim
Replaces the cmdline, messages, and popup with nicer UI. Big visual change. Can feel flashy.
- Repo: `folke/noice.nvim`
- Skip unless: you want a modern cmdline experience.

### nvim-colorizer.lua
Inline color previews for `#ffffff`, `rgb(…)`, and named colors. Useful for CSS/theme work.
- Repo: `NvChad/nvim-colorizer.lua`

## Detection / behavior

### vim-sleuth
Auto-detect `shiftwidth` and `expandtab` from the file you open. Removes the mismatch when editing other people's repos that use tabs or 4-space indents.
- Repo: `tpope/vim-sleuth`
- Effort: install-and-forget.

### mini.pairs
Auto-insert closing brackets/quotes. Already part of `mini.nvim` — commented out in `lua/plugins/mini.lua`. Opinionated; some prefer typing pairs manually.
- Enable: uncomment the line in `mini.lua`.

## Worth knowing about but probably skip

- **nvim-tree / neo-tree** — tree-style file explorers. `fzf-lua files` + oil/mini.files covers this need.
- **telescope** — fuzzy finder. You have fzf-lua, which is faster. Don't run both.
- **lualine** — statusline. You have mini.statusline.
- **bufferline / barbar** — buffer tabs. Generally redundant once you use `:FzfLua buffers`.
- **alpha / dashboard** — startup dashboard. Pure aesthetics.
- **mason.nvim** — LSP/formatter installer. Valuable if you don't want to manage binaries via system package manager. Skippable if you're comfortable with `brew install lua-language-server ruff pyright`.
