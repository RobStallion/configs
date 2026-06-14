# Two standalone zsh plugins (no framework needed):
#
#   zsh-autosuggestions     — ghost text from history while you type. Press →
#     to accept the suggestion, Ctrl+E to accept and edit.
#   fast-syntax-highlighting — live coloring of the command line. Valid commands
#     show green, invalid red, strings yellow, etc. Catches typos before Enter.
#
# Load order matters: zsh-autosuggestions MUST come before
# fast-syntax-highlighting. FSH's README requires it be sourced last — it wraps
# ZLE's zle-line-pre-redraw and needs to be the outermost hook. Note: FSH does
# not color the autosuggestion ghost text regardless of order; that text is
# styled separately by ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE.

local brew_prefix="${HOMEBREW_PREFIX:-/opt/homebrew}"

local zas_paths=(
  "$brew_prefix/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
  "/usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
)
for p in "${zas_paths[@]}"; do
  if [[ -f "$p" ]]; then
    source "$p"
    break
  fi
done

local fsh_paths=(
  "$brew_prefix/opt/zsh-fast-syntax-highlighting/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
  "$brew_prefix/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
  "/usr/local/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
)
for p in "${fsh_paths[@]}"; do
  if [[ -f "$p" ]]; then
    source "$p"
    break
  fi
done
