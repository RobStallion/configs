# fzf is installed and used via fzf-lua in nvim (<leader>ff, <leader>sg, etc.).
# Shell integration (Ctrl+R, Ctrl+T, Alt+C) is wired up below — see ADR-006.

# Default file search — rg respects .gitignore, surfaces hidden files.
# fzf-lua's files picker inherits this when no explicit cmd is set.
export FZF_DEFAULT_COMMAND='rg --files --hidden --glob "!.git"'

# ── Shell integration ────────────────────────────────────────────────────────
# Wires Ctrl+R (fuzzy history), Ctrl+T (file picker), Alt+C (cd picker).
# Cached the same way as brew/starship init to avoid a subprocess on every
# shell start. Cache regenerates when the fzf binary updates.
_fzf_cache="$HOME/.cache/zsh_fzf_init"
_fzf_bin=$(command -v fzf)
if [[ -n "$_fzf_bin" ]]; then
  if [[ ! -f "$_fzf_cache" || "$_fzf_bin" -nt "$_fzf_cache" ]]; then
    mkdir -p "$HOME/.cache"
    "$_fzf_bin" --zsh > "$_fzf_cache"
  fi
  source "$_fzf_cache"
fi
unset _fzf_cache _fzf_bin

# Per-binding opts (kept out of FZF_DEFAULT_OPTS so fzf-lua isn't polluted with
# shell-only opts like preview windows).
# Ctrl+R — history: no preview, exact-match for fewer false hits.
export FZF_CTRL_R_OPTS="--no-preview --sort --exact"
# Ctrl+T — file picker: bat preview on the right.
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers {}' --preview-window right:55%"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
# Alt+C — directory picker: tree preview.
export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --icons=auto {}' --preview-window right:55%"
