#!/usr/bin/env bash
# Dev layout: left 1/3 (Claude Code top, terminal bottom), right 2/3 (nvim/editor)
# Usage: ./layout.sh [session-name]

SESSION="$1"

if tmux has-session -t "$SESSION" 2>/dev/null; then
  tmux attach-session -t "$SESSION"
  exit 0
fi

# Size session to current terminal so percentage splits compute correctly
tmux new-session -d -s "$SESSION" -x "$(tput cols)" -y "$(tput lines)"

# Right pane = 67% width (becomes editor)
tmux split-window -h -l 67%

# Back to left pane, bottom split = 18% height (becomes terminal)
tmux select-pane -L
tmux split-window -v -l 18%

# Pane 1 = top-left, pane 2 = bottom-left, pane 3 = right
tmux select-pane -t "${SESSION}:.1" -T "claude"
tmux select-pane -t "${SESSION}:.2" -T "terminal"
tmux select-pane -t "${SESSION}:.3" -T "editor"

# Auto-run claude in the top-left pane
tmux send-keys -t "${SESSION}:.1" "claude" Enter

# Navigate 1 → right: primes directional tracking so C-h returns to claude
tmux select-pane -t "${SESSION}:.1"
tmux select-pane -R

tmux attach-session -t "$SESSION"
