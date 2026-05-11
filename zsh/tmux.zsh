# Launch or attach to a tmux dev session.
# Usage:
#   t           — session named after current directory
#   t myproject — session named myproject
t() {
  local name="${1:-$(basename "$PWD")}"
  ~/.config/tmux/layout.sh "$name"
}
