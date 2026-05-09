# fzf configuration.

export FZF_DEFAULT_COMMAND='rg --files --hidden --glob "!.git"'
export FZF_DEFAULT_OPTS="--preview='bat --color=always --style=numbers {}' --bind up:preview-up,down:preview-down -m --preview-window right:60%"
