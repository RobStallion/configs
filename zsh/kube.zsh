# Kubernetes aliases + helpers.

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