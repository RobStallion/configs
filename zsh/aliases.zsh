# ── nvim ──────────────────────────────────────────────────────────────────────
alias v="nvim -O"
alias vtv="v ~/.tool-versions"

# ── zshrc ─────────────────────────────────────────────────────────────────────
function sz() {
  local target_all=false
  if [[ "$1" == "-a" || "$1" == "--all" ]]; then
    target_all=true
  fi

  . ~/.zshrc

  if [[ -n "$TMUX" ]]; then
    tmux source-file ~/.config/tmux/tmux.conf
    if [[ "$target_all" == "true" ]]; then
      local pane_id cmd
      tmux list-panes -F '#{pane_id} #{pane_current_command}' | while read -r pane_id cmd; do
        if [[ "$pane_id" == "$TMUX_PANE" ]]; then
          continue
        fi
        if [[ "$cmd" == *zsh ]]; then
          echo "sz: sending reload to pane $pane_id (zsh)"
          tmux send-keys -t "$pane_id" "sz" C-m
        else
          echo "sz: skipping pane $pane_id (running $cmd)"
        fi
      done
    fi
  fi
}
compdef '_arguments "1:options:((-a\ --all))"' sz

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

# ── rest ──────────────────────────────────────────────────────────────────────
alias xx="exit"
alias s="open -a SourceTree ."
alias z="zed ."
