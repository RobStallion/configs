# ── Modules ───────────────────────────────────────────────────────────────────
source ~/.config/zsh/mise.zsh      # FIRST: sets up PATH via mise activate; all tools below depend on this
source ~/.config/zsh/options.zsh
source ~/.config/zsh/completions.zsh # before kube.zsh: runs compinit; kube.zsh calls compdef which requires it
source ~/.config/zsh/keybindings.zsh
source ~/.config/zsh/aliases.zsh
source ~/.config/zsh/git-aliases.zsh
source ~/.config/zsh/kube.zsh
source ~/.config/zsh/fzf.zsh
source ~/.config/zsh/claude.zsh
source ~/.config/zsh/tmux.zsh
source ~/.config/zsh/.zsh_secrets   # API keys etc. (gitignored, sourced via the symlinked dir)
source ~/.config/zsh/plugins.zsh    # LAST: fast-syntax-highlighting and zsh-autosuggestions wrap ZLE widgets

# ── Prompt ────────────────────────────────────────────────────────────────────
# Cached starship init. Plain `eval "$(starship init zsh)"` spawns a subprocess
# every shell start (~10ms). Cache regenerates when the starship binary updates.
_starship_cache="$HOME/.cache/zsh_starship_init"
_starship_bin=$(command -v starship)
if [[ -n "$_starship_bin" ]]; then
  if [[ ! -f "$_starship_cache" || "$_starship_bin" -nt "$_starship_cache" ]]; then
    mkdir -p "$HOME/.cache"
    "$_starship_bin" init zsh > "$_starship_cache"
  fi
  source "$_starship_cache"
fi
unset _starship_cache _starship_bin
