# Git aliases extracted from oh-my-zsh git plugin
# Kept here so they survive the OMZ → starship migration.
# Source this from .zshrc.

# ── Helper functions ──────────────────────────────────────────────────────────
# These back the aliases below that reference "current branch" or "main branch".

# Runs git with locking disabled — safe to call in prompts/scripts
function __git_prompt_git() {
  GIT_OPTIONAL_LOCKS=0 command git "$@"
}

# Prints the name of the current branch (e.g. "main", "feature/foo")
function git_current_branch() {
  local ref
  ref=$(__git_prompt_git symbolic-ref --quiet HEAD 2>/dev/null)
  local ret=$?
  if [[ $ret != 0 ]]; then
    [[ $ret == 128 ]] && return  # not in a git repo
    ref=$(__git_prompt_git rev-parse --short HEAD 2>/dev/null) || return
  fi
  echo ${ref#refs/heads/}
}

# Prints "main", "master", "trunk" etc — whichever the repo uses as default
function git_main_branch() {
  command git rev-parse --git-dir &>/dev/null || return
  local remote ref
  for ref in refs/{heads,remotes/{origin,upstream}}/{main,trunk,mainline,default,stable,master}; do
    if command git show-ref -q --verify $ref; then
      echo ${ref:t}
      return 0
    fi
  done
  echo master
  return 1
}

# Prints "develop", "dev", "devel" etc — whichever the repo uses
function git_develop_branch() {
  command git rev-parse --git-dir &>/dev/null || return
  local branch
  for branch in dev devel develop development; do
    if command git show-ref -q --verify refs/heads/$branch; then
      echo $branch
      return 0
    fi
  done
  echo develop
  return 1
}

# ── Aliases ───────────────────────────────────────────────────────────────────

alias g='git'

# add
alias ga='git add'
alias gaa='git add --all'
alias gapa='git add --patch'          # interactive/selective staging

# branch
alias gb='git branch'
alias gba='git branch --all'
alias gbd='git branch --delete'
alias gbD='git branch --delete --force'

# checkout
alias gco='git checkout'
alias gcb='git checkout -b'
alias gcm='git checkout $(git_main_branch)'
alias gcd='git checkout $(git_develop_branch)'

# clone
alias gcl='git clone --recurse-submodules'

# commit
alias gc='git commit --verbose'
alias gcmsg='git commit --message'
alias gca!='git commit --verbose --all --amend'
alias gcan!='git commit --verbose --all --no-edit --amend'

# diff
alias gd='git diff'
alias gds='git diff --staged'
alias gdw='git diff --word-diff'
alias gdup='git diff @{upstream}'

# fetch
alias gf='git fetch'
alias gfo='git fetch origin'
alias gfa='git fetch --all --tags --prune'

# log
alias glog='git log --oneline --decorate --graph'
alias gloga='git log --oneline --decorate --graph --all'
alias glol='git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset"'

# merge
alias gm='git merge'
alias gma='git merge --abort'

# pull / push
alias gl='git pull'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gpf!='git push --force'
alias ggpull='git pull origin "$(git_current_branch)"'
alias ggpush='git push origin "$(git_current_branch)"'

# rebase
alias grb='git rebase'
alias grba='git rebase --abort'
alias grbc='git rebase --continue'
alias grbi='git rebase --interactive'
alias grbs='git rebase --skip'

# reset
alias grh='git reset'
alias grhh='git reset --hard'
alias grhs='git reset --soft'

# show / blame
alias gsh='git show'
alias gbl='git blame -w'

# stash
alias gsta='git stash push'
alias gstp='git stash pop'
alias gstl='git stash list'
alias gstd='git stash drop'
alias gstaa='git stash apply'
alias gstu='git stash push --include-untracked'

# status
alias gst='git status'
alias gss='git status --short'
alias gsb='git status --short --branch'

# misc
alias grt='cd "$(git rev-parse --show-toplevel || echo .)"'  # cd to repo root
alias gfg='git ls-files | grep'                               # grep tracked files
