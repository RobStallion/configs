# Initialise completion system
# -d: use explicit dumpfile path so we can track it
autoload -Uz compinit && compinit -d "$HOME/.zcompdump"

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
