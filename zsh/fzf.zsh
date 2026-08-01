# fzf is installed and used via fzf-lua in nvim (<leader>ff, <leader>sg, etc.).
# Shell integration (Ctrl+R, Ctrl+T, Alt+C) is wired up below — see ADR-006.

# Default file search — rg respects .gitignore, surfaces hidden files.
# fzf-lua's files picker inherits this when no explicit cmd is set.
export FZF_DEFAULT_COMMAND='rg --files --hidden --glob "!.git"'

# ── Shell integration ────────────────────────────────────────────────────────
# Wires Ctrl+R (fuzzy history), Ctrl+T (file picker), Alt+C (cd picker).
# Cached to avoid a subprocess on every shell start.
_cached_init fzf --zsh

# Per-binding opts (kept out of FZF_DEFAULT_OPTS so fzf-lua isn't polluted with
# shell-only opts like preview windows).
# Ctrl+R — history: no preview, exact-match for fewer false hits.
export FZF_CTRL_R_OPTS="--no-preview --no-sort --exact"
# Ctrl+T — file picker: bat preview on the right.
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers {}' --preview-window right:55%"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
# Alt+C — directory picker: tree preview.
export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --icons=auto {}' --preview-window right:55%"

# Ctrl+F — fuzzy find file(s) and open in nvim.
# Tab selects multiple files; Enter opens all. --height keeps rg output visible above.
# Guarded against non-empty $BUFFER so a stray Ctrl+F mid-typing doesn't wipe input.
_fvim() {
  if [[ -n "$BUFFER" ]]; then
    zle -M "_fvim: clear the line first (^U)"
    return
  fi
  local -a files
  files=(${(f)"$(eval "$FZF_DEFAULT_COMMAND" | fzf \
    --preview 'bat --color=always --style=numbers {}' \
    --preview-window right:55% \
    --height 50% \
    --multi)"})
  if [[ ${#files} -gt 0 ]]; then
    local cmd="v"
    local f
    for f in "${files[@]}"; do
      cmd+=" ${(q)f}"
    done
    BUFFER=$cmd
    zle accept-line
  else
    zle reset-prompt
  fi
}
zle -N _fvim
bindkey '^f' _fvim
