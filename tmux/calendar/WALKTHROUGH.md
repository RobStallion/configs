# Walkthrough: tmux calendar chip

This document explains how the calendar chip works end-to-end, with annotated
excerpts of every file involved. The goal is that you can read this document
plus the code and understand the whole feature without needing further help.

If you just want to set it up on a new machine, see `README.md` instead.

---

## 1. What you see

A peach-colored rounded chip in the right-hand side of the tmux status bar,
to the left of the date/time chip:

```
… [ EBM Fusion Steering [NEW] @ 15:15] [ 2026-05-18 15:30]
```

- Upcoming event: `Title @ HH:MM`
- Currently in progress: `Title (now)`
- No events today: `free`

The icon is `` (Nerd Font `fa-clock-o`, codepoint U+F017), shown on a peach
background — distinct from the directory chip (rosewater), session chip
(green/red), date_time chip (blue), and the mauve active-pane border.

---

## 2. Data flow at a glance

```
┌──────────────────┐        ┌──────────────┐        ┌──────────────┐
│ tmux session     │        │ fetch.sh     │        │ Google       │
│ created (hook)   │───────▶│ (orchestr.)  │───────▶│ Calendar API │
└──────────────────┘        └──────┬───────┘        └──────┬───────┘
                                   │ JSON                  │
                                   ▼                       │
                          ┌──────────────────┐             │
                          │ ~/.cache/        │◀────────────┘
                          │  tmux-calendar/  │             via gcalcli
                          │   events.json    │
                          └────────┬─────────┘
                                   │ read every 5s
                                   ▼
┌──────────────────────┐  ┌──────────────┐  ┌─────────────────────┐
│ tmux status-interval │─▶│ chip.sh      │─▶│ status-right chip   │
│ (5s tick)            │  │ (renderer)   │  │ (catppuccin module) │
└──────────────────────┘  └──────────────┘  └─────────────────────┘
```

Two scripts, one cache file, one catppuccin module definition, three lines
added to `tmux.conf`. That's the whole feature.

---

## 3. The fetcher: `fetch.sh`

**Role:** Talk to Google Calendar (via `gcalcli`), write today's events to a
local JSON cache, tell tmux to redraw.

**When it runs:** Every time a new tmux session is created (`session-created`
hook), and on-demand when `chip.sh` notices the cache is stale (>15 min old).

### Full source, annotated

```bash
#!/usr/bin/env bash
# Fetch Google Calendar events for today and refresh tmux status bar.
set -euo pipefail
```

`set -euo pipefail` is the standard "strict mode" for bash:
- `-e` exit on any unchecked error
- `-u` error on undefined variables
- `-o pipefail` propagate failure through pipes (without this, `false | true`
  succeeds)

```bash
PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
```

