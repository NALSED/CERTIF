## Récapitulatif des commandes de gestion de Kubernetes

---

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

----

=== VÉRIFIER LA PRÉSENCE DE CRICTL ===

- Contrôle que le client CRI est installé sur le node, et l'installe si besoin.

- Use-Case : premier réflexe avant toute investigation runtime sur un worker.
````
crictl --version
sudo apt install -y cri-tools
````

----

=== CONFIGURER CRICTL ===

- Déclare le socket containerd, sans quoi chaque commande sort un warning.

- Use-Case : rendre crictl utilisable sur un node fraîchement installé.
````
sudo vim /etc/crictl.yaml
````

----

=== LISTER LES SANDBOX (CRICTL) ===

- Affiche les Pods au niveau du runtime, sans passer par l'API server.

- Use-Case : voir les Pods d'un worker quand le control plane est injoignable.
````
sudo crictl pods
````

----

=== LISTER LES IMAGES EN CACHE (CRICTL) ===

- Montre les images réellement présentes sur le node.

- Use-Case : vérifier qu'une image est bien pullée avant de chercher ailleurs.
````
sudo crictl images
````

----

=== ANALYSER LE KUBELET ===

- État du service et journal systemd de l'agent du node.

- Use-Case : diagnostiquer un node NotReady.
````
sudo systemctl status kubelet
sudo journalctl -u kubelet
````

----

=== INSTALLER LE METRICS SERVER ===

- Déploie le collecteur de métriques CPU/RAM, absent d'une installation kubeadm.

- Use-Case : prérequis à `kubectl top` et à l'autoscaling HPA.
````
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
````

----

=== DÉBLOQUER LE METRICS SERVER (TLS) ===

- Ajoute --kubelet-insecure-tls aux args, sinon le Pod reste 0/1 Running.

- Use-Case : lab kubeadm où les certificats kubelet sont auto-signés.
````
kubectl -n kube-system edit deployment metrics-server
# sous spec.template.spec.containers[].args, ajouter :
#   - --kubelet-insecure-tls
````

----

=== CONSOMMATION DES NODES ET DES PODS ===

- Affiche CPU et mémoire réellement consommés, via le metrics-server.

- Use-Case : repérer le node ou le Pod qui sature.
````
kubectl top nodes
kubectl top pods -A
````

----

=== INSTALLER ETCDCTL ===

- Le client etcd n'est pas fourni avec les paquets Kubernetes.

- Use-Case : premier pas avant toute sauvegarde d'etcd.
````
sudo apt install etcd-client
````

----

=== RETROUVER LES PARAMÈTRES D'ETCD ===

- Donne endpoints, cacert, cert et key depuis la ligne de commande du process.

- Use-Case : construire la commande etcdctl sans chercher dans les manifests.
````
ps aux | grep etcd

ls /etc/kubernetes/pki/etcd
````

----

=== FORCER L'API V3 D'ETCDCTL ===

- Impose la V3 de l'API, la seule qui gère les snapshots.

- Use-Case : lever toute ambiguïté sur une version d'etcdctl ancienne.
````
ETCDCTL_API=3 <COMMANDE>
````

----

=== SAUVEGARDER ETCD ===

- Écrit un snapshot complet de la base du cluster.

- Use-Case : avant un upgrade, ou question classique de l'examen.
````
sudo etcdctl --endpoints=https://127.0.0.1:2379 \
--cacert=/etc/kubernetes/pki/etcd/ca.crt \
--cert=/etc/kubernetes/pki/etcd/server.crt \
--key=/etc/kubernetes/pki/etcd/server.key \
snapshot save /tmp/EtcdBackUp.db
````

----

=== LISTER LES CLÉS D'ETCD ===

- Parcourt le keyspace en n'affichant que les clés, sans les valeurs.

- Use-Case : vérifier que la base répond avant de lancer le snapshot.
````
sudo etcdctl --endpoints=https://127.0.0.1:2379 \
--cacert=/etc/kubernetes/pki/etcd/ca.crt \
--cert=/etc/kubernetes/pki/etcd/server.crt \
--key=/etc/kubernetes/pki/etcd/server.key \
get / --prefix --keys-only
````

----

=== VÉRIFIER UN SNAPSHOT ETCD ===

- Affiche hash, révision, nombre de clés et taille du snapshot.

- Use-Case : confirmer qu'une sauvegarde est exploitable. etcdutl remplace etcdctl, déprécié pour cet usage.
````
sudo etcdctl --write-out=table snapshot status /tmp/EtcdBackUp.db

sudo etcdutl snapshot status /tmp/EtcdBackUp.db
````

----

=== RESTAURER UN SNAPSHOT ETCD ===

- Remonte la base dans un data-dir neuf, static Pods arrêtés le temps de l'opération.

- Use-Case : récupérer un control plane après une corruption d'etcd.
````
sudo mv /etc/kubernetes/manifests/*.yaml /etc/kubernetes/
sudo mv /var/lib/etcd /var/lib/etcd-old
sudo etcdctl snapshot restore /tmp/EtcdBackUp.db --data-dir /var/lib/etcd
sudo mv /etc/kubernetes/*.yaml /etc/kubernetes/manifests/
crictl ps
````
