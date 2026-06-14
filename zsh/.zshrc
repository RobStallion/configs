# ── Modules ───────────────────────────────────────────────────────────────────
source ~/.config/zsh/lib.zsh       # FIRST: _cached_init helper used by mise/fzf/kube/starship
source ~/.config/zsh/mise.zsh      # sets up PATH via mise activate; all tools below depend on this
source ~/.config/zsh/options.zsh
source ~/.config/zsh/completions.zsh # before kube.zsh: runs compinit; kube.zsh calls compdef which requires it
source ~/.config/zsh/keybindings.zsh
source ~/.config/zsh/aliases.zsh
source ~/.config/zsh/git-aliases.zsh
source ~/.config/zsh/kube.zsh
source ~/.config/zsh/fzf.zsh
source ~/.config/zsh/claude.zsh
source ~/.config/zsh/claude-wrapper.zsh  # defines the `c` function
source ~/.config/zsh/theme.zsh
source ~/.config/zsh/tmux.zsh
source ~/.config/zsh/.zsh_secrets   # API keys etc. (gitignored, sourced via the symlinked dir)
source ~/.config/zsh/plugins.zsh    # LAST: fast-syntax-highlighting and zsh-autosuggestions wrap ZLE widgets

# ── Prompt ────────────────────────────────────────────────────────────────────
# Cached starship init. Plain `eval "$(starship init zsh)"` spawns a subprocess
# every shell start (~10ms). Cache regenerates when the starship binary updates.
_cached_init starship init zsh
