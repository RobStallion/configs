# ADR-003: bun completions lazy load

**Date**: 2026-05-09
**Status**: Active

## Context

Bun ships a 938-line zsh completion file (`~/.bun/_bun`). Sourcing it on every shell start
costs ~2ms and loads completions for a tool that's rarely used (not used in 2026 so far).

Options considered:
- **Always source**: simple, 2ms cost, completions always available
- **Detect bun project files**: check for `bun.lockb`/`package.json` at shell start — only
  works for the directory you open the shell in, misses projects you cd into later
- **Function wrapper (lazy load)**: define a `bun()` function that loads completions on first
  invocation, then deletes itself and calls the real binary

## Decision

Function wrapper approach. On first `bun` call in a session:
1. The wrapper function removes itself (`unfunction bun`)
2. Loads the completion file
3. Passes all args through to the real binary (`command bun "$@"`)

Every subsequent call hits the binary directly with no overhead.

## Consequences

- Tab completion for `bun` won't work until after the first `bun` command in a session
- That's acceptable given how rarely bun is used
- If bun usage increases, revert to always sourcing (2ms is negligible)
