# ADR-006: fzf shell integration

**Date**: 2026-05-09
**Status**: Active

## Context

`fzf` is installed and actively used via the `fzf-lua` nvim plugin for file
picking (`<leader>ff`), live grep (`<leader>sg`), buffers, LSP references, etc.
`FZF_DEFAULT_COMMAND` is set in `fzf.zsh` so fzf-lua's files picker uses
`rg` (respects .gitignore, surfaces hidden files).

Shell-level fzf integration (Ctrl+R for history, Ctrl+T for file insert, Alt+C
for cd) is **implemented** in `zsh/fzf.zsh`. The previous attempt set
`FZF_DEFAULT_OPTS` with a broken `up:preview-up,down:preview-down` binding
that rebound the arrow keys to preview scroll — breaking result navigation. That
was removed and per-binding opts are now set via `FZF_CTRL_R_OPTS` /
`FZF_CTRL_T_OPTS` / `FZF_ALT_C_OPTS` instead of `FZF_DEFAULT_OPTS`, so
fzf-lua is not polluted with shell-specific flags.

## What shell integration provides

- **Ctrl+R** — fuzzy history search (replaces stock prefix-only history search)
- **Ctrl+T** — fuzzy file picker; inserts selected path into the command line
- **Alt+C** — fuzzy cd into subdirectory

These are separate from fzf-lua. Shell integration is loaded via cached
`fzf --zsh` output (same caching pattern as brew/starship/mise).

## Decision

Enable shell integration. Prefix-search via `up-line-or-beginning-search` only
helps when you remember the start of the command — fzf's substring match on
Ctrl+R catches the rest. Ctrl+T and Alt+C are useful in a terminal even with
fzf-lua inside nvim (e.g. `cp <Ctrl+T>`, `cd <Alt+C>`).

Per-binding opts (`FZF_CTRL_R_OPTS` etc.) kept out of `FZF_DEFAULT_OPTS` so
fzf-lua isn't polluted with shell-only flags like preview windows.

`FZF_CTRL_R_OPTS` uses `--no-sort` to preserve reverse-chronological order —
the most recent matching command stays at the top. `--sort` would reorder by
fzf's string-scoring heuristics, which is counterproductive for history search
(especially combined with `--exact`, where all matches are equal-quality hits).

## Consequences

- Ctrl+R is fuzzy substring search over full history, not prefix-only
- Ctrl+T previews files via `bat`; Alt+C previews dirs via `eza --tree`
- `FZF_DEFAULT_OPTS` stays empty so fzf-lua behaviour is unaffected
- Shell start cost avoided via binary-mtime-gated cache
