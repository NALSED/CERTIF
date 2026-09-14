## Récapitulatif des commandes de gestion de Kubernetes

=== GÉNÉRER UN MANIFESTE SANS CRÉER LA RESSOURCE ===

- Produit le YAML d'une ressource sans rien créer dans le cluster.

- Use-Case : fabriquer le squelette d'un Static Pod depuis le master avant de le copier sur un worker.
````
kubectl run <NOM> --image=<IMAGE> --dry-run=client -o yaml > $HOME/static.yaml
````

----

=== EMPLACEMENT DES STATIC PODS ===

- Répertoire surveillé par le kubelet ; tout .yaml déposé ici devient un Pod.

- Use-Case : créer un Static Pod sur un worker, ou consulter les 4 Pods du control plane.
````
sudo vim /etc/kubernetes/manifests/<NOM>.yaml
ls /etc/kubernetes/manifests/
````

----

=== CHEMIN DES STATIC PODS (KUBELET) ===

- Le répertoire des manifests est défini par staticPodPath dans la config du kubelet.

- Use-Case : déplacer le répertoire des Static Pods.
````
sudo vim /var/lib/kubelet/config.yaml
sudo systemctl restart kubelet
````

----

=== REDÉMARRER LE KUBELET ===

- Relit la configuration et le répertoire des manifests.

- Use-Case : faire prendre en compte un Static Pod tout juste déposé.
````
sudo systemctl restart kubelet
````

----

=== LISTER LES CONTENEURS (CRICTL) ===

- Voit les conteneurs directement au niveau du runtime, sans l'API server.

- Use-Case : vérifier sur le worker qu'un Static Pod tourne réellement.
````
sudo crictl ps
````

----

=== INSPECTER UN CONTENEUR (CRICTL) ===

- Détaille un conteneur : nom, image, sandbox, namespace.

- Use-Case : confirmer qu'un conteneur appartient bien au Static Pod attendu.
````
sudo crictl inspect <CONTAINER_ID>
````

----

=== CORDON ===

- Met un node en quarantaine : plus aucun nouveau Pod n'y sera planifié.

- Use-Case : investiguer sur un node sans que le Scheduler continue d'y placer des Pods.
````
kubectl cordon <NODE_NAME>
````

----

=== UNCORDON ===

- Lève la quarantaine et rend le node à nouveau schedulable.

- Use-Case : remettre le node en service après investigation.
````
kubectl uncordon <NODE_NAME>
````

----

=== VÉRIFIER L'ÉTAT ET LES TAINTS D'UN NODE ===

- Affiche le détail du node, dont le taint node.kubernetes.io/unschedulable.

- Use-Case : confirmer qu'un cordon a bien pris effet.
````
kubectl describe node <NODE_NAME> | less
````

----

=== DRAIN ===

- Comme cordon, plus l'éviction des Pods déjà en cours sur le node.

- Use-Case : vider un node avant une maintenance ou un upgrade.
````
kubectl drain <NODE_NAME> --ignore-daemonsets
````
