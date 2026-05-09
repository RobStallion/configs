# ── mise ──────────────────────────────────────────────────────────────────────
# Shimless activation: on cd, mise prepends the correct version's bin dir to
# PATH directly. No shim overhead. Tools without a .tool-versions in scope are
# still available globally via ~/.tool-versions.
#
# Cached to avoid spawning a subprocess on every shell start (~10ms savings).
# Cache regenerates automatically when the mise binary updates.
_mise_cache="$HOME/.cache/zsh_mise_init"
_mise_bin=$(command -v mise)
if [[ -n "$_mise_bin" ]]; then
  if [[ ! -f "$_mise_cache" || "$_mise_bin" -nt "$_mise_cache" ]]; then
    mkdir -p "$HOME/.cache"
    "$_mise_bin" activate zsh > "$_mise_cache"
  fi
  source "$_mise_cache"
fi
unset _mise_cache _mise_bin