tmux hooks inherit the tmux **server's** environment, not your shell's. If
the server was started before Homebrew was on PATH (or from a launchd job
that doesn't source your shell profile), `gcalcli` and `jq` won't be found.
Pinning the standard Homebrew paths up front makes the script self-sufficient.

```bash
CACHE="$HOME/.cache/tmux-calendar"
mkdir -p "$CACHE"
```

Cache lives under `$XDG_CACHE_HOME` (= `~/.cache/`), which is the
[XDG-spec-correct](https://specifications.freedesktop.org/basedir-spec/)
location for regenerable derived data. `mkdir -p` is idempotent — safe to run
every time.

```bash
# Skip if cache is fresh (< 60s) — guards against burst from dev-session.sh
if [[ -f "$CACHE/events.json" ]]; then
  age=$(( $(date +%s) - $(stat -f %m "$CACHE/events.json") ))
  [[ $age -lt 60 ]] && exit 0
fi
```

`dev-session.sh` and similar tooling spin up multiple tmux sessions in
quick succession, each firing the `session-created` hook. Without this
guard, that triggers N parallel `gcalcli` calls — wasteful and a recipe
for being rate-limited.

- `stat -f %m FILE` returns the file's modification time as a Unix timestamp
  (this is the macOS form; Linux uses `stat -c %Y`).
- `$(( ... ))` is bash arithmetic.
- If the JSON was written less than 60 seconds ago, skip silently.

```bash
TODAY="$(date +%Y-%m-%d)"
TOMORROW="$(date -v+1d +%Y-%m-%d)"
TMP="$(mktemp "$CACHE/events.tmp.XXXXXX")"
```

- `date -v+1d` = "today + 1 day" (macOS-specific syntax).
- `mktemp` creates a unique temp file; the `XXXXXX` template gets replaced
  with random chars. We write to the temp file then atomically `mv` it into
  place (see below) — guarantees `chip.sh` never reads a partially-written
  JSON.

```bash
# Load machine-specific calendar config (not in repo)
[[ -f "$CACHE/config" ]] && source "$CACHE/config"

# Build gcalcli args — filter to a specific calendar if configured
gcalcli_args=(agenda "$TODAY" "$TOMORROW" --nocolor --military --tsv)
[[ -n "${CALENDAR_EMAIL:-}" ]] && gcalcli_args+=(--calendar "$CALENDAR_EMAIL")
```

The config file `~/.cache/tmux-calendar/config` contains a single line like:
```
CALENDAR_EMAIL=robert.francis@rvu.co.uk
```

If present and sourced, `$CALENDAR_EMAIL` is set, and we append
`--calendar <email>` to the gcalcli arg list. This filters to that one
calendar.

**Why this matters:** Without `--calendar`, gcalcli returns events from
**every** calendar you're subscribed to — including shared team calendars
and colleagues' calendars (if you have reader access). Without filtering,
you'll see meetings that aren't yours.

The `${CALENDAR_EMAIL:-}` form means "value or empty if unset", which works
even under `set -u`.

```bash
events="$(gcalcli "${gcalcli_args[@]}" 2>/dev/null)" || {
  jq -n '{ok: false, fetched_at: (now|floor), error: "gcalcli failed", data: []}' > "$TMP"
  mv "$TMP" "$CACHE/events.json"
  exit 1
}
```

Call gcalcli. If it fails (network error, auth expired, etc.), write a
well-formed error JSON to the cache rather than leaving the old cache in
place or corrupting it. `chip.sh` reads `data` defensively, so it will just
show `free` rather than crashing.

The `2>/dev/null` suppresses gcalcli's stderr — its error messages aren't
useful in this context (they'd appear in `fetch.log`).

```bash
jq_input="$(printf '%s\n' "$events" | tail -n +2 | jq -R -s '
  split("\n") | map(select(length > 0) | split("\t") | select(length >= 5) |
    {start_date: .[0], start_time: .[1], end_date: .[2],
     end_time: .[3], title: .[4]})')"
```

gcalcli `--tsv` returns tab-separated lines, with a header row we skip via
`tail -n +2`. The original code parsed this with `awk` and string-interpolated
into JSON, which is unsafe: any event title containing a `"` produces invalid
JSON.

This version pipes the raw TSV into `jq` and lets jq do the JSON encoding —
quotes, backslashes, and Unicode are all handled correctly.

- `jq -R` = "raw input" mode, treats input as a string.
- `jq -s` = "slurp" mode, reads all input into one big string.
- `split("\n")` = split into lines.
- `select(length > 0)` = drop blank lines.
- `split("\t")` = split each line by tab.
- `select(length >= 5)` = guard against malformed lines.
- The object construction produces one record per event.

```bash
jq -n \
  --argjson data "$jq_input" \
  '{ok: true, fetched_at: (now|floor), data: $data}' > "$TMP"
mv "$TMP" "$CACHE/events.json"
```

Wrap the events in an envelope:
- `ok: true` — sentinel so `chip.sh` can distinguish from failure (it doesn't
  currently use it, but it's there).
- `fetched_at` — Unix timestamp, used by `chip.sh` for the staleness check.
- `data` — the array of event records.

`jq -n` ("null input") starts with no input. `--argjson` injects pre-parsed
JSON as a variable, which we then reference as `$data`. Output goes to the
temp file, then `mv` rotates it into place — atomic on POSIX filesystems.

```bash
tmux refresh-client -S 2>/dev/null || true
```

Tell tmux to redraw the status bar. `-S` redraws only the status line (cheaper
than `-c` which redraws everything). The `|| true` is belt-and-braces: if
we're called from outside tmux (e.g. manually from a shell), the command
fails harmlessly.

---

## 4. The renderer: `chip.sh`

**Role:** Read the JSON cache, decide what to display, print it. Trigger a
background refresh if the cache is stale.

**When it runs:** Every status-interval tick (5 seconds in your config),
because it's referenced by `#(...)` in the catppuccin module's text. tmux
runs the command on every refresh and uses its stdout as the chip text.

### Full source, annotated

```bash
#!/usr/bin/env bash
# Output next/current calendar event for tmux status bar.
CACHE="$HOME/.cache/tmux-calendar"
TODAY="$(date +%Y-%m-%d)"
NOW="$(date +%H:%M)"
```

No `set -euo pipefail` here — this script is called every 5s by tmux and a
silent failure (show `free`) is better than a noisy one.

```bash
# Background refresh if cache is stale (> 15 min)
if [[ -f "$CACHE/events.json" ]]; then
  fetched_at="$(jq -r '.fetched_at // 0' "$CACHE/events.json" 2>/dev/null || echo 0)"
  if [[ $(( $(date +%s) - fetched_at )) -gt 900 ]]; then
    bash "$(dirname "$0")/fetch.sh" > "$CACHE/fetch.log" 2>&1 &
  fi
fi
```

This is what keeps the chip honest if you leave tmux open all day. Without
it, a new meeting added at 10am for 3pm wouldn't show up — the cache was
written on session creation and never refreshed.

- Read `fetched_at` from the cache.
- `// 0` is jq's null-coalescing: "if missing or null, use 0".
- If older than 900s (15min), background-fire `fetch.sh` (note the trailing
  `&`).
- `> "$CACHE/fetch.log" 2>&1` captures all output into a log file you can
  read later if something looks wrong.
- The 60s self-throttle in `fetch.sh` means this is safe to run every 5s
  while the cache is stale — only one fetch will actually go through.

```bash
result="$(jq -r --arg today "$TODAY" --arg now "$NOW" '
  [.data[] | select(.start_date == $today and (.start_time // "") != "")]
  | sort_by(.start_time)
  | map(select(.start_time >= $now or ((.end_time // "") > $now)))
  | first
  | if . == null then "" else "\(.title)\t\(.start_time)\t\(.end_time // "")" end
' "$CACHE/events.json" 2>/dev/null)"
```

The whole event-selection logic, in one jq invocation (the prior version
called jq four times — the consolidation is a real perf win since this runs
every 5 seconds in every tmux session).

Step by step:
1. `[.data[] | select(...)]` — filter to today's events that have a
   start_time (drops all-day events).
2. `sort_by(.start_time)` — chronological order.
3. `map(select(.start_time >= $now or ((.end_time // "") > $now)))` — keep
   events that are either upcoming or currently in progress (end is in the
   future).
4. `first` — take the next one. If the array is empty, this returns `null`.
5. `if . == null then "" else "\(.title)\t..." end` — guard against null.
   For a non-null result, format as tab-separated `title\tstart\tend`.

The bash side reads the tab-separated string back into three variables.

```bash
[[ -z "$result" ]] && printf "free" && exit 0

IFS=$'\t' read -r title start end <<< "$result"
```

Empty result = no upcoming events today = print `free` and bail.

Otherwise, split on tab into the three variables. `IFS=$'\t'` is bash's
syntax for "tab character"; `read -r` disables backslash escape processing
(safer for arbitrary data).

```bash
if [[ ${#title} -gt 30 ]]; then
  title="${title:0:28}…"
fi
```

Truncate long titles to keep the chip from dominating the status bar. The
`…` is a single character (Unicode ellipsis), not three dots — saves space.

```bash
if [[ ! "$start" > "$NOW" && -n "$end" && "$end" > "$NOW" ]]; then
  printf "%s (now)" "$title"
else
  printf "%s @ %s" "$title" "$start"
fi
```

`start` and `end` are `HH:MM` strings; string comparison happens to work
correctly because of the zero-padded format.

- If start is in the past **and** end is in the future → in progress, show
  `Title (now)`.
- Otherwise → upcoming, show `Title @ HH:MM`.

The leading icon used to live here too (`◷ Title @ HH:MM` / `● Title (now)`),
but was removed when we wired the static clock icon into the catppuccin chip
icon section. Having two icons was confusing.

---

## 5. The chip definition: `calendar.conf`

**Role:** Define a custom catppuccin status module called `calendar` that
catppuccin's template machinery turns into a rendered chip.

### Full source, annotated

```tmux
%hidden MODULE_NAME="calendar"
```

`%hidden` is a tmux config-parser directive that sets a parse-time variable
(not a runtime tmux option). The variable is interpolated into the lines
below as `${MODULE_NAME}`. This matches the exact pattern used by all the
built-in catppuccin modules (`directory.conf`, `session.conf`, etc.).

```tmux
set -gq  "@catppuccin_${MODULE_NAME}_icon"  " "
```

After parser interpolation: `set -gq "@catppuccin_calendar_icon" " "`.

- `-g` = global option (applies workspace-wide, not per-window).
- `-q` = quiet (no error if the option doesn't exist).
- The icon is `` (Nerd Font `fa-clock-o`, U+F017) followed by a space.

**Important:** This file was originally written via shell `printf` with
explicit UTF-8 hex bytes (`\xef\x80\x97`) for the icon. Editing it through
some other tooling can silently strip the Nerd Font character because it
lives in the Unicode Private Use Area. If the chip suddenly loses its icon
after an edit, run:

```bash
sed -n '3p' ~/.config/tmux/calendar/calendar.conf | xxd | tail -2
```

You should see bytes `ef 80 97` in the output. If they're missing, rewrite
the line via printf.

```tmux
set -gqF "@catppuccin_${MODULE_NAME}_color" "#{E:@thm_peach}"
```

`-F` evaluates the value as a tmux format string at set time. `#{E:@thm_peach}`
expands to the hex value of catppuccin's `@thm_peach` palette colour
(`#ef9f76` for the frappe flavor). This is the background color of the
chip's icon section.

Why peach: distinct from every other colored thing on the bar (directory
rosewater, session green/red, date_time blue, active pane border mauve),
warm enough to draw the eye for "upcoming time-sensitive thing."

```tmux
set -gq "@catppuccin_${MODULE_NAME}_text" "#(~/.config/tmux/calendar/chip.sh)"
```

The chip's text content. The `#(...)` is tmux's shell-command interpolation —
runs the script on every status refresh, uses stdout as the chip text.

```tmux
source -F "#{d:current_file}/../plugins/tmux/utils/status_module.conf"
```

This is the magic line. `status_module.conf` is the catppuccin utility that
takes the three options we just set (`_icon`, `_color`, `_text`) and produces
the rendered chip string in `@catppuccin_status_calendar` — the variable we
reference from `status-right`.

- `#{d:current_file}` resolves to the directory of the file currently being
  sourced — here that's `~/.config/tmux/calendar/`.
- `../plugins/tmux/utils/status_module.conf` then resolves to
  `~/.config/tmux/plugins/tmux/utils/status_module.conf` — the catppuccin
  plugin's template file.
- `-F` evaluates the path as a format string so `#{d:current_file}` works.

**Why the path looks weird:** TPM installs `catppuccin/tmux` under the repo
name `tmux`, not the owner/repo name. So the actual install path is
`~/.config/tmux/plugins/tmux/`, not `~/.config/tmux/plugins/catppuccin/`
which you might intuitively expect.

---

## 6. The five-segment render template

When `source -F .../status_module.conf` runs above, catppuccin's template
expands your three options into a multi-segment chip:

```
[left_cap][icon section][middle separator][text section][right_cap]
```

Each segment has its own foreground and background color. The defaults are:

| Segment | bg color | fg color |
|---|---|---|
| left/right cap | matches icon bg | (separator chars) |
| icon section | `@catppuccin_calendar_color` (= `@thm_peach`) | `@thm_crust` |
| middle separator | (none) | (connector chars) |
| text section | `@catppuccin_status_module_text_bg` (= `@thm_surface_0`) | `@thm_fg` |

You can override any of these per-module by setting `@catppuccin_status_calendar_<segment>_<fg|bg>` — that's how we'd e.g. swap the
text bg if we wanted (we don't, the defaults look fine here).

The `_icon` and `_text` options control only the **content** of the icon and
text sections, not their styling. The styling all comes from this template.

---

## 7. tmux.conf integration

Three changes in `tmux/tmux.conf`. All small, all important.

### Change 1: Session-created hook (before TPM loads)

```tmux
# ── Calendar ──────────────────────────────────────────────────────────────────
# Fetch fresh data on every new session; backgrounded so it doesn't block.
set-hook -ga session-created 'run-shell -b "~/.config/tmux/calendar/fetch.sh"'
```

- `set-hook -g` = global hook (fires for any session).
- `-a` = append (preserves any other hooks bound to this event).
- `session-created` = fires when tmux creates a new session.
- `run-shell -b` = run in background. The `-b` is important: without it,
  tmux waits for the script to finish before letting you into the session.
  With a network round-trip to Google, that would be a perceptible delay.

### Change 2: Source the chip definition (after TPM loads)

```tmux
run '~/.config/tmux/plugins/tpm/tpm'

# ── Status bar (must come after TPM loads catppuccin) ─────────────────────────
source ~/.config/tmux/calendar/calendar.conf
```

`calendar.conf` references `@thm_peach`, which is only set after catppuccin
finishes loading. catppuccin loads during the `run '...tpm'` line. So
`calendar.conf` must be sourced **after** that line.

### Change 3: Add the chip to status-right

```diff
-set -g status-right "#{E:@catppuccin_status_date_time}"
+set -g status-right "#{E:@catppuccin_status_calendar}#{E:@catppuccin_status_date_time}"
```

`#{E:@catppuccin_status_calendar}` expands to the rendered chip string that
the template populated. tmux concatenates the two `#{...}` expansions and
renders them right-to-left from the right edge of the status bar. The date
chip lands on the far right; the calendar chip immediately to its left.

---

## 8. State that lives outside the repo

These files are intentionally not version-controlled — they're either
machine-specific or runtime state.

| Path | Purpose | Created by |
|---|---|---|
| `~/.cache/tmux-calendar/config` | `CALENDAR_EMAIL=…` filter | You, manually |
| `~/.cache/tmux-calendar/events.json` | JSON cache of today's events | `fetch.sh` |
| `~/.cache/tmux-calendar/fetch.log` | stdout/stderr of stale-refresh fetches | `chip.sh` |
| `~/.config/gcalcli/oauth` | Google OAuth token (auto-refreshes) | `gcalcli init` |

Setting up a new machine is the only time you touch the config file. See
`README.md` for the procedure.

---

## 9. Refresh strategy

Three triggers refresh the JSON cache:

1. **New tmux session.** The `session-created` hook fires `fetch.sh`. This
   is the "first time of the day" trigger — when you start tmux in the
   morning, the cache gets populated.

2. **Stale cache while running.** `chip.sh` checks the cache's `fetched_at`
   timestamp every 5 seconds (every status refresh). If older than 15 minutes,
   it fires `fetch.sh` in the background. This keeps the chip honest if you
   leave tmux open all day — a meeting added at 10am for 3pm will show up
   within 15 minutes.

3. **Manual.** You can run `~/.config/tmux/calendar/fetch.sh` directly.
   Delete `~/.cache/tmux-calendar/events.json` first if you want to bypass
   the 60s self-throttle.

`fetch.sh` itself throttles to once per 60 seconds. This protects against
both rapid session bursts (`dev-session.sh` creating multiple sessions) and
against `chip.sh` accidentally firing multiple background refreshes.

The chip script (`chip.sh`) runs every 5 seconds regardless, but only reads
the local JSON file — no network. Cheap.

---

## 10. Debugging

If the chip is broken, walk these checks in order.

### Is the cache populated?

```bash
cat ~/.cache/tmux-calendar/events.json | jq .
```

Should show `{ok: true, fetched_at: ..., data: [ ... ]}`. If it shows
`ok: false` or the file is missing, `fetch.sh` is failing.

### Can fetch.sh run by hand?

```bash
rm -f ~/.cache/tmux-calendar/events.json
bash ~/.config/tmux/calendar/fetch.sh
echo "exit: $?"
```

If it exits nonzero or leaves an `ok: false` cache, the underlying issue is
either gcalcli or the calendar filter. Try:

```bash
gcalcli list                                  # OAuth working?
gcalcli agenda                                # any events at all?
gcalcli --calendar your.email@... agenda      # does the filter work?
```

### Can chip.sh produce output?

```bash
bash ~/.config/tmux/calendar/chip.sh
```

Should print the chip text (`Title @ HH:MM`, `Title (now)`, or `free`).

### Does the catppuccin chip variable exist?

```bash
tmux show-option -gv @catppuccin_status_calendar
```

Should print a long string with format codes and color escapes. If empty,
`source ~/.config/tmux/calendar/calendar.conf` didn't run — check the
ordering in `tmux.conf` (must be after `run '...tpm'`).

### Is the icon character in the file?

```bash
sed -n '3p' ~/.config/tmux/calendar/calendar.conf | xxd | tail -2
```

Bytes `ef 80 97` should be present. If missing, the file was edited through
something that strips Private Use Area characters — rewrite the line via
`printf` (see `calendar.conf` annotation above).

### Logs

`~/.cache/tmux-calendar/fetch.log` contains the most recent
stale-refresh fetch's stdout/stderr. The `session-created` hook redirects
to the same file too (depends on which version of the hook is current).

---

## 11. How to customize common things

### Change the icon

Edit line 3 of `calendar.conf`. Because of the Nerd Font / PUA issue, use
`printf`:

```bash
# Look up the Nerd Font codepoint at https://www.nerdfonts.com/cheat-sheet
# Convert to UTF-8 bytes (e.g. U+F073 = ef 81 b3 for fa-calendar)
# Then rewrite the line:
printf '... "\xef\x81\xb3 " ...' > ~/.config/tmux/calendar/calendar.conf
```

Standard Unicode characters (anything below U+E000) can be typed directly
into the file with a normal editor — only PUA glyphs need the printf trick.

### Change the color

Edit line 4 of `calendar.conf`. Pick any catppuccin palette name from:
`rosewater, flamingo, pink, mauve, red, maroon, peach, yellow, green, teal,
sky, sapphire, blue, lavender`.

```tmux
set -gqF "@catppuccin_${MODULE_NAME}_color" "#{E:@thm_lavender}"
```

Avoid: colors already in heavy use on your bar (rosewater = directory,
green/red = session, blue = date_time, mauve = active pane border).

### Change the displayed text

Edit `chip.sh`'s two `printf` lines at the bottom. The script can output
anything — tmux just uses whatever lands on stdout.

### Change the refresh interval

The 5s status refresh is `set -g status-interval 5` in `tmux.conf`. The
15min staleness threshold is the `900` in `chip.sh`'s second `if`. The 60s
self-throttle is the `60` in `fetch.sh`'s skip-if-fresh check.

### Filter to multiple calendars

Currently the config supports one `CALENDAR_EMAIL`. To support multiple,
extend `fetch.sh` to read e.g. `CALENDAR_EMAILS=email1,email2` and append
one `--calendar` flag per entry. gcalcli supports multiple `--calendar`
flags natively.
