# ADR-003: bun completions lazy load

**Date**: 2026-05-09 (Updated 2026-06-07)
**Status**: Active

## Context

Bun ships a 938-line zsh completion file. Sourcing it on every shell start
costs ~2ms and loads completions for a tool that's rarely used (not used in 2026 so far).
When bun was globally installed, it lived in `~/.bun/_bun`. With bun managed
via `mise`, there is no default global installation directory, and we don't
want to pollute the home directory with `~/.bun`.

Options considered:
- **Always source**: simple, 2ms cost, completions always available
- **Detect bun project files**: check for `bun.lockb`/`package.json` at shell start — only
  works for the directory you open the shell in, misses projects you cd into later
- **Function wrapper (lazy load)**: define a `bun()` function that loads completions on first
  invocation, then deletes itself and calls the real binary

## Decision

Function wrapper approach. On first `bun` call in a session:
1. The wrapper function removes itself (`unfunction bun`).
2. Invokes the shared `_cached_init` helper (`_cached_init bun completions`) to handle checking the cache, generating the completions if missing or outdated, and sourcing them.
3. Passes all args through to the real binary (`command bun "$@"`).

Every subsequent call hits the binary directly with no overhead.

## Consequences

- Tab completion for `bun` won't work until after the first `bun` command in a session.
- That's acceptable given how rarely bun is used.
- Uses the existing `_cached_init` helper, keeping logic DRY and unified with other tools (mise, fzf, starship, kubectl).
- Automatically handles invalidating and regenerating completions if the `bun` binary is updated/newer than the cache file.
- No custom global `~/.bun` directory or environment variables are needed, keeping the system clean.


