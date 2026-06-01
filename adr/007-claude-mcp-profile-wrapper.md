# ADR-007: Claude Code MCP profile wrapper (`c`)

**Date**: 2026-06-01
**Status**: Active

## Context

Claude Code is launched via a LiteLLM-routed setup. LiteLLM strips Claude Code's
native **Tool Search Tool**, the mechanism that normally defers MCP tool-schema
loading until the model asks for a tool. Without it, every configured MCP
server's full JSON-RPC tool schema is dumped into the system prompt at session
start — pre-loading tooling for servers the session will never touch and
torching the context window before the first user prompt is typed.

The setup had six MCP servers configured (Linear, Notion, BigQuery, GitHub,
Chrome DevTools, and Slack via the slack plugin). Five were removed from
`~/.claude.json` as an emergency cull, leaving only `linear` — but the only
sustainable model is opt-in per session.

The previous launcher was `alias c="claude"` in `zsh/aliases.zsh` — a thin
wrapper that inherited all ambient MCP and plugin state.

## Decision

Replace the alias with a `c` zsh function (`zsh/claude-wrapper.zsh`) that:

1. Starts from an empty `{"mcpServers": {}}` base.
2. For each bare-word arg, looks up `~/.mcp-profiles/<arg>.json` and merges its
   `mcpServers` block in via `jq -s '.[0] * .[1]'`. Unknown names error out
   loudly — typos must not silently launch with the wrong config.
3. Passes the merged temp config to `claude --mcp-config <tmp>
   --strict-mcp-config`. Strict mode is what makes the gating real: it blocks
   `~/.claude.json` *and* plugin-bundled `.mcp.json` files from leaking back in.
4. Forwards any `-flag` args (e.g. `--resume`) untouched.
5. Cleans up the temp file via `trap … EXIT INT TERM HUP`.

Profile files live in `~/.mcp-profiles/` — **outside this repo**, because
`github.json` holds a Personal Access Token and even mode-600 secrets don't
belong in a public git history. The dir is `chmod 700`, files `chmod 600`. A
sibling `README.md` documents the contents.

### Why scoped to MCP servers only

Plugins are a separate axis with their own per-plugin cost. The current plugin
set (caveman, pyright-lsp, gopls-lsp, slack) totals only ~833 always-on tokens
per `claude plugin details`, and three of those four are either deliberate
(caveman) or essentially free (out-of-process LSPs at ~0 tokens). Adding plugin
gating to the wrapper would muddy a clean single-purpose tool for ~213 tokens of
saving (slack plugin) — not worth the complexity.

### Why a function, not a script

Used dozens of times daily. In-shell function = zero exec overhead. `command
claude` prevents the function recursing into itself.

### Slack's split treatment

The slack plugin bundles a slack MCP server. Because `--strict-mcp-config`
ignores plugin-bundled MCPs, the slack plugin's 7 skill stubs stay loaded
globally (they're cheap), but the actual MCP server only attaches when you run
`c slack`. So slack appears in the profile set even though the plugin stays
enabled — a deliberate split.

## Consequences

- Raw `claude` still works but loads ambient MCPs from `~/.claude.json`. `c` is
  the sanctioned entry point.
- Profile files require manual edit when MCP endpoints change. The trade-off
  for not having a central registry.
- First-run OAuth may re-prompt for linear/slack/notion if cache keying assumes
  ambient config — accept one-time browser flow.
- GitHub PAT lives in plaintext at `~/.mcp-profiles/github.json` (mode 600).
  Acceptable for single-user macOS. If lifecycle becomes painful, replace with a
  wrapper script that reads from `op`/keychain and emits JSON on stdout.
- `c` summary line is printed to stderr before launch so it's clear which
  profiles are attached without polluting the model context.
