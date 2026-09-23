## Lab 

---

<details>
<summary>
<h2>
SINGLE CONTROLE PLANE
</h2>
</summary>

### `-1-` Create à backup of etcd

### `-2-` Remove resources (Pods and/od Deployments)

### `-3-` Restor backup

---
!!! avant backup !!!
````
k create deploy nginx --image=nginx --replicas=3 
````

### `-1-` Create à backup of etcd et verrification
````
sudo ETCDCTL_API=3 etcdctl
\ --endpoints=https://127.0.0.1:2379
\ --cacert=/etc/kubernetes/pki/etcd/ca.crt
\ --cert=/etc/kubernetes/pki/etcd/server.crt
\ --key=server.key 

\ snaphot save /tmp/backup.db
````
````
sudo etcdutl --write-out=table snapshot status /tmp/backup.db

````

---

### `-2-` Remove resources (Pods and/od Deployments)
````
k delete deployment nginx
````
````
k get pods -o wide
# doit etre vide dans cette exercice
````
### `-3-` Restor backup
````
sudo mv /etc/kubernetes/manifests/*.yaml /etc/kubernetes/
````

````
sudo mv /var/lib/etcd /var/lib/etcd.old
````

````
ls -l /etc/kubernetes/
ls -l /etc/kubernetes/manifests/
````

````
ls -l /var/lib | grep etcd
````

- Si tout est ok
````
sudo etcdutl --data-dir /var/lib/etcd snapshot restore /tmp/backup.db
````

````
mv /etc/kubernetes/*.yaml /etc/kubernetes/manifests/
````

````
k get pods -o wide
````

````
NAME                     READY   STATUS    RESTARTS   AGE   IP              NODE          NOMINATED NODE   READINESS GATES
nginx-69b9cdbbdd-mm6m8   1/1     Running   0          51m   172.16.194.69   k8s-worker1   <none>           <none>
nginx-69b9cdbbdd-vghkt   1/1     Running   0          51m   172.16.126.7    k8s-worker2   <none>           <none>
nginx-69b9cdbbdd-vsd26   1/1     Running   0          51m   172.16.194.70   k8s-worker1   <none>           <none>
````

- FIN
````
k delete deploy nginx
````

</details>

---
---

<details>
<summary>
<h2>
MULTI CONTROLE PLANE
</h2>
</summary>

### `-1-` Create à backup of etcd

### `-2-` Remove resources (Pods and/od Deployments)

### `-3-` Restor backup

---
!!! avant backup !!!
````
k create deploy nginx --image=nginx --replicas=3 
````

### `-1-` Create à backup of etcd et verrification
````
sudo ETCDCTL_API=3 etcdctl
\ --endpoints=https://127.0.0.1:2379
\ --cacert=/etc/kubernetes/pki/etcd/ca.crt
\ --cert=/etc/kubernetes/pki/etcd/server.crt
\ --key=server.key snaps
hot save /tmp/backup.db
````
````
sudo etcdutl --write-out=table snapshot status /tmp/backup.db

````

---

### `-2-` Remove resources (Pods and/od Deployments)
````
k delete deployment nginx
````
````
k get pods -o wide
# doit etre vide dans cette exercice
````
### `-3-` Restor backup

⚠️ Ici la procédure est différente car chaque node garde une copie compléte de `etcd` ⚠️


`- 3.1` Déplacacer fichier `.yaml`' (Sur chaque node `192.168.0.5` / `192.168.0.8` / `192.168.0.9`) 
````
sudo mv /etc/kubernetes/manifests/*.yaml /etc/kubernetes/
````

`- 3.2` Archiver `/var/lib/etcd` (Sur chaque node `192.168.0.5` / `192.168.0.8` / `192.168.0.9`) 
````
sudo mv /var/lib/etcd/ /var/lib/etcd.bak
````

`- 3.3` Copier le backup de `etcd` vers les autres `nodes`
````
sudo scp /tmp/backup.db sednal@192.168.0.8:/tmp/
sudo scp /tmp/backup.db sednal@192.168.0.8:/tmp/
````

`- 3.4` Restauration BackUp (Sur chaque node `192.168.0.5` / `192.168.0.8` / `192.168.0.9`) 
````
sudo etcdutl snapshot restore /tmp/backup.db \
  --data-dir /var/lib/etcd \
  --name <NOM_CE_MASTER> \
  --initial-cluster <M1>=https://<IP1>:2380,<M2>=https://<IP2>:2380,<M3>=https://<IP3>:2380 \
  --initial-cluster-token etcd-restore \
  --initial-advertise-peer-urls https://<IP_CE_MASTER>:2380
````
- ICI
````
sudo etcdutl snapshot restore /tmp/backup.db \
  --data-dir /var/lib/etcd \
  --name k8s-master \
  --initial-cluster k8s-master=https://192.168.0.5:2380,k8s-master-2=https://192.168.0.8:2380,k8s-master-3=https://192.168.0.9:2380 \
  --initial-cluster-token etcd-restore \
  --initial-advertise-peer-urls https://192.168.0.5:2380

sudo etcdutl snapshot restore /tmp/backup.db \
  --data-dir /var/lib/etcd \
  --name k8s-master-2 \
  --initial-cluster k8s-master=https://192.168.0.5:2380,k8s-master-2=https://192.168.0.8:2380,k8s-master-3=https://192.168.0.9:2380 \
  --initial-cluster-token etcd-restore \
  --initial-advertise-peer-urls https://192.168.0.8:2380

sudo etcdutl snapshot restore /tmp/backup.db \
  --data-dir /var/lib/etcd \
  --name k8s-master-3 \
  --initial-cluster k8s-master=https://192.168.0.5:2380,k8s-master-2=https://192.168.0.8:2380,k8s-master-3=https://192.168.0.9:2380 \
  --initial-cluster-token etcd-restore \
  --initial-advertise-peer-urls https://192.168.0.9:2380
````

`- 3.5` Fichier `.yaml`
````
sudo mv /etc/kubernetes/*.yaml /etc/kubernetes/manifests/
````









</details>
