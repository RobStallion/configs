# ── nvim ──────────────────────────────────────────────────────────────────────
alias v="nvim -O"
alias vtv="v ~/.tool-versions"

# ── zshrc ─────────────────────────────────────────────────────────────────────
alias vz="v ~/.zshrc"
function sz() {
  . ~/.zshrc
  # $TMUX is set by tmux when running inside a session; -n guards against sourcing outside one
  [[ -n $TMUX ]] && tmux source-file ~/.config/tmux/tmux.conf
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

# ── rest ──────────────────────────────────────────────────────────────────────
alias xx="exit"
alias s="open -a SourceTree ."
alias z="zed ."
