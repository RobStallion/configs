# ADR-005: Migrate from asdf to mise

**Date**: 2026-05-09
**Status**: Proposed (not yet executed)

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
- Optional shimless mode (`mise activate`) injects PATH on `cd` instead of
  using shims at all — zero per-invocation cost

## Decision

Replace asdf with mise. Use shimless `mise activate zsh` mode (PATH-based) for
maximum speed.

## Migration plan

1. **Install mise**
   ```sh
   brew install mise
   ```

2. **Inventory current asdf state** — capture before changing anything:
   ```sh
   asdf current > /tmp/asdf-current-snapshot.txt
   asdf plugin list > /tmp/asdf-plugins-snapshot.txt
   ls ~/.tool-versions ~/code/*/.tool-versions 2>/dev/null > /tmp/tool-versions-files.txt
   ```

3. **Install plugins + versions in mise** — mise reads `.tool-versions` directly,
   so existing project files keep working. Install the global versions first:
   ```sh
   # For each runtime in `asdf current`:
   mise use --global node@<version>
   mise use --global python@<version>
   # ...etc
   ```

4. **Switch shell activation** — edit `zsh/.zprofile`:
   - Remove the asdf shims block (lines for `$HOME/.asdf/shims` PATH guard)
   - Add: `eval "$(mise activate zsh --shims)"` for transitional period, OR
   - Add: `eval "$(mise activate zsh)"` for full shimless (PATH per-dir)

   Cache the activation output in the same pattern as `brew shellenv` (ADR-002)
   to avoid the subprocess on every shell start.

5. **Verify**:
   ```sh
   which node python ruby     # should resolve via mise, not ~/.asdf/shims
   node --version              # should match `asdf current`'s version
   cd ~/code/<some-project>
   node --version              # project-pinned version still wins
   ```

6. **Remove asdf** (only after a week of mise running cleanly):
   ```sh
   brew uninstall asdf         # or however it was installed
   rm -rf ~/.asdf
   ```
   Keep `~/.tool-versions` files — mise reads them.

## Rollback

If mise misbehaves:
1. Comment out `mise activate` in `.zprofile`
2. Re-add the `~/.asdf/shims` PATH block
3. asdf data at `~/.asdf` is untouched until step 6

## Consequences

- Per-invocation cost drops from ~50–150ms to ~5–15ms (shimmed) or ~0ms (shimless)
- `.tool-versions` files keep working — no project changes needed
- Shimless mode means `node` is only on PATH in dirs with a version file. Scripts
  that assume `node` is always present need updating (rare).
- One more tool to remember to update (`brew upgrade mise`)
- ADR-001-style write-up of what asdf actually provided is unnecessary — the
  feature set maps 1:1.

## Open questions

- Shimmed vs shimless: pick one upfront. Shimless is faster but changes PATH
  semantics. If anything outside an interactive shell calls `node` (cron jobs,
  launch agents), shimmed is safer.
- mise has a config file (`~/.config/mise/config.toml`). Decide whether to
  symlink it from this repo for consistency with starship/zsh modules.
