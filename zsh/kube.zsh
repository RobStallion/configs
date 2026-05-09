# Kubernetes aliases + helpers.

alias k="kubectl"

# Cached kubectl completion. Without this, `kubectl get <Tab>` and friends
# don't expand resources/namespaces. kubectl is managed by mise; resolve via
# `command -v` and cache the generated init to skip a fork on each shell.
# `compdef k=kubectl` reuses the same completion for the `k` alias.
_kctl_cache="$HOME/.cache/zsh_kubectl_init"
_kctl_bin=$(command -v kubectl)
if [[ -n "$_kctl_bin" ]]; then
  if [[ ! -f "$_kctl_cache" || "$_kctl_bin" -nt "$_kctl_cache" ]]; then
    mkdir -p "$HOME/.cache"
    "$_kctl_bin" completion zsh > "$_kctl_cache"
  fi
  source "$_kctl_cache"
  compdef k=kubectl
fi
unset _kctl_cache _kctl_bin

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

# set kube namespace
function kns() {
  local ctx ns nsExists
  ctx=$(kubectl config current-context)
  ns=$1

  if [[ -z "$ns" ]]; then
    echo "usage: kns <namespace>" >&2
    return 1
  fi

  # verify that the namespace exists
  nsExists=$(kubectl get namespace "$ns" --no-headers --output=go-template={{.metadata.name}} 2>/dev/null)
  if [[ -z "$nsExists" ]]; then
    echo "Namespace ($ns) not found" >&2
    return 1
  fi

  kubectl config set-context "${ctx}" --namespace="${ns}"
  echo "Namespace set to $ns"
}