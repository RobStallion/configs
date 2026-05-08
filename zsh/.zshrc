# Homebrew - must be early so user bins can override
eval "$(/opt/homebrew/bin/brew shellenv)"

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"

plugins=(git)

source $ZSH/oh-my-zsh.sh

# FZF
export FZF_DEFAULT_COMMAND='rg --files --hidden --glob "!.git"'
export FZF_DEFAULT_OPTS="--preview='bat --color=always --style=numbers {}' --bind up:preview-up,down:preview-down -m --preview-window right:60%"


# vim & nvim
alias v="nvim -O"
# alias v="vim -O"
alias vvv="v ~/.vim/"
alias vtv="v ~/.tool-versions"

# commenting out for now but may come back to this in the future
# function v.() {
#     v $(fzf)
# }

# zshrc
alias vz="v ~/.zshrc"
alias sz='. ~/.zshrc'

# git
alias gbb="git branch | cat"
alias grau='git remote add upsteam'

# kube
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

# rest
alias xx="exit"
alias s="open -a SourceTree ."
alias z="zed ."
alias zz="zed ~/.zshrc"

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

# deno
. "/Users/robertfrancis/.deno/env"

# bun
export BUN_INSTALL="$HOME/.bun"
# add bun to PATH if it isn't added yet
case ":${PATH}:" in
    *:"$BUN_INSTALL/bin":*)
        ;;
    *)
        # Prepending path in case a system-installed bun needs to be overridden
        export PATH="$BUN_INSTALL/bin:$PATH"
        ;;
esac
# bun completions
[ -s "/Users/robertfrancis/.bun/_bun" ] && source "/Users/robertfrancis/.bun/_bun"

# asdf
# add asdf shims to PATH if they aren't added yet
case ":${PATH}:" in
    *:"$HOME/.asdf/shims":*)
        ;;
    *)
        # Prepending path in case system-installed binaries need to be overridden
        export PATH="$HOME/.asdf/shims:$PATH"
        ;;
esac

# cargo
# add cargo to PATH if it isn't added yet
case ":${PATH}:" in
    *:"$HOME/.cargo/bin":*)
        ;;
    *)
        # Appending path in case system-installed binaries need to be overridden
        export PATH="$PATH:$HOME/.cargo/bin"
        ;;
esac

# uv
. "$HOME/.local/bin/env"
alias uvsh='source .venv/bin/activate'

export LITE_LLM_API_KEY='sk-Mz2oWnVIrIgFXboTp4F-Mg'

# Claude
export ANTHROPIC_AUTH_TOKEN='sk-Mz2oWnVIrIgFXboTp4F-Mg'
export ANTHROPIC_BASE_URL='https://litellm.external-ai.rvu.cloud'

export CLAUDE_CODE_EFFORT_LEVEL='max'
export ANTHROPIC_MODEL='opusplan'

# export ANTHROPIC_DEFAULT_HAIKU_MODEL=rvu-default-haiku
# export ANTHROPIC_DEFAULT_SONNET_MODEL=rvu-default-sonnet
# export ANTHROPIC_DEFAULT_OPUS_MODEL=rvu-default-opus
# export ANTHROPIC_DEFAULT_OPUS_MODEL='claude-opus-4-6'

export CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1
# export CAVEMAN_DEFAULT_MODE='ultra'

# dbt
# export DBT_PROJECT_DIR="./dbt"
#
