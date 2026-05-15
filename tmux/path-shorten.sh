#!/usr/bin/env bash
# Print a short, informative form of a path for the tmux status bar.
#   In a git repo:           <repo-name>[/subpath]
#   Outside, ≥2 segments:    <parent>/<leaf>
#   Otherwise:               path with $HOME → ~

path="${1:-$PWD}"

if repo_root=$(git -C "$path" rev-parse --show-toplevel 2>/dev/null); then
  repo_name="${repo_root##*/}"
  rel="${path#$repo_root}"
  rel="${rel#/}"
  if [[ -z "$rel" ]]; then
    printf '%s' "$repo_name"
  else
    printf '%s/%s' "$repo_name" "$rel"
  fi
  exit 0
fi

display="${path/#$HOME/~}"
case "$display" in
  */*/*)
    parent="${display%/*}"
    printf '%s/%s' "${parent##*/}" "${display##*/}"
    ;;
  *)
    printf '%s' "$display"
    ;;
esac
