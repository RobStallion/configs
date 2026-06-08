# AGENTS.md

This file provides guidance to AI agents (like Claude Code) when working with code in this repository.

## Repo Structure

Personal config files, symlinked to their expected locations:

| Repo path | Symlinked from |
|---|---|
| `nvim/` | `~/.config/nvim` |
| `ghostty/` | `~/.config/ghostty` |
| `zsh/` | `~/.config/zsh` (whole dir) |
| `zsh/.zshrc` | `~/.zshrc` |
| `zsh/.zprofile` | `~/.zprofile` |
| `starship/` | `~/.config/starship` (whole dir) |
| `vim/` | legacy only, not symlinked |
| `.tool-versions` | `~/.tool-versions` |
| `mise/config.toml` | `~/.config/mise/config.toml` |
| `tmux/` | `~/.config/tmux` (whole dir) |
| `git/gitconfig` | `~/.gitconfig` (file symlink) |
| `claude/statusline-command.sh` | `~/.claude/statusline-command.sh` (file symlink) |
| `fd/ignore` | `~/.config/fd/ignore` (file symlink) |
| `theme` | `~/.config/theme` (file symlink, `skip-worktree` — runtime changes don't dirty the repo) |

`claude/statusline/` is a Rust crate that builds the statusline binary invoked by the shell wrapper. Build artifacts in `target/` are gitignored.

## Architecture Decision Records

`adr/` contains numbered ADRs explaining *why* configuration choices were made (e.g., `005-asdf-to-mise.md`). Read the relevant ADR before changing related config. New decisions should follow the format in `adr/README.md`.

## Where to look

Load the relevant doc on demand instead of assuming context from here:
- Working in `nvim/` → `nvim/CONVENTIONS.md` (structure + LSP setup), `nvim/TIPS.md`, `nvim/PACKAGES.md`
- Working in `tmux/` → `tmux/CHEATSHEET.md`
- Working in `zsh/` → `zsh/TIPS.md`

## Invariants

- The nvim config uses native `vim.lsp.config` (Neovim 0.11+), **not** `nvim-lspconfig`. Commands like `:LspInfo`/`:LspStart`/`:LspRestart` from that plugin do not exist here. See `nvim/CONVENTIONS.md`.
- Claude Code is launched via the `c` zsh function (`zsh/claude-wrapper.zsh`), not the raw `claude` binary. `c` enforces `--strict-mcp-config` and attaches MCP servers per-session from `~/.mcp-profiles/` (outside this repo — holds a GitHub PAT). See ADR-007.
- **No autonomous git commits:** Do not run `git commit` or commit files unless the user has explicitly reviewed the changes first and instructed you to commit.
