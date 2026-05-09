# Emacs key bindings (Ctrl+A/E, Ctrl+R, etc.)
bindkey -e

# Arrow keys search history by prefix typed so far
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search    # up arrow
bindkey "^[[B" down-line-or-beginning-search  # down arrow

# Home / End
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line

# Shift+Tab — reverse through completion menu
bindkey "^[[Z" reverse-menu-complete

# Ctrl+arrows — jump word
bindkey "^[[1;5C" forward-word   # Ctrl+right
bindkey "^[[1;5D" backward-word  # Ctrl+left

# Space expands history (!! → last command)
bindkey " " magic-space

# Ctrl+X Ctrl+E — edit command line in $EDITOR
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey "^X^E" edit-command-line

# Bracketed paste — paste text literally (no accidental execution)
autoload -Uz bracketed-paste-magic
zle -N bracketed-paste bracketed-paste-magic

# URL quoting — auto-escape URLs when pasted
autoload -Uz url-quote-magic
zle -N self-insert url-quote-magic
