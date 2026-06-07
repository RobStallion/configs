# Architecture Decision Records

Decisions made in this config repo. Written so future-me remembers the why, not just the what.

## Format

Each file: `NNN-kebab-title.md`

```
# ADR-NNN: Title
**Date**: YYYY-MM-DD
**Status**: Active | Superseded by ADR-NNN | Deprecated

## Context
What situation led to this decision.

## Decision
What was decided.

## Consequences
What's better, what's worse, what to watch out for.
```

## Index

| # | Title | Status |
|---|-------|--------|
| [001](001-oh-my-zsh.md) | oh-my-zsh as zsh framework | Superseded by 004 |
| [002](002-brew-shellenv.md) | brew shellenv caching in zprofile | Active |
| [003](003-bun-completions.md) | bun completions lazy load | Active |
| [004](004-starship.md) | Replace oh-my-zsh with starship + modular zsh | Active |
| [005](005-asdf-to-mise.md) | Migrate from asdf to mise | Active |
| [006](006-fzf-shell-integration.md) | fzf shell integration (Ctrl+R/T, Alt+C) | Active |
| [007](007-claude-mcp-profile-wrapper.md) | Claude Code MCP profile wrapper (`c`) | Active |
