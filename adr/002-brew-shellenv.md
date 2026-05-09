# ADR-002: brew shellenv caching in zprofile

**Date**: 2026-05-09
**Status**: Active

## Context

`brew shellenv` sets up Homebrew's environment: PATH, FPATH, MANPATH, INFOPATH, HOMEBREW_*.
Without it, no brew-installed tool (nvim, rg, bat, fzf, etc.) would be on PATH on Apple Silicon
(Homebrew lives at `/opt/homebrew`, not `/usr/local`).

Original approach was `eval "$(brew shellenv)"` in `.zshrc`. Two problems:
1. Spawns a subprocess every shell start (~34ms)
2. Wrong file — env vars like PATH belong in `.zprofile` (login shell), not `.zshrc`

Options considered:
- **Hardcode the output**: fast, but breaks silently when brew updates its env script
- **Keep eval in .zshrc**: works, but wrong semantic location and 34ms cost
- **Cache + move to .zprofile**: stays dynamic, near-zero cost after first run, correct location

## Decision

Cache `brew shellenv` output to `~/.cache/zsh_brew_env`. Regenerate when `/opt/homebrew/bin/brew`
is newer than the cache file (i.e. after `brew update`). Source the cache in `.zprofile`.

Why `.zprofile`: Ghostty opens login shells, so `.zprofile` runs for every new window.
Child processes (tmux, sub-shells, scripts) inherit the exported env vars — they don't need
to re-source anything.

## Consequences

- Startup cost: ~1ms (file source) instead of ~34ms (subprocess)
- Cache invalidation: automatic on `brew update` via `-nt` file comparison
- If brew ever moves or is reinstalled, delete `~/.cache/zsh_brew_env` to force regeneration
- Sub-shells no longer re-run brew shellenv (correct behaviour — they inherit PATH)
