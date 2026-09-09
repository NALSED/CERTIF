## Composition d'un Node

---

`=== Kubelet ===`

- Agent qui exécute les Pods qu'on lui assigne. Seul composant du control plane qui n'est pas un Pod : c'est un service systemd classique.

   - Il s'enregistre auprès de l'API server et remonte l'état du nœud.
   - Il reçoit les PodSpecs qui lui sont assignés par le scheduler, et demande au runtime (containerd) de créer les conteneurs correspondants.
   - Il surveille en boucle l'état réel des Pods et le compare à l'état désiré. Écart => il corrige.
   - Il exécute les probes (liveness, readiness, startup) et applique les actions associées.
   - Il surveille `/etc/kubernetes/manifests/` et démarre les Pods statiques qu'il y trouve, sans passer par l'API server.

````
/var/lib/kubelet/config.yaml      # configuration du kubelet
/etc/kubernetes/kubelet.conf      # kubeconfig pour joindre l'API server
/etc/kubernetes/manifests/        # répertoire des Pods statiques
````

````
sudo systemctl status kubelet
sudo journalctl -u kubelet -f
````

---

`=== Container Runtime (containerd) ===`

- Service systemd. Reçoit les ordres du kubelet via l'interface CRI et gère réellement les conteneurs : pull des images, création, démarrage, arrêt.

````
sudo systemctl status containerd
sudo crictl ps          # conteneurs en cours
sudo crictl images      # images présentes
````

---

`=== Kube-proxy ===`

- DaemonSet, donc présent sur chaque nœud. Traduit les ClusterIP des Services vers les IP réelles des Pods, via iptables ou IPVS.
- Ne transporte pas le trafic : il écrit les règles de routage.

---

`=== CNI (calico-node) ===`

- DaemonSet, présent sur chaque nœud. Attribue les IP aux Pods depuis la tranche `/24` allouée au nœud, et assure la connectivité Pod <=> Pod.
- Sans CNI, le nœud reste `NotReady` et les Pods en `Pending`.

````
/etc/cni/net.d/         # configuration CNI
/opt/cni/bin/           # binaires des plugins
````

---

### Spécifique au `control plane`

Ces 4 composants tournent en **Pods statiques**, démarrés par le kubelet depuis
`/etc/kubernetes/manifests/` :

`=== kube-apiserver ===`
- Point d'entrée unique du cluster. Valide les requêtes et persiste dans etcd.
- Seul composant à parler directement à etcd.

`=== etcd ===`
- Base clé/valeur qui stocke tout l'état du cluster.
- Objet des questions backup/restore à l'examen (`etcdctl snapshot save` / `restore`).

`=== kube-scheduler ===`
- Décide sur quel nœud placer chaque Pod non encore assigné.

`=== kube-controller-manager ===`
- Boucles de réconciliation : maintient l'état réel aligné sur l'état désiré
  (réplicas, nœuds, endpoints, ServiceAccounts...).

````
ls /etc/kubernetes/manifests/
# etcd.yaml  kube-apiserver.yaml  kube-controller-manager.yaml  kube-scheduler.yaml
````

---
