# Launch or attach to the base tmux session.
# Usage:
#   t        — attach to (or create) session "base", window "home"
#   t myname — attach to (or create) session "myname", window "home"
t() {
  local name="${1:-base}"
  tmux new-session -A -s "$name" -n "home"
}

# Find a project directory by name under ~/code (fzf if multiple matches).
_tmux_find_dir() {
  local target="$1"
  if [[ -d "$target" ]]; then
    echo "$target"
    return
  fi
  local result
  result="$(find ~/code -maxdepth 3 -type d -name "$target" 2>/dev/null \
    | fzf --select-1 --exit-0)"
  [[ -z "$result" ]] && { echo "tmux: '$target' not found under ~/code" >&2; return 1; }
  echo "$result"
}

# tp <project> — open project in tmux with full dev layout (claude/terminal/editor).
# Outside tmux: starts a new session. Inside tmux: opens a new window.
tp() {
  local dir
  dir="$(_tmux_find_dir "${1:?usage: tp <project>}")" || return 1
  local name
  name="$(basename "$dir")"

  if [[ -z "$TMUX" ]]; then
    ~/.config/tmux/dev-session.sh "$name" "$dir"
    return
  fi

  # Launch claude in the first pane (matches dev-session.sh behavior). When claude
  # exits, exec a login shell so the pane stays alive instead of closing.
  tmux new-window -c "$dir" -n "$name" "claude; exec ${SHELL:-zsh} -l"
  tmux split-window -h -l 67% -c "$dir"
  tmux select-pane -L
  tmux split-window -v -l 18% -c "$dir"
  tmux select-pane -t ":.1" -T "claude"
  tmux select-pane -t ":.2" -T "terminal"
  tmux select-pane -t ":.3" -T "editor"
  tmux select-pane -t ":.1"
  tmux select-pane -R
}

# tw <project> — open project in a plain new tmux window (single pane).
tw() {
  local dir
  dir="$(_tmux_find_dir "${1:?usage: tw <project>}")" || return 1
  local name
  name="$(basename "$dir")"

  if [[ -z "$TMUX" ]]; then
    tmux new-session -A -s "$name" -c "$dir"
    return
  fi

  tmux new-window -c "$dir" -n "$name"
}

# Re-render tmux status bar immediately on `cd` so the path module stays in sync
# with the shell instead of waiting for status-interval to tick.
if [[ -n "$TMUX" ]]; then
  autoload -Uz add-zsh-hook
  _tmux_refresh_on_cd() { tmux refresh-client -S 2>/dev/null }
  add-zsh-hook chpwd _tmux_refresh_on_cd
fi

# ts [project] — open a vertical split in the current tmux window.
# No arg: split inherits current pane's working directory (same as `prefix |`).
ts() {
  if [[ -z "$TMUX" ]]; then
    echo "ts: must be inside tmux" >&2
    return 1
  fi

  if [[ -z "$1" ]]; then
    tmux split-window -h -c "#{pane_current_path}"
    return
  fi

  local dir
  dir="$(_tmux_find_dir "$1")" || return 1
  tmux split-window -h -c "$dir"
}
