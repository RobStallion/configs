# ── Modules ───────────────────────────────────────────────────────────────────
source ~/.config/zsh/options.zsh
source ~/.config/zsh/completions.zsh
source ~/.config/zsh/keybindings.zsh
source ~/.config/zsh/git-aliases.zsh

# ── FZF ───────────────────────────────────────────────────────────────────────
export FZF_DEFAULT_COMMAND='rg --files --hidden --glob "!.git"'
export FZF_DEFAULT_OPTS="--preview='bat --color=always --style=numbers {}' --bind up:preview-up,down:preview-down -m --preview-window right:60%"

# ── nvim ──────────────────────────────────────────────────────────────────────
alias v="nvim -O"
alias vtv="v ~/.tool-versions"

# ── zshrc ─────────────────────────────────────────────────────────────────────
alias vz="v ~/.zshrc"
alias sz='. ~/.zshrc'

# ── git ───────────────────────────────────────────────────────────────────────
alias gbb="git branch | cat"

# ── kube ──────────────────────────────────────────────────────────────────────
alias k="kubectl"

alias kg="kubectl get"
alias kd="kubectl describe"

alias kgi="kubectl get ing"
alias kdi="kubectl describe ing"

alias kgp="kubectl get pods"
alias kdp="kubectl describe pod"

alias kgd="kubectl get deployment"
alias kdd="kubectl describe deployment"

alias kgs="kubectl get service"
alias kds="kubectl describe service"

alias kgsa="kubectl get sa"
alias kdsa="kubectl describe sa"

alias kgc="kubectl get cronjob"
alias kdc="kubectl describe cronjob"

alias kc1="kubectl config use-context eks-01"
alias kc2="kubectl config use-context eks-02"

# ── rest ──────────────────────────────────────────────────────────────────────
alias xx="exit"
alias s="open -a SourceTree ."
alias z="zed ."
alias zz="zed ~/.zshrc"

# ── Functions ─────────────────────────────────────────────────────────────────

# Opens the github page for a given repo
function gh() {
  # check if we pass in a remote
  url=`git config remote.$1.url`
  if [ -n "$url" ]; then
    open $url
    return
  fi

  open `git config remote.origin.url`
  return
}

# set kube namespace
function kns() {
  ctx=`kubectl config current-context`
  ns=$1

  # verify that the namespace exists
  nsExists=`kubectl get namespace $ns --no-headers --output=go-template={{.metadata.name}} 2> /dev/null`
  if [ -z $nsExists ]; then
    echo "Namespace ($ns) not found, using recharge"
    ns="recharge"
  fi

  kubectl config set-context ${ctx} --namespace="${ns}"
  echo "Namespace set to $ns"
}

# set kube context
function kc() {
  kubectl config use-context "$1"
}

# bun completions — lazy: load on first `bun` call, not every shell start
# (PATH for bun is set in .zprofile)
bun() {
  unfunction bun
  [ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
  command bun "$@"
}

# ── uv ────────────────────────────────────────────────────────────────────────
alias uvsh='source .venv/bin/activate'

# ── Claude ────────────────────────────────────────────────────────────────────
export LITE_LLM_API_KEY='sk-Mz2oWnVIrIgFXboTp4F-Mg'

export ANTHROPIC_AUTH_TOKEN='sk-Mz2oWnVIrIgFXboTp4F-Mg'
export ANTHROPIC_BASE_URL='https://litellm.external-ai.rvu.cloud'

export CLAUDE_CODE_EFFORT_LEVEL='max'
export ANTHROPIC_MODEL='opusplan'

export ANTHROPIC_DEFAULT_HAIKU_MODEL='rvu-default-haiku'
export ANTHROPIC_DEFAULT_SONNET_MODEL='rvu-default-sonnet'
export ANTHROPIC_DEFAULT_OPUS_MODEL='rvu-default-opus'

export CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1

# ── Prompt ────────────────────────────────────────────────────────────────────
eval "$(starship init zsh)"
