#!/usr/bin/env bash
# Dev layout: left 1/3 (Claude Code top, terminal bottom), right 2/3 (nvim/editor)
# Usage: ./dev-session.sh [session-name]

SESSION="${1:-dev}"

if tmux has-session -t "$SESSION" 2>/dev/null; then
  tmux attach-session -t "$SESSION"
  exit 0
fi

# Size session to current terminal so percentage splits compute correctly.
# Top-left pane runs claude as its first process (no shell race). When claude
# exits, exec into a login shell so the pane stays alive instead of closing.
tmux new-session -d -s "$SESSION" -x "$(tput cols)" -y "$(tput lines)" \
  "claude; exec ${SHELL:-zsh} -l"

# Right pane = 67% width (becomes editor)
tmux split-window -h -l 67%

# Back to left pane, bottom split = 18% height (becomes terminal)
tmux select-pane -L
tmux split-window -v -l 18%

# Pane 1 = top-left, pane 2 = bottom-left, pane 3 = right
tmux select-pane -t "${SESSION}:.1" -T "claude"
tmux select-pane -t "${SESSION}:.2" -T "terminal"
tmux select-pane -t "${SESSION}:.3" -T "editor"

# Navigate 1 → right: primes directional tracking so C-h returns to claude
tmux select-pane -t "${SESSION}:.1"
tmux select-pane -R

tmux attach-session -t "$SESSION"
