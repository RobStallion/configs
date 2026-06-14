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

# switch kubernetes context and/or namespace
function kc() {
  local arg1=$1
  local arg2=$2

  if [[ -z "$arg1" ]]; then
    local current_context current_namespace
    current_context=$(kubectl config current-context 2>/dev/null)
    if [[ -z "$current_context" ]]; then
      echo "No current Kubernetes context set" >&2
      return 1
    fi
    current_namespace=$(kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null)
    [[ -z "$current_namespace" ]] && current_namespace="default"
    echo "Context: $current_context"
    echo "Namespace: $current_namespace"
    return 0
  fi

  local -a contexts
  if command -v kubectl >/dev/null; then
    contexts=( $(kubectl config get-contexts -o name 2>/dev/null) )
  fi

  if [[ -n "$arg2" ]]; then
    # Two arguments: kc <context> <namespace>
    if (( ! contexts[(I)$arg1] )); then
      echo "Context ($arg1) not found" >&2
      return 1
    fi
    kubectl config use-context "$arg1" || return 1
    local nsExists
    nsExists=$(kubectl get namespace "$arg2" --no-headers --output=go-template={{.metadata.name}} 2>/dev/null)
    if [[ -z "$nsExists" ]]; then
      echo "Namespace ($arg2) not found in context ($arg1)" >&2
      return 1
    fi
    kubectl config set-context "$arg1" --namespace="$arg2"
    echo "Switched to context $arg1, namespace $arg2"
  else
    # One argument: kc <context-or-namespace>
    # 1. Is it a context?
    if (( contexts[(I)$arg1] )); then
      kubectl config use-context "$arg1"
      return $?
    fi

    # 2. Is it a namespace in the current context?
    local current_context
    current_context=$(kubectl config current-context 2>/dev/null)
    if [[ -n "$current_context" ]]; then
      local nsExists
      nsExists=$(kubectl get namespace "$arg1" --no-headers --output=go-template={{.metadata.name}} 2>/dev/null)
      if [[ -n "$nsExists" ]]; then
        kubectl config set-context "${current_context}" --namespace="${arg1}"
        echo "Namespace set to $arg1"
        return 0
      fi
    fi

    echo "Argument ($arg1) is neither a valid context nor a namespace in the current context." >&2
    return 1
  fi
}

alias kns="kc"

# ── Completion for kc / kns ──────────────────────────────────────────────────
_kc_complete() {
  local cache_file="${HOME}/.cache/kns_namespaces"
  local -a namespaces contexts
  local cache_valid=false

  if command -v kubectl >/dev/null; then
    contexts=( $(kubectl config get-contexts -o name 2>/dev/null) )
  fi

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
      if [[ ${#namespaces[@]} -gt 0 ]]; then
        mkdir -p "${cache_file:h}"
        printf "%s\n" "${namespaces[@]}" > "$cache_file"
      fi
    fi
  fi

  if (( CURRENT == 2 )); then
    _describe -t contexts 'contexts' contexts
    _describe -t namespaces 'namespaces' namespaces
  elif (( CURRENT == 3 )); then
    _describe -t namespaces 'namespaces' namespaces
  fi
}
compdef _kc_complete kc kns