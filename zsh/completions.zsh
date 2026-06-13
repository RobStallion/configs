# ── Grok ──────────────────────────────────────────────────────────────────────
# fpath addition for the Grok CLI's native zsh completions.
# Must appear before compinit below so that ~/.grok/completions/zsh/_grok
# is discovered during initialization.
#
# The PATH export was originally placed here by the grok installer but has
# been moved to .zprofile (per the convention that PATH changes and exported
# env vars belong in the login-shell file for inheritance into tmux panes,
# subshells, etc.).
fpath=(~/.grok/completions/zsh $fpath)

# Initialise completion system.
# -d: use explicit dumpfile path so we can track it.
# Fast path: if the dump is fresh (modified <24h ago), skip compinit's
# security/audit walk via -C. Otherwise run a full compinit to refresh it.
# The (N.mh-24) glob qualifier matches the file only if mtime is within
# the last 24 hours (N = nullglob, .  = regular file, mh-24 = mtime <24h).
# Glob qualifiers don't expand inside `[[ -n ]]`, so assign to an array and
# check its length instead.
autoload -Uz compinit
_zdump=($HOME/.zcompdump(N.mh-24))
if (( ${#_zdump} )); then
  compinit -C -d "$HOME/.zcompdump"
else
  compinit -d "$HOME/.zcompdump"
fi
unset _zdump

# ── Completion behaviour ──────────────────────────────────────────────────────

# Tab opens a menu when multiple matches exist
zstyle ':completion:*' menu select

# Case-insensitive, smart-path, and substring/fuzzy matching dynamically based on length
zstyle -e ':completion:*' matcher-list '
  if (( ${#PREFIX} < 3 )); then
    # Less than 3 characters: Case-insensitive prefix and path-segments only
    reply=("m:{a-z}={A-Z}" "r:|[._-]=* r:|=*")
  else
    # 3 or more characters: Add substring/fuzzy matching to prefix matching in a single pass
    reply=("m:{a-z}={A-Z} l:|=* r:|=*")
  fi
'

# Cache completions (avoids re-generating on every shell start)
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path "$HOME/.zcompcache"

# Show . and .. in directory completions
zstyle ':completion:*' special-dirs true

# Coloured ls-style output in file completions
zstyle ':completion:*:default' list-colors "${(s.:.)LS_COLORS}"

# Verbose descriptions above each completion group
zstyle ':completion:*:descriptions' format '%B%d%b'

# ── Lazy completions ──────────────────────────────────────────────────────────

# bun completions — lazy: load on first `bun` call, not every shell start
bun() {
  unfunction bun 2>/dev/null
  _cached_init bun completions
  command bun "$@"
}
