# ADR-004: Replace oh-my-zsh with starship + modular zsh files

**Date**: 2026-05-09
**Status**: Active
**Supersedes**: [ADR-001](001-oh-my-zsh.md)

## Context

oh-my-zsh added ~131ms to shell startup. After auditing what it actually provides,
the full feature set maps directly to standalone replacements — nothing requires the
framework:

| OMZ feature | Replacement |
|---|---|
| `robbyrussell` prompt | starship with equivalent config |
| git aliases | `zsh/git-aliases.zsh` (already extracted, ADR-001 migration path) |
| `..`, `...` navigation | `zsh/options.zsh` |
| `compinit` + caching | `zsh/completions.zsh` |
| history options | `zsh/options.zsh` |
| key bindings | `zsh/keybindings.zsh` |

## Decision

Remove oh-my-zsh. Replace with:

- **starship** (~10ms prompt, configured in `starship/starship.toml`)
- Four modular zsh files sourced from `.zshrc`:
  - `options.zsh` — history, directory, misc setopts + nav aliases
  - `completions.zsh` — compinit, zstyle settings
  - `keybindings.zsh` — bindkey setup
  - `git-aliases.zsh` — git helper functions + ~50 aliases (extracted in previous session)

Modular structure chosen so each piece can be commented out independently for testing.

## Consequences

- Shell startup target: <30ms (down from ~167ms)
- Tab completion works from first shell open (unlike bun lazy-load — completions.zsh
  can be commented out to test if features are missed)
- No plugin ecosystem, but the only OMZ plugin in use was `git` (now replaced by
  `git-aliases.zsh`)
- starship reads `.git/` on every prompt — negligible cost (~5ms), no process spawn
