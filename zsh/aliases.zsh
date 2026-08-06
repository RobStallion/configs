# ── nvim ──────────────────────────────────────────────────────────────────────
alias v="nvim -O"
alias vz="v ~/.zshrc"
alias vtv="v ~/.config/mise/config.toml"

# ── zshrc ─────────────────────────────────────────────────────────────────────
# Reloads .zshrc in this pane, then fans out to every other idle zsh pane in
# the *current window* — siblings only, other windows and sessions are left
# alone. A reload only takes effect inside the shell itself, so siblings are
# poked with send-keys and each prints its own "reloaded current pane" line.
# SZ_CHILD guards the fan-out: without it the pane we poke would poke us back
# and the two would ping-pong forever.
function sz() {
  . ~/.zshrc

  if [[ -z "$TMUX" ]]; then
    echo "sz: reloaded current shell"
    return
  fi

  tmux source-file ~/.config/tmux/tmux.conf
  echo "sz: reloaded current pane $TMUX_PANE"

  [[ -n "$SZ_CHILD" ]] && return

  local pane_id cmd
  # No -s: list-panes defaults to the current window.
  tmux list-panes -F '#{pane_id} #{pane_current_command}' | while read -r pane_id cmd; do
    if [[ "$pane_id" == "$TMUX_PANE" ]]; then
      continue
    fi
    if [[ "$cmd" == *zsh ]]; then
      echo "sz: sending reload to pane $pane_id (zsh)"
      tmux send-keys -t "$pane_id" "SZ_CHILD=1 sz" C-m
    else
      echo "sz: skipping pane $pane_id (running $cmd)"
    fi
  done
}

# ── ls (eza) ──────────────────────────────────────────────────────────────────
# eza = modern Rust replacement for ls. Colours by type, --git shows per-file
# git status, --group-directories-first puts dirs at the top.
# Drop user + permissions columns by default — single-user machine, perms
# rarely matter. Use `lp` when you actually need them.
alias l='eza -lah --git --no-user --no-permissions --time-style=relative --group-directories-first --icons=auto'
alias ll='eza -lh --git --no-user --no-permissions --time-style=relative --group-directories-first --icons=auto'
alias lp='eza -lah --git --time-style=relative --group-directories-first --icons=auto'  # full info incl. perms + user
alias lt='eza --tree --level=2 --icons=auto'
alias md='mkdir -p'

# ── navigation ────────────────────────────────────────────────────────────────
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias -- -='cd -'             # - goes to previous directory

# Makes a directory and cd into it
function take() {
  mkdir -p "$1" && cd "$1"
}

# ── rest ──────────────────────────────────────────────────────────────────────
alias xx="exit"
alias s="open -a SourceTree ."
alias z="zed ."
