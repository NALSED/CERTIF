## Configuration de `kubectl`

Prérequis (RHEL) :

````
sudo dnf install -y bash-completion
````

À ajouter en fin de `~/.bashrc`, **sur les trois VM** (master + workers) :

````
# --- kubectl ---
source <(kubectl completion bash)
alias k=kubectl
complete -o default -F __start_kubectl k
````
