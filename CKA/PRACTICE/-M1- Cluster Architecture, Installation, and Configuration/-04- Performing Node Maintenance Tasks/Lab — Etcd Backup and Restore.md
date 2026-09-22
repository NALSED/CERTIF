## Lab 

---

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
