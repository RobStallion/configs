#!/bin/bash
# ~/.config/tmux/terminal_popup.sh
# Creates or attaches to a project-specific tmux session inside a popup.

# Use current working directory (set by display-popup -d)
dir_path="$PWD"

# Strip trailing slash to keep hashes and names consistent
dir_path="${dir_path%/}"

# Ensure it's a valid directory, fallback to HOME if not
if [ ! -d "$dir_path" ]; then
  dir_path="$HOME"
fi

# Get the base folder name
base_name=$(basename "$dir_path")

# Sanitize the folder name to be a valid tmux session name (no colons or periods)
# Keep only alphanumeric, underscores, and hyphens
base_name_clean=$(echo "$base_name" | sed 's/[^a-zA-Z0-9_-]/_/g')

# Calculate an 8-character hash of the full path to guarantee uniqueness
path_hash=$(echo -n "$dir_path" | md5 | cut -c 1-8)

# Construct the session name
session_name="term_popup_${base_name_clean}_${path_hash}"

# Create/attach to the session
tmux new-session -A -s "$session_name" -c "$dir_path"
