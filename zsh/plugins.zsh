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

_zas="/opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
[[ -f "$_zas" ]] && source "$_zas"
unset _zas

_fsh="/opt/homebrew/opt/zsh-fast-syntax-highlighting/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
[[ -f "$_fsh" ]] && source "$_fsh"
unset _fsh
