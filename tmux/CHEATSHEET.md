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

---

## Windows (tabs)

| Key | Action |
|---|---|
| `prefix c` | New window |
| `prefix ,` | Rename window |
| `prefix n` | Next window |
| `prefix p` | Previous window |
| `prefix 1–9` | Jump to window by number |
| `prefix q` | Close window (with confirm) |

---

## Panes (splits)

| Key | Action |
|---|---|
| `prefix \|` | Split vertically (side by side) |
| `prefix -` | Split horizontally (top/bottom) |
| `prefix x` | Close current pane |
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

| Key | Action |
|---|---|
| `prefix v` | Enter copy mode |
| `v` | Begin selection (in copy mode) |
| `y` | Copy selection + exit copy mode |
| `q` | Exit copy mode |
| `C-u / C-d` | Scroll up / down |
| `/` | Search forward |
| `?` | Search backward |

---

## Config

| Key / Command | Action |
|---|---|
| `prefix r` | Reload config |
| `prefix I` | Install TPM plugins (capital i) |

---

## Dev layout

```bash
~/.config/tmux/layout.sh          # launch 3-pane dev session
~/.config/tmux/layout.sh myname   # use custom session name
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
