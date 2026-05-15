# tmux Cheatsheet

Prefix = `C-a` (hold Ctrl, tap a)
> Note: `C-a C-a` sends `C-a` to the shell (readline: jump to line start)

## Concepts

```
Session
  └── Window  (like a tab — fills the full terminal)
        └── Pane  (a split within a window)
```

Sessions persist after you close the terminal. `tmux attach` brings you back.

---

## Sessions

| Key / Command | Action |
|---|---|
| `tmux` | New session (no name) |
| `tmux new -s dev` | New named session |
| `tmux attach` | Attach to last session |
| `tmux attach -t dev` | Attach to named session |
| `tmux ls` | List sessions |
| `prefix d` | Detach (leaves session running) |
| `prefix $` | Rename current session |
| `prefix s` | Interactive session picker |
| `prefix x` | Kill current session (with confirm) |

---

## Windows (tabs)

| Key | Action |
|---|---|
| `prefix c` | New window |
| `prefix ,` | Rename window |
| `prefix n` / `prefix p` | Next / previous window |
| `S-Left` / `S-Right` | Next / previous window (no prefix) |
| `prefix l` | Jump to last window |
| `prefix 1–9` | Jump to window by number |
| `prefix q` | Close window (with confirm) |

---

## Panes (splits)

| Key | Action |
|---|---|
| `prefix \|` | Split vertically (side by side) |
| `prefix -` | Split horizontally (top/bottom) |
| `prefix z` | **Zoom** — toggle pane fullscreen |
| `prefix {` | Swap pane left |
| `prefix }` | Swap pane right |
| `prefix space` | Cycle through pane layouts |

---

## Navigation

`C-h/j/k/l` — move between panes **and nvim splits** seamlessly (smart-splits).  
No prefix needed.

---

## Resize

`M-h/j/k/l` — resize pane (Alt + hjkl). No prefix needed.  
Matches nvim resize bindings.

---

## Copy mode

`prefix v` enters a **vim-like normal mode** over the pane's scrollback. Navigate
with all the usual vim motions, then visual-select and yank to copy.

Selections (mouse or keyboard) go to the **macOS system clipboard** via `pbcopy`,
so `Cmd-v` pastes them anywhere.

### Entering / exiting

| Key | Action |
|---|---|
| `prefix v` | Enter copy mode |
| `q` or `Esc` | Exit copy mode |

### Navigation (vim motions)

| Key | Action |
|---|---|
| `h j k l` | Move cursor |
| `w / b` | Next / prev word |
| `0 / $` | Line start / end |
| `gg / G` | Top / bottom of buffer |
| `C-u / C-d` | Half-page up / down |
| `/ pattern` | Search forward |
| `? pattern` | Search backward |
| `n / N` | Next / prev match |

### Selection + copy

| Key | Action |
|---|---|
| `v` | Begin character selection |
| `C-v` | Toggle rectangle (block) selection |
| `V` | Line selection |
| `y` | Yank selection → clipboard (or whole line if no selection), exit copy mode |
| `Y` | Yank cursor → end of line → clipboard, exit copy mode |
| `Enter` | Same as `y` |

### Mouse

Click-drag inside a pane selects within that pane only and copies to the system
clipboard on release. Hold **Option** while dragging to bypass tmux and use
Ghostty's native selection (spans panes).

### Paste

| Key | Action |
|---|---|
| `Cmd-v` | Paste from system clipboard (anywhere) |
| `prefix ]` | Paste from tmux buffer |

---

## Config

| Key / Command | Action |
|---|---|
| `prefix r` | Reload config |
| `prefix I` | Install TPM plugins (capital i) |

---

## Dev layout

```bash
~/.config/tmux/dev-session.sh          # launch 3-pane dev session
~/.config/tmux/dev-session.sh myname   # use custom session name
```

```
┌────────────┬──────────────────────┐
│  claude    │                      │
│  (top-left)│   editor / nvim      │
│            │   (right, 2/3 width) │
├────────────┤                      │
│  terminal  │                      │
│ (bot-left) │                      │
└────────────┴──────────────────────┘
```

Zoom the editor pane with `prefix z` while coding. Zoom out to return.

Pane labels above each pane (`claude` / `terminal` / `editor`) come from
`tmux select-pane -T <name>` set by the layout script.

---

## Shell helpers (zsh/tmux.zsh)

| Command | Action |
|---|---|
| `t [name]` | Attach/create session `name` (default `base`), window `home` |
| `tp <project>` | Open `<project>` with full dev layout (claude/terminal/editor). Outside tmux: new session. Inside tmux: new window |
| `ts [project]` | Vertical split inside current window. No arg: splits in current pane's cwd |
| `tw <project>` | Plain new window for `<project>` (no layout) |

`<project>` is matched against directories under `~/code` (depth 3); fzf disambiguates multiple matches.

---

## Status bar layout

```
[session] [window-chips] [📁 path]                                  
```

- `session` — current tmux session name
- `window-chips` — one chip per window in the session, active highlighted
- `path` — git-aware: `<repo>/<subpath>` inside a repo, last two segments outside
