# Tips

Reference for getting more out of the current shell setup (zsh + ghostty + starship + fzf).

## fzf shell integration

Bound by `fzf --zsh` (cached in `~/.cache/zsh_fzf_init`):

- `<C-r>` — fuzzy-search command history (reverse-chronological, exact match)
- `<C-t>` — fuzzy-pick file/dir into the current command line, with `bat` preview
- `<M-c>` — fuzzy-pick a directory and `cd` into it, with `eza --tree` preview

Inside fzf:
- `<C-j>` / `<C-k>` or arrows — navigate
- `<Tab>` — multi-select (where supported)
- `<C-/>` — toggle preview window
- Type to filter, `<CR>` to accept, `<Esc>` to cancel

Override globals in `zsh/fzf.zsh` (`FZF_CTRL_R_OPTS`, `FZF_CTRL_T_OPTS`, `FZF_ALT_C_OPTS`).

## zsh-autosuggestions

Ghost text from history while typing:

- `→` (right arrow) — accept the full suggestion
- `<C-e>` — accept and jump to end of line
- `<M-f>` — accept one word at a time (forward-word widget)
- Just keep typing — suggestion updates live, no commitment

## fast-syntax-highlighting

Live colouring of the command line as you type:

- Green command name → executable found on PATH
- Red command name → typo / not found (catches it before `<CR>`)
- Yellow string → quoted string
- Underlined path → file exists at that path

Nothing to bind. If colours look wrong on a theme change, run `fast-theme default` or pick from `fast-theme -l`.

## Git aliases

Defined in `zsh/git-aliases.zsh`. Short list of the most-used:

| Alias | Expands to |
|---|---|
| `g` | `git` |
| `gst` / `gss` / `gsb` | status (full / short / short+branch) |
| `ga` / `gaa` / `gapa` | add / add --all / add --patch |
| `gc` / `gcmsg` | commit --verbose / commit -m |
| `gca!` / `gcan!` | amend / amend --no-edit |
| `gco` / `gcb` | checkout / checkout -b |
| `gcm` / `gcd` | checkout main / develop (auto-detects name) |
| `gd` / `gds` / `gdup` | diff / diff --staged / diff @{upstream} |
| `gp` / `gpf` | push / push --force-with-lease |
| `gl` / `ggpull` / `ggpush` | pull / pull current branch / push current branch |
| `gf` / `gfa` / `gfo` | fetch / fetch --all --tags --prune / fetch origin |
| `grb` / `grbi` / `grbc` / `grba` | rebase / -i / --continue / --abort |
| `grhh` / `grhs` | reset --hard / --soft |
| `gsta` / `gstp` / `gstu` | stash push / pop / push -u (incl. untracked) |
| `glog` / `gloga` / `glol` | log oneline graph / + all / pretty graph |
| `grt` | cd to repo root |
| `gfg` | grep tracked files (`git ls-files \| grep`) |

Run `alias | grep '^g'` to see the full set.

## Kubernetes aliases (`zsh/kube.zsh`)

| Alias | Expands to |
|---|---|
| `k` | `kubectl` (with completion via `compdef k=kubectl`) |
| `kg` / `kd` | `kubectl get` / `describe` |
| `kgp` / `kdp` | get/describe pods |
| `kgd` / `kdd` | get/describe deployment |
| `kgs` / `kds` | get/describe service |
| `kgi` / `kdi` | get/describe ingress |
| `kgsa` / `kdsa` | get/describe serviceaccount |
| `kgc` / `kdc` | get/describe cronjob |
| `kc1` / `kc2` | switch context to `eks-01` / `eks-02` |
| `kns <ns>` | set current namespace (errors if namespace not found) |

Tab completion works on both `kubectl` and `k` once cache is built (regenerates when the binary updates).

## Misc aliases

| Alias | Expands to |
|---|---|
| `v` / `vz` / `vtv` | `nvim -O` / edit `.zshrc` / edit `.tool-versions` |
| `sz` | source `.zshrc` |
| `xx` | `exit` |
| `s` / `z` | open SourceTree / Zed in cwd |
| `gho [remote]` | open GitHub page for current repo (defaults to `origin`) |

## Theme switching

`theme [variant]` — switches Catppuccin variant in both Ghostty and Neovim simultaneously.

```
theme latte      # switch to Catppuccin Latte (light)
theme mocha      # switch to Catppuccin Mocha (dark)
theme macchiato  # other variants also supported
theme frappe
theme            # no arg: toggle between latte and current dark variant
```

Ghostty hot-reloads immediately. New Neovim instances open with the updated theme; running instances are unaffected.

State is stored in `~/.config/ghostty/theme.conf` (gitignored). Defined in `zsh/theme.zsh`.

## Ghostty shortcuts

Window / tabs / splits:
- `<D-n>` — new window
- `<D-t>` — new tab
- `<D-S-d>` — split down
- `<D-d>` — split right
- `<D-w>` — close surface (tab/split)
- `<D-[>` / `<D-]>` — previous/next split

Prompt navigation (requires `shell-integration = zsh`, which is set):
- `<D-S-Up>` / `<D-S-Down>` — jump to previous/next prompt
- `<D-S-J>` — scroll to bottom
- `<D-S-Home>` — scroll to top

Other:
- `<D-k>` — clear screen + scrollback
- `<D-=>` / `<D-->` — increase / decrease font size
- `<D-0>` — reset font size
- `<D-i>` — open new window in same working directory (via OSC 7)

## Starship prompt

Format defined in `starship/starship.toml`:

- Left side: `directory` → language version (node/python/ruby) → command duration → exit status → prompt char
- Right side: `kubernetes` (when repo root contains `kube/`, `k8s/`, or `__kube__/` — visible at all depths within that repo) → git branch → git status

Status symbols on the right:
- `+` staged · `·` modified · `?` untracked · `✘` deleted · `»` renamed · `$` stashed · `!` conflicted
- `↑` ahead · `↓` behind · `↕` diverged

Failed command shows the exit code in red (`✘ 127`, `✘ 130`, etc.) — handy for distinguishing "not found" vs "killed".

To add a new colour to the palette: edit `[palettes.rcm]` at the bottom of `starship.toml` and reference the name (e.g. `peach`) in any module's style. **Do not** put `[palettes.X]` above any top-level key — TOML will absorb the keys into the table and starship will silently fall back to defaults.

## zsh built-ins worth remembering

History search:
- `<C-r>` — fzf history (replaces default reverse-i-search)
- `!!` — last command
- `!$` — last argument of last command (`vim !$`)
- `^old^new` — re-run last command with `old` replaced by `new`

Word motion (with `macos-option-as-alt = true` in ghostty):
- `<M-b>` / `<M-f>` — back/forward one word
- `<M-d>` — delete word forward
- `<C-w>` — delete word backward
- `<C-u>` / `<C-k>` — kill to start / end of line

Globbing:
- `**/*.ts` — recursive glob (zsh-native, no `find` needed)
- `*(.)` — files only · `*(/)` — dirs only · `*(.x)` — executable files
- `*(.mh-1)` — modified within last hour · `*(.Lk+100)` — larger than 100KB
- `print -l **/*.md(.om[1,5])` — 5 most recently modified markdown files

Directory stack:
- `cd -` — previous directory
- `cd -<Tab>` — pick from recent dirs (with `setopt AUTO_PUSHD`)
- `dirs -v` — list stack
