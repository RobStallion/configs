# Conventions

How this nvim config is structured and why. Read before making structural changes.

## LSP: native `vim.lsp.config`, NOT nvim-lspconfig

This config uses the Neovim 0.11+ native LSP API. **`nvim-lspconfig` is not installed and is not planned.**

### What this means in practice

- Server configs live in `lsp/<name>.lua` and return a config table (cmd, filetypes, root_markers, settings, handlers).
- Neovim 0.11+ auto-loads any `lsp/*.lua` file under `runtimepath`. The file's basename becomes the server name.
- `init.lua` activates servers with `vim.lsp.enable({...})`. To add a new server: drop a `lsp/<name>.lua` file and add the name to the `vim.lsp.enable` list.

### Commands from nvim-lspconfig that DO NOT exist here

- `:LspInfo` — use `:checkhealth vim.lsp` or `:lua =vim.lsp.get_clients({ bufnr = 0 })`
- `:LspStart` / `:LspStop` — use `vim.lsp.enable`/`vim.lsp.stop_client()`
- `:LspRestart` — does not exist. The user has `:LspReload` (defined in `lua/config/usercmds.lua`) which re-reads `lsp/<name>.lua` from disk *and* reattaches clients for the current buffer — use that when iterating on LSP config. For a generic detach without config reload, use `vim.lsp.stop_client(id)` + `:edit`.
- `:LspLog` (an `nvim-lspconfig` command) — does not exist in native LSP. Use `:lua vim.cmd.edit(vim.lsp.get_log_path())` to view server logs.

### Useful native commands

| Need | Command |
|---|---|
| Which LSP is attached to this buffer? | `:=vim.tbl_map(function(c) return c.name end, vim.lsp.get_clients({bufnr=0}))` |
| Full client details for current buffer | `:lua =vim.lsp.get_clients({ bufnr = 0 })` |
| All active LSP clients | `:lua =vim.lsp.get_clients()` |
| LSP health | `:checkhealth vim.lsp` |
| Server logs | `:lua vim.cmd.edit(vim.lsp.get_log_path())` |
| Stop a specific client | `:lua vim.lsp.stop_client(<id>)` |

### Why native instead of nvim-lspconfig

- 7 servers, all already configured — the lspconfig "server database" benefit is front-loaded and already paid.
- Custom handlers (see `lsp/vtsls.lua`'s diagnostic filter) read more cleanly without a wrapping layer.
- Native is the direction Neovim core is moving; lspconfig has become a compatibility/database layer over it.

## JS/TS LSP routing

- `vtsls` handles Node/TS projects (requires `package.json`/`tsconfig.json`/`jsconfig.json` — `workspace_required = true`).
- `deno` handles orphan JS/TS files outside any project.
- This split is intentional and was considered against alternatives. Do not propose collapsing it without surfacing the trade-off first.

## Directory layout

```
nvim/
├── init.lua              # entry: requires config/*, vim.diagnostic.config, vim.lsp.enable
├── lua/
│   ├── config/           # configuration modules (sourced from init.lua)
│   │   ├── lazy.lua      # lazy.nvim bootstrap + spec loader
│   │   ├── options.lua   # vim.opt.* settings
│   │   ├── keymaps.lua   # global keymaps
│   │   ├── autocmds.lua  # autocommand groups
│   │   ├── usercmds.lua  # custom :commands (incl. :LspReload — reloads lsp/<name>.lua and reattaches)
│   │   └── filetypes.lua # filetype detection overrides
│   └── plugins/          # one file per plugin (lazy.nvim spec format)
├── lsp/                  # one file per LSP server (Neovim 0.11+ autoload)
├── lazy-lock.json        # pinned plugin versions (commit changes)
└── TIPS.md / PACKAGES.md # reference docs, not loaded by nvim
```

### Conventions

- **One file per plugin** in `lua/plugins/`. Filename is the conventional plugin name (e.g. `fzf-lua.lua`, `blink.lua`). The file returns a lazy.nvim spec table.
- **One file per LSP server** in `lsp/`. Filename matches the server name registered with `vim.lsp.enable`.
- **No `mason.nvim`.** LSP binaries are installed via system package manager / mise. See `mise/config.toml` and `.tool-versions`.
- **No `nvim-cmp`.** Completion is `blink.cmp` (see `lua/plugins/blink.lua`).
- **No `telescope`.** Fuzzy finder is `fzf-lua` (see `lua/plugins/fzf-lua.lua`).
- **No statusline plugin.** `mini.statusline` (from `mini.nvim`) handles it — see `lua/plugins/mini.lua`.

If you're tempted to add a plugin already covered by one of the above, check `PACKAGES.md` first — many "alternative" plugins are explicitly listed there as considered-and-skipped with reasons.
