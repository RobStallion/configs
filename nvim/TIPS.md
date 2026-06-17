# Tips

Reference for getting more out of the current setup before adding plugins.

## Built-in Neovim (0.11+)

### LSP defaults (no config needed)

- `K` — hover docs
- `grn` — rename symbol
- `gra` — code action
- `grr` — find references
- `gri` — go to implementation
- `gO` — document symbols
- `<C-s>` (insert mode) — signature help
- `]d` / `[d` — next/prev diagnostic
- `<C-w>d` — open diagnostic float for current line

### Other built-ins people miss

- `gx` — open URL under cursor in browser
- `gf` — go to file under cursor (respects `path` option)
- `gd` / `gD` — local / global declaration (LSP overrides to definition)
- `Q` — replay last recorded macro (faster than `@@`)
- `g;` / `g,` — jump backward/forward through change list
- `<C-o>` / `<C-i>` — jump backward/forward through jump list
- `'.'` — repeat last change (operator + motion)
- `ciw` / `daw` / `yi"` — text objects chain with every operator
- `:InspectTree` — open treesitter AST viewer for current buffer
- `:Inspect` — show syntax and highlight groups at cursor
- Format file/selection with `<leader>=` (normal = whole file, visual = range).
  This uses the custom formatter (`lua/config/formatter.lua`) which has special
  handling for JSON (via `jq`) and Markdown (via rumdl with reflow) before
  falling back to LSP. The raw `vim.lsp.buf.format` builtin is still available
  directly.

### Spell checking (enabled on markdown, gitcommit, text)

- `<C-n>` / `<C-p>` (or `]s` / `[s`) — jump to next/prev spelling error
- `z=` — show spelling suggestions for word under cursor
- `zg` — add word under cursor to dictionary (whitelist permanently)
- `zG` — add word to temporary dictionary (current session only)
- `zug` — undo adding word to dictionary

## mini.nvim modules you have

### mini.ai — extended text objects

- `vaf` / `vif` — select around / inside function
- `vac` / `vic` — around / inside class
- `va)` / `vi)` — around / inside parentheses (next/last)
- `a)` / `i)` accept a count: `v2a)` selects 2 levels out
- Works with any operator: `daf` delete whole function, `yi{` yank inside braces

### mini.surround — surround edits

- `sa{motion}{char}` — add surround (e.g. `saiw"` wraps word in quotes)
- `sd{char}` — delete surround (e.g. `sd"` removes surrounding quotes)
- `sr{old}{new}` — replace surround (e.g. `sr"'` changes `"` to `'`)
- `sf` / `sF` — find next/prev surround
- `sh` — highlight surround

### mini.statusline

- Already displays mode, git, diagnostics, filename, location. No config needed.

## blink.cmp (completion)

Default preset keymaps while the menu is open:

- `<C-space>` — trigger completion
- `<C-n>` / `<C-p>` or `<Down>` / `<Up>` — navigate items
- `<C-y>` — accept
- `<C-e>` — cancel
- `<Tab>` / `<S-Tab>` — snippet forward/backward when in snippet
- `<C-k>` — toggle signature help

Docs popup only shows when manually triggered — bind `<C-d>` / `<C-f>` if you
want to scroll docs.

## fzf-lua pickers worth knowing

Beyond the ones already bound:

- `:FzfLua resume` — re-open last picker with its query (great after you close
  one by accident)
- `:FzfLua buffers` — switch buffers
- `:FzfLua diagnostics_document` — fuzzy through current file's diagnostics
- `:FzfLua diagnostics_workspace` — workspace-wide
- `:FzfLua commands` — search `:` commands
- `:FzfLua keymaps` — search all your keymaps (useful when you forget one)
- `:FzfLua git_status` — staged/unstaged picker
- `:FzfLua git_branches` — checkout branches
- `:FzfLua lsp_document_symbols` — outline view
- `:FzfLua lsp_workspace_symbols` — project-wide symbol search

Inside any picker: `<C-q>` sends results to quickfix.

## gitsigns (already loaded)

Default mappings (check `:h gitsigns-maps`):

- `]c` / `[c` — next/prev hunk
- `:Gitsigns preview_hunk` — floating preview
- `:Gitsigns stage_hunk` / `reset_hunk` — stage or reset under cursor
- `:Gitsigns blame_line` — inline blame for current line
- `:Gitsigns toggle_current_line_blame` — persistent inline blame

Worth binding: `<leader>hs` (stage), `<leader>hr` (reset), `<leader>hp`
(preview), `<leader>hb` (blame).

## treesitter

- `:TSUpdate` — update parsers
- `:TSPlayground` (if installed) or `:InspectTree` — AST viewer
- Queries live in `runtime/queries/<lang>/*.scm` — override in
  `~/.config/nvim/queries/<lang>/`

## Lazy.nvim

- `:Lazy` — dashboard
- `:Lazy sync` — install + update + clean
- `:Lazy profile` — startup profiling, find slow plugins
- `:Lazy log` — recent plugin commits
- `:Lazy restore` — roll back to lazy-lock.json state

## Health checks

- `:checkhealth` — run all
- `:checkhealth lsp` / `vim.lsp` — LSP diagnostics
- `:checkhealth nvim-treesitter` — parser status

## Quickfix / location list

- `:copen` / `:cclose` — toggle quickfix window
- `:cnext` / `:cprev` or `]q` / `[q` (with unimpaired-style binding) — navigate
- `:cdo {cmd}` — run command on each quickfix entry (bulk refactor)
- `:cfdo {cmd}` — run command per file in quickfix
- After fzf picker: `<C-q>` → quickfix, then `:cdo s/foo/bar/g | update`

## Registers

- `"ayy` — yank line into register `a`
- `"ap` — paste from register `a`
- `:reg` — view all registers
- `"+` — system clipboard (already default via `unnamedplus`)
- `"0` — last yank (survives delete commands overwriting `""`)
- `:let @a = @b` — copy register to register

## Marks

- `ma` — set mark `a` (lowercase = buffer-local, uppercase = global across
  files)
- `'a` / `` `a `` — jump to mark (line / exact position)
- `:marks` — list marks
- `` `. `` — last change, `` `^ `` — last insert position

## Diff mode

- `:diffthis` in two windows — start a diff
- `]c` / `[c` — next/prev diff hunk (already covered by gitsigns for git)
- `do` / `dp` — diff obtain / diff put

## Command-line editing

- `q:` — open command history in a buffer (editable, `<CR>` to run)
- `q/` — same for search history
- `<C-f>` in `:` — open cmdline window
