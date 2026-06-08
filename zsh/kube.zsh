# Kubernetes aliases + helpers.

alias k="kubectl"

# Cached kubectl completion. Without this, `kubectl get <Tab>` and friends
# don't expand resources/namespaces. `compdef k=kubectl` reuses the same
# completion for the `k` alias.
_cached_init kubectl completion zsh && compdef k=kubectl

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

# ── Completion for kns ────────────────────────────────────────────────────────
_kns_complete() {
  local cache_file="${HOME}/.zcompcache/kns_namespaces"
  local -a namespaces
  local cache_valid=false

  if [[ -f "$cache_file" ]]; then
    zmodload -F zsh/stat b:zstat 2>/dev/null
    zmodload -F zsh/datetime b:strftime 2>/dev/null
    local -A file_info
    if zstat -H file_info "$cache_file" 2>/dev/null; then
      if (( EPOCHSECONDS - file_info[mtime] < 300 )); then
        cache_valid=true
      fi
    fi
  fi

  if [[ "$cache_valid" == "true" ]]; then
    namespaces=( ${(f)"$(cat "$cache_file")"} )
  else
    if command -v kubectl >/dev/null; then
      namespaces=( $(kubectl get namespaces -o jsonpath='{.items[*].metadata.name}' 2>/dev/null) )
      [[ ${#namespaces[@]} -gt 0 ]] && printf "%s\n" "${namespaces[@]}" > "$cache_file"
    fi
  fi
  _describe -t namespaces 'namespaces' namespaces
}
compdef _kns_complete kns