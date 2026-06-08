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

  # 1. Direct match: check if target is an absolute path or relative to current dir
  if [[ -d "$target" ]]; then
    echo "$target"
    return
  fi

  # 2. Direct match under ~/code: check if target is a direct relative path (e.g. personal/configs)
  if [[ -n "$target" && -d "$HOME/code/$target" ]]; then
    echo "$HOME/code/$target"
    return
  fi

  local result
  if [[ -z "$target" ]]; then
    local -a projects
    projects=(
      ~/code/*(N/)
      ~/code/personal/*(N/)
      ~/code/spike/*(N/)
      ~/code/claude-projects/*(N/)
    )
    projects=( ${projects#$HOME/code/} )
    projects=( ${projects:#personal} )
    projects=( ${projects:#spike} )
    projects=( ${projects:#claude-projects} )
    local selection
    selection=$(printf "%s\n" "${projects[@]}" | fzf --exit-0)
    [[ -z "$selection" ]] && return 1
    result="$HOME/code/$selection"
  else
    # 3. Intelligent path splitting if target contains a slash (e.g. personal/conf)
    if [[ "$target" == */* ]]; then
      local dir_part="${target%/*}"
      local pattern_part="${target##*/}"
      local search_root="$HOME/code/$dir_part"
      if [[ -d "$search_root" ]]; then
        result="$(fd --type d --max-depth 2 "$pattern_part" "$search_root" 2>/dev/null \
          | fzf --select-1 --exit-0)"
      else
        # Fallback to full path search if the prefix directory doesn't exist
        result="$(fd -p --type d --max-depth 3 "$target" ~/code 2>/dev/null \
          | fzf --select-1 --exit-0)"
      fi
    else
      # 4. Standard search for single term (e.g. configs)
      result="$(fd --type d --max-depth 3 "$target" ~/code 2>/dev/null \
        | fzf --select-1 --exit-0)"
    fi
  fi
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

  local target panes
  if [[ "$1" =~ ^[1-3]$ ]]; then
    target=""
    panes="$1"
  else
    target="$1"
    panes="${2:-1}"
  fi

  local dir
  dir="$(_tmux_find_dir "$target")" || return 1
  local name
  name="$(basename "$dir")"

  if [[ "$panes" == "1" ]]; then
    tmux new-window -c "$dir" -n "$name"
    return
  fi

  # Left pane is for `c <profile>` — left empty so you pick profiles
  # deliberately rather than auto-launching with ambient MCPs (see ADR-007).
  tmux new-window -c "$dir" -n "$name"

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

# ── Completions ──────────────────────────────────────────────────────────────

# Completion for tw and ts
_tw_complete() {
  local -a projects
  projects=(
    ~/code/*(N/)
    ~/code/personal/*(N/)
    ~/code/spike/*(N/)
    ~/code/claude-projects/*(N/)
  )
  projects=( ${projects#$HOME/code/} )
  projects=( ${projects:#personal} )
  projects=( ${projects:#spike} )
  projects=( ${projects:#claude-projects} )

  if [[ "$service" == "ts" ]]; then
    _arguments '1:project:($projects)'
  else
    _arguments \
      '1:project:($projects)' \
      '2:panes:(1 2 3)'
  fi
}
compdef _tw_complete tw ts

# Completion for t (suggests active sessions to attach to)
_t_complete() {
  local -a sessions
  sessions=( ${(f)"$(tmux list-sessions -F '#S' 2>/dev/null)"} )
  _arguments '1:session:($sessions)'
}
compdef _t_complete t
