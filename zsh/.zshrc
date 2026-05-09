# ── Modules ───────────────────────────────────────────────────────────────────
source ~/.config/zsh/options.zsh
source ~/.config/zsh/completions.zsh
source ~/.config/zsh/keybindings.zsh
source ~/.config/zsh/git-aliases.zsh
source ~/.config/zsh/kube.zsh
source ~/.config/zsh/fzf.zsh
source ~/.config/zsh/claude.zsh

# ── nvim ──────────────────────────────────────────────────────────────────────
alias v="nvim -O"
alias vtv="v ~/.tool-versions"

# ── zshrc ─────────────────────────────────────────────────────────────────────
alias vz="v ~/.zshrc"
alias sz='. ~/.zshrc'

# ── rest ──────────────────────────────────────────────────────────────────────
alias xx="exit"
alias s="open -a SourceTree ."
alias z="zed ."

# ── Functions ─────────────────────────────────────────────────────────────────

# Opens the github page for a given repo (renamed from `gh` to avoid
# shadowing the GitHub CLI if it ever gets installed).
function gho() {
  # check if we pass in a remote
  url=$(git config remote.$1.url)
  if [ -n "$url" ]; then
    open $url
    return
  fi

  open $(git config remote.origin.url)
  return
}

# bun completions — lazy: load on first `bun` call, not every shell start
# (PATH for bun is set in .zprofile)
bun() {
  unfunction bun 2>/dev/null
  [ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
  command bun "$@"
}

# ── uv ────────────────────────────────────────────────────────────────────────
alias uvsh='source .venv/bin/activate'

# ── Secrets ───────────────────────────────────────────────────────────────────
# API keys etc. live in zsh/.zsh_secrets (gitignored, sourced via the symlinked dir).
[ -f ~/.config/zsh/.zsh_secrets ] && source ~/.config/zsh/.zsh_secrets

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
