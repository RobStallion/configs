# Initialise completion system.
# -d: use explicit dumpfile path so we can track it.
# Fast path: if the dump is fresh (modified <24h ago), skip compinit's
# security/audit walk via -C. Otherwise run a full compinit to refresh it.
# The (#qN.mh-24) glob qualifier matches the file only if mtime is within
# the last 24 hours; empty result = stale, so we run the full check.
autoload -Uz compinit
if [[ -n "$HOME/.zcompdump"(#qN.mh-24) ]]; then
  compinit -C -d "$HOME/.zcompdump"
else
  compinit -d "$HOME/.zcompdump"
fi

# Also enable bash-style completions (needed by some tools)
autoload -Uz bashcompinit && bashcompinit

# ── Completion behaviour ──────────────────────────────────────────────────────

# Tab opens a menu when multiple matches exist
zstyle ':completion:*' menu select

# Case-insensitive matching
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# Cache completions (avoids re-generating on every shell start)
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path "$HOME/.zcompcache"

# Show . and .. in directory completions
zstyle ':completion:*' special-dirs true

# Coloured ls-style output in file completions
zstyle ':completion:*:default' list-colors "${(s.:.)LS_COLORS}"

# Verbose descriptions above each completion group
zstyle ':completion:*:descriptions' format '%B%d%b'
