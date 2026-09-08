## Configuration de `kubectl`

Prérequis (RHEL) :

````
sudo dnf install -y bash-completion
````

À ajouter en fin de `~/.bashrc`, **sur les trois VM** (master + workers) :

````
sudo vim ~/.bashrc
````
````
# --- kubectl ---
#-1-
source <(kubectl completion bash)
#-2-
alias k=kubectl
#-3-
complete -o default -F __start_kubectl k
````
- Explication
   
   - -1- Charge la complétion pour `kubectl`

   - -2- Rattache la complétion à l'alias `k`.

   - -3- Sans cette ligne, la touche TAB ne fonctionne pas sur `k`.
