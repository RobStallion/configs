# fzf is installed and used via fzf-lua in nvim (<leader>ff, <leader>sg, etc.).
# Shell integration (Ctrl+R, Ctrl+T, Alt+C) is not configured — see ADR-006.

# Default file search — rg respects .gitignore, surfaces hidden files.
# fzf-lua's files picker inherits this when no explicit cmd is set.
export FZF_DEFAULT_COMMAND='rg --files --hidden --glob "!.git"'
