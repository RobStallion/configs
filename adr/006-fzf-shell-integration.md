# ADR-006: fzf shell integration

**Date**: 2026-05-09
**Status**: Active

## Context

`fzf` is installed and actively used via the `fzf-lua` nvim plugin for file
picking (`<leader>ff`), live grep (`<leader>sg`), buffers, LSP references, etc.
`FZF_DEFAULT_COMMAND` is set in `fzf.zsh` so fzf-lua's files picker uses
`rg` (respects .gitignore, surfaces hidden files).

Shell-level fzf integration (Ctrl+R for history, Ctrl+T for file insert, Alt+C
for cd) is **not currently configured**. The previous `fzf.zsh` attempted to
set `FZF_DEFAULT_OPTS` with a broken `up:preview-up,down:preview-down` binding
that rebound the arrow keys to preview scroll — breaking result navigation. That
was removed.

## What shell integration would provide

- **Ctrl+R** — fuzzy search over shell history (replaces stock zsh history search)
- **Ctrl+T** — fuzzy file picker; inserts selected path into the command line
- **Alt+C** — fuzzy cd into subdirectory

These are separate from fzf-lua. The shell integration is loaded via
`source <(fzf --zsh)` and respects `FZF_DEFAULT_OPTS` for per-binding config.

## Decision

Enable shell integration. Prefix-search via `up-line-or-beginning-search` only
helps when you remember the start of the command — fzf's substring/fuzzy match
on Ctrl+R catches the rest. Ctrl+T and Alt+C are useful in a terminal even with
fzf-lua inside nvim (e.g. `cp <Ctrl+T>`, `cd <Alt+C>`).

Cached `fzf --zsh` to avoid the subprocess on every shell start. Per-binding
opts kept out of `FZF_DEFAULT_OPTS` so fzf-lua isn't polluted with shell-only
flags like preview windows.

## Migration plan (when ready)

1. **Enable shell integration** — add to `zsh/.zshrc` after the modules block:
   ```zsh
   # fzf shell integration — Ctrl+R, Ctrl+T, Alt+C
   source <(fzf --zsh)
   ```
   Or cache it like `brew shellenv` / `starship init` to avoid the subprocess:
   ```zsh
   _fzf_cache="$HOME/.cache/zsh_fzf_init"
   if [[ ! -f "$_fzf_cache" || "$(command -v fzf)" -nt "$_fzf_cache" ]]; then
     fzf --zsh > "$_fzf_cache"
   fi
   source "$_fzf_cache"
   unset _fzf_cache
   ```

2. **Configure per-binding opts** — set opts per command, not globally in
   `FZF_DEFAULT_OPTS` (global opts apply to fzf-lua too):
   ```zsh
   # Ctrl+R — history search: no preview, chronological fallback
   export FZF_CTRL_R_OPTS="--no-preview --sort --exact"

   # Ctrl+T — file picker: bat preview on the right
   export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers {}' --preview-window right:55%"
   export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

   # Alt+C — directory picker: tree preview
   export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --icons=auto {}' --preview-window right:55%"
   ```

3. **Navigation binding** — if adding preview windows, use `ctrl-u`/`ctrl-d`
   to scroll preview (not `up`/`down` — those must navigate results):
   ```zsh
   export FZF_DEFAULT_OPTS="--bind ctrl-u:preview-up,ctrl-d:preview-down"
   ```

## Consequences

- Ctrl+R becomes significantly more useful (fuzzy, not prefix-only)
- Keeps `FZF_DEFAULT_OPTS` lean so fzf-lua isn't polluted with shell-specific opts
- Subprocess on shell start is avoidable via caching (same pattern as brew/starship)
