# ADR-005: Migrate from asdf to mise

**Date**: 2026-05-09
**Status**: Accepted (executed 2026-05-09, soak period in progress)

## For / Against

**For mise:**
- 5–10× faster shim resolution (Rust binary vs shell script)
- Shimless mode available: zero per-invocation cost via PATH injection on `cd`
- Reads `.tool-versions` directly — zero project-side changes required
- Actively maintained; asdf development has slowed
- `mise.toml` is a superset of `.tool-versions` with richer config when needed

**Against mise:**
- Newer, less battle-tested than asdf
- Shimless mode changes PATH semantics — tools absent outside `.tool-versions` dirs; risky for scripts/cron
- One more binary to keep updated
- Minor plugin compat risk for niche asdf plugins

**Conclusion:** Switch. Speed gain is real and measurable. Risk is low — mise reads existing `.tool-versions` files unchanged, and asdf stays dormant during the soak period as a fallback. Shimless chosen over shimmed: mise prepends to PATH on `cd` so it always wins over brew, and global `~/.tool-versions` ensures tools are available everywhere.

---

## Context

`asdf` manages multiple language runtimes via shims at `~/.asdf/shims`. Every
invocation of `node`, `python`, `ruby`, etc. goes through a shim script that
re-resolves the active version by walking up the directory tree looking for
`.tool-versions`. The shim is shell-based, so each call spawns extra processes.

Measured cost: shim resolution adds ~50–150ms per invocation (varies by depth
of the version-file search). Tools like prettier/eslint/jest that invoke `node`
many times per run inherit this overhead linearly.

`mise` (formerly `rtx`) is a drop-in replacement written in Rust:
- Reads the same `.tool-versions` file (and `.mise.toml`)
- Same plugin ecosystem (`asdf` plugins work via compatibility layer)
- Compiled binary instead of shell shim → ~5–10× faster resolution
- Shimless mode (`mise activate`) injects PATH on `cd` instead of using shims
  at all — zero per-invocation cost

## Decision

Replace asdf with mise in shimless mode (`mise activate zsh`). Shimless was
chosen over shimmed because mise prepends its paths at `cd` time, winning over
brew regardless of PATH order. Global `~/.tool-versions` keeps all tools
available outside project dirs, so shimless carries no practical downside.

## What changed

`.tool-versions` was pruned and bumped as part of this migration:

**Removed from version management** (moved to brew — no version pinning needed):
`bat`, `fd`, `neovim`, `lua-language-server`

**Removed entirely** (unused runtimes):
`elixir`, `erlang`, `clojure`, `java`, `lein`, `argo`, `kubectx`

**Removed** (native management preferred):
`gcloud` (managed via `gcloud components update`),
`ruff` (managed via `uv tool install`),
`poetry` (vfox plugin broken on 2.x; managed per-project via `uv tool install poetry`)

**Remaining tools** (all bumped to latest stable/LTS):
`nodejs`, `kubectl`, `terraform`, `golang`, `python`, `yq`, `kustomize`, `uv`, `gomplate`, `bun`

**Shell wiring:**
- `zsh/mise.zsh` added — cached `mise activate zsh` (same pattern as starship init)
- Sourced first in `.zshrc` so all subsequent modules see mise-managed PATH
- `zsh/.zprofile` asdf block commented out (not deleted — rollback available)
- `mise/config.toml` added to repo, symlinked to `~/.config/mise/config.toml`
- `~/.tool-versions` symlinked to repo for version control

**Python attestation note:** cpython 3.13.0 predates mise's GitHub artifact
attestation support. `MISE_PYTHON_GITHUB_ATTESTATIONS=false` set in `.zprofile`
as a workaround. Remove when Python is bumped to a version that has attestations.

## Rollback

1. Comment out `source ~/.config/zsh/mise.zsh` in `.zshrc`
2. Uncomment the asdf block in `.zprofile`
3. `~/.asdf` is untouched — asdf is immediately functional again

## Remove asdf (after soak period ~2026-05-16)

```sh
brew uninstall asdf
rm -rf ~/.asdf
# Delete the commented asdf block from zsh/.zprofile
```

## Consequences

- Per-invocation cost: ~0ms (shimless PATH injection vs ~50–150ms asdf shims)
- `.tool-versions` files in projects keep working — no project changes needed
- `poetry` managed per-project via `uv tool install poetry` rather than globally
- `mise/config.toml` in repo keeps version management config under source control
