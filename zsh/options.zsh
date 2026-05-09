# History
HISTSIZE=50000
SAVEHIST=10000
HISTFILE="$HOME/.zsh_history"
setopt share_history          # share history across sessions
setopt hist_ignore_dups       # don't record duplicate consecutive commands
setopt hist_ignore_space      # don't record commands starting with a space
setopt hist_verify            # expand !! before executing, don't run immediately
setopt extended_history       # record timestamp with each command

# Directory navigation
setopt auto_cd                # type a dir name to cd into it
setopt auto_pushd             # cd pushes to directory stack
setopt pushd_ignore_dups      # don't push duplicates onto the stack
setopt pushdminus             # swap + and - meanings for pushd (feels more natural)

# Misc
setopt interactivecomments    # allow # comments in interactive shell
setopt multios                # allow multiple redirections: cmd > f1 > f2
setopt long_list_jobs         # show PID when listing jobs

# ── Directory shortcuts ───────────────────────────────────────────────────────
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias -- -='cd -'             # - goes to previous directory

# ── Common ────────────────────────────────────────────────────────────────────
alias l='ls -lah'
alias md='mkdir -p'

# Makes a directory and cd into it
function take() {
  mkdir -p "$1" && cd "$1"
}
