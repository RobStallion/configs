# Two standalone zsh plugins (no framework needed):
#
#   fast-syntax-highlighting — live coloring of the command line. Valid commands
#     show green, invalid red, strings yellow, etc. Catches typos before Enter.
#   zsh-autosuggestions     — ghost text from history while you type. Press →
#     to accept the suggestion, Ctrl+E to accept and edit.
#
# Load order matters: fast-syntax-highlighting MUST come before
# zsh-autosuggestions, otherwise their ZLE widget overrides clobber each other
# (autosuggestions wraps the same widgets and expects them already wrapped).

_fsh="/opt/homebrew/opt/zsh-fast-syntax-highlighting/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
[[ -f "$_fsh" ]] && source "$_fsh"
unset _fsh

_zas="/opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
[[ -f "$_zas" ]] && source "$_zas"
unset _zas
