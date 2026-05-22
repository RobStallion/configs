# ── mise ──────────────────────────────────────────────────────────────────────
# Shimless activation: on cd, mise prepends the correct version's bin dir to
# PATH directly. No shim overhead. Tools without a .tool-versions in scope are
# still available globally via ~/.tool-versions.
#
# Cached to avoid spawning a subprocess on every shell start (~10ms savings).
_cached_init mise activate zsh
