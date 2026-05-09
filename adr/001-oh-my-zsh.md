# ADR-001: oh-my-zsh as zsh framework

**Date**: 2026-05-09
**Status**: Superseded by [ADR-004](004-starship.md)

## Context

Been using oh-my-zsh for ~9 years as a reflex. Profiling showed it adds ~131ms to shell startup
(total startup ~167ms). That's acceptable but worth documenting what it's actually providing
so the decision to keep or replace is informed.

## What oh-my-zsh actually provides

- **Prompt**: `robbyrussell` theme — shows current dir + git branch + arrow
- **Git aliases**: `gst`, `gco`, `gcb`, `gp`, `ggpull`, `gaa`, `gc`, and ~80 more
- **Directory navigation**: `..`, `...`, `....` etc. (just `cd ..` aliases)
- **Completion system**: initialises zsh's `compinit` with caching
- **Plugin ecosystem**: one-line activation of plugins like zsh-autosuggestions

Known used: `..`, `ggpull`.

## Decision

Keep oh-my-zsh. 131ms is acceptable, migration cost isn't worth it right now.
If startup ever feels slow again, the migration path is:
- `starship` for the prompt (~10ms, shows git branch)
- Copy the ~8 git aliases actually used from `~/.oh-my-zsh/plugins/git/git.plugin.zsh`
- `autoload -Uz compinit && compinit` for tab completion (2 lines)
- That's it — everything else is unused

## Consequences

- Shell startup: ~131ms for OMZ. Acceptable.
- Framework overhead: OMZ owns the completion system init, meaning plugin ordering matters if new plugins are added
- Migration note: if moving to starship, disable `ZSH_THEME` in `.zshrc` (setting it empty disables the theme without breaking OMZ)
