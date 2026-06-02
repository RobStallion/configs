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
  result="$(fd --type d --max-depth 3 "$target" ~/code 2>/dev/null \
    | fzf --select-1 --exit-0)"
  [[ -z "$result" ]] && { echo "tmux: '$target' not found under ~/code" >&2; return 1; }
  echo "$result"
}

# tw <project> [panes] — open project in a new tmux window.
# panes=1 (default): plain window. panes=2: 35/65 claude|editor.
# panes=3: claude/terminal|editor.
tw() {
  if [[ -z "$TMUX" ]]; then
    echo "tw: must be inside tmux" >&2
    return 1
  fi

  local dir panes
  dir="$(_tmux_find_dir "${1:?usage: tw <project> [panes]}")" || return 1
  panes="${2:-1}"
  local name
  name="$(basename "$dir")"

  if [[ "$panes" == "1" ]]; then
    tmux new-window -c "$dir" -n "$name"
    return
  fi

  # Left pane is for `c <profile>` — left empty so you pick profiles
  # deliberately rather than auto-launching with ambient MCPs (see ADR-007).
  # Brief pause lets the PTY settle before splitting, avoiding a race where
  # zsh draws its first prompt mid-resize and shows a spurious `%`.
  tmux new-window -c "$dir" -n "$name"
  sleep 0.1

  if [[ "$panes" == "2" ]]; then
    tmux split-window -h -p 65 -c "$dir"
    tmux select-pane -t ":.1" -T "claude"
    tmux select-pane -t ":.2" -T "editor"
    tmux select-pane -t ":.2"
  else
    tmux split-window -h -l 67% -c "$dir"
    tmux select-pane -L
    tmux split-window -v -l 18% -c "$dir"
    tmux select-pane -t ":.1" -T "claude"
    tmux select-pane -t ":.2" -T "terminal"
    tmux select-pane -t ":.3" -T "editor"
    tmux select-pane -t ":.1"
    tmux select-pane -R
  fi
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
