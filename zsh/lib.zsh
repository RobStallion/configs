# Shared zsh helpers. Sourced first by .zshrc so all later modules can use them.

# Source the cached shell-init output of a command, regenerating the cache when
# the binary is newer than the cache file. Silent no-op if the binary is missing.
#
#   _cached_init <bin-name> <args-to-bin...>
#
# Cache path is derived: $HOME/.cache/zsh_<bin-name>_init
_cached_init() {
  local bin_name="$1"; shift
  local bin
  bin=$(command -v "$bin_name") || return 0
  local cache="$HOME/.cache/zsh_${bin_name}_init"
  if [[ ! -f "$cache" || "$bin" -nt "$cache" ]]; then
    mkdir -p "$HOME/.cache"
    "$bin" "$@" > "$cache"
  fi
  source "$cache"
}
