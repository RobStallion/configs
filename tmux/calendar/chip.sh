#!/usr/bin/env bash
# Output next/current calendar event for tmux status bar.
CACHE="$HOME/.cache/tmux-calendar"
TODAY="$(date +%Y-%m-%d)"
NOW="$(date +%H:%M)"

# Background refresh if cache is stale (> 15 min)
if [[ -f "$CACHE/events.json" ]]; then
  fetched_at="$(jq -r '.fetched_at // 0' "$CACHE/events.json" 2>/dev/null || echo 0)"
  if [[ $(( $(date +%s) - fetched_at )) -gt 900 ]]; then
    bash "$(dirname "$0")/fetch.sh" > "$CACHE/fetch.log" 2>&1 &
  fi
fi

result="$(jq -r --arg today "$TODAY" --arg now "$NOW" '
  [.data[] | select(.start_date == $today and (.start_time // "") != "")]
  | sort_by(.start_time)
  | map(select(.start_time >= $now or ((.end_time // "") > $now)))
  | first
  | if . == null then "" else "\(.title)\t\(.start_time)\t\(.end_time // "")" end
' "$CACHE/events.json" 2>/dev/null)"

[[ -z "$result" ]] && printf "free" && exit 0

IFS=$'\t' read -r title start end <<< "$result"

if [[ ${#title} -gt 30 ]]; then
  title="${title:0:28}…"
fi

if [[ ! "$start" > "$NOW" && -n "$end" && "$end" > "$NOW" ]]; then
  printf "%s (now)" "$title"
else
  printf "%s @ %s" "$title" "$start"
fi
