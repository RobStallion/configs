#!/bin/bash
# Kill any existing config_popup session to ensure a clean slate
tmux kill-session -t config_popup 2>/dev/null

# Create a new detached session starting in the configs directory
tmux new-session -d -s config_popup -c "/Users/robertfrancis/code/personal/configs"

# Split window horizontally (left pane is 35% width, right pane gets remaining 65%)
tmux split-window -h -p 65 -t config_popup -c "/Users/robertfrancis/code/personal/configs"

# Set pane titles
tmux select-pane -t config_popup:.1 -T "claude"
tmux select-pane -t config_popup:.2 -T "editor"

# Focus the editor pane (pane 2)
tmux select-pane -t config_popup:.2

# Attach to the session inside the popup
tmux attach-session -t config_popup
