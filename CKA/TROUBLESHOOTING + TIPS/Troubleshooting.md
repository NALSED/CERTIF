### `- montre les pods par namespace `
````
kubectl get pods -n kube-system
````

---
---

### `-Problème avec metrics-server`
````
# Install
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# TLS
kubectl -n kube-system edit deployment metrics-server
#Editer
spec:
  template:
    spec:
      containers:
      - args:
        - --kubelet-insecure-tls <========= Cette ligne
````

---
---

### `- Débug HA exemple`

- Au redémarrage impossible d'utiliser kubectl
````
E0922 05:38:37.453305    3095 memcache.go:381] "Couldn't get current server API group list" err="Get \"https://192.168.0.15:6443/api?timeout=32s\": EOF"
````

`Utiliser crictl`
````
sudo crictl ps -a

# Sortie de kube-apiserver
CONTAINER           IMAGE               CREATED             STATE               NAME                      ATTEMPT             POD ID              POD                                       NAMESPACE
3e47607d46a76       bec5f0e1e2eeb       2 minutes ago       Exited              kube-apiserver            16                  35f4b2c76a233       kube-apiserver-k8s-master                 kube-system
````

- Logs
````
crictl logs 3e47607d46a76 

# Extrait Sortie
E0922 05:44:05.716442       1 run.go:72] "command failed" err="failed to create listener: failed to listen on 0.0.0.0:6443: listen tcp 0.0.0.0:6443: bind: address already in use"
````

- vérification port
````
ss -tlnp | grep 6443

# Sortie
LISTEN 0      4096    192.168.0.15:6443       0.0.0.0:*    users:(("haproxy",pid=1345,fd=5))
````

- **Verdict** : Haproxy démarre plus vite que kube-apiserverdonc conflit de port

- **Solution** : dans `/etc/kubernetes/manifests/kube-apiserver.yaml` ajouter `- --bind-address=192.168.0.5`

---
---


### Conflit en HA, avec un corum etcd.

- A l'installation de etcdctl il est possible que Ubuntu instal etcd et l'active donc conflit pour le port 2379.

- utiliser `crictl`
````
sudo crictl ps -a | grep -E "apiserver|etcd"
````

-logs
````
sudo crictl logs <ID>

# Erreur trouvé
erreur trouvée : bind: address already in use sur 127.0.0.1:2379
````

- Identifier qui tient le port
````
sudo ss -tlnp | grep 2379
````

- Distinguer process k8s vs process natif
````
cat /proc/<PID>/cgroup

# Si besoin
sudo kill -9 <PID>
````


- Stopper `etcd` natif
````
sudo systemctl stop etcd
sudo systemctl disable etcd
sudo systemctl mask etcd
````

- restart `kublet`
````
sudo systemctl restart kublet
````

---
---


