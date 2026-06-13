#!/usr/bin/env bash
# Fetch Google Calendar events for today and refresh tmux status bar.
set -euo pipefail

PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

CACHE="$HOME/.cache/tmux-calendar"
mkdir -p "$CACHE"

# Skip if cache is fresh (< 60s) — guards against burst from rapid session creation (e.g. multiple `t` / layout launches)
if [[ -f "$CACHE/events.json" ]]; then
  age=$(( $(date +%s) - $(stat -f %m "$CACHE/events.json") ))
  [[ $age -lt 60 ]] && exit 0
fi

TODAY="$(date +%Y-%m-%d)"
TOMORROW="$(date -v+1d +%Y-%m-%d)"
TMP="$(mktemp "$CACHE/events.tmp.XXXXXX")"

# Load machine-specific calendar config (not in repo)
[[ -f "$CACHE/config" ]] && source "$CACHE/config"

# Build gcalcli args — filter to a specific calendar if configured
gcalcli_args=(agenda "$TODAY" "$TOMORROW" --nocolor --military --tsv)
[[ -n "${CALENDAR_EMAIL:-}" ]] && gcalcli_args+=(--calendar "$CALENDAR_EMAIL")

events="$(gcalcli "${gcalcli_args[@]}" 2>/dev/null)" || {
  jq -n '{ok: false, fetched_at: (now|floor), error: "gcalcli failed", data: []}' > "$TMP"
  mv "$TMP" "$CACHE/events.json"
  exit 1
}

jq_input="$(printf '%s\n' "$events" | tail -n +2 | jq -R -s '
  split("\n") | map(select(length > 0) | split("\t") | select(length >= 5) |
    {start_date: .[0], start_time: .[1], end_date: .[2],
     end_time: .[3], title: .[4]})')"

jq -n \
  --argjson data "$jq_input" \
  '{ok: true, fetched_at: (now|floor), data: $data}' > "$TMP"
mv "$TMP" "$CACHE/events.json"

tmux refresh-client -S 2>/dev/null || true
