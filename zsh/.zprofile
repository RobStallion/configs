# Homebrew — runs in zprofile (login shell only) so it's set once per session
# and inherited by all child processes (tmux, sub-shells, scripts).
# Cache avoids spawning a subprocess on every shell start.
# Cache is regenerated automatically whenever brew itself is updated.
_brew_cache="$HOME/.cache/zsh_brew_env"
if [[ ! -f "$_brew_cache" || /opt/homebrew/bin/brew -nt "$_brew_cache" ]]; then
  mkdir -p "$HOME/.cache"
  /opt/homebrew/bin/brew shellenv > "$_brew_cache"
fi
source "$_brew_cache"
unset _brew_cache
