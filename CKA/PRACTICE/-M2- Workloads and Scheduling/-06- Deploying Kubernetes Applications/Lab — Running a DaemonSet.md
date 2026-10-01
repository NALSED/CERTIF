## Labs DaemonSet

---

`-1-` Créer le fichier
````
kubectl create deployment nginxdaemon --image=nginx --dry-run=client -o yaml > daemonset-nginx.yaml
````

`-2-` Editer (Retirer Replicas et Strategy / Ajouter kind: DaemonSet)
````
apiVersion: apps/v1
kind: DaemonSet
metadata:
  labels:
    app: nginxdaemon
  name: nginxdaemon
spec:
  selector:
    matchLabels:
      app: nginxdaemon
  template:
    metadata:
      labels:
        app: nginxdaemon
    spec:
      containers:
      - image: nginx
        name: nginx
        resources: {}
status: {
````

`-3-` Créer
````
kubectl apply -f daemonset-nginx.yaml
````

`-4-` Test
````
kubectl get all | grep daemonset
# Sortie
daemonset.apps/nginxdaemon   2         2         2       2            2           <none>          5m23s
daemonset.apps/test-daemon   2         2         2       2            2           <none>          45h


kubectl get pods -o wide | grep nginxdaemon
# Sortie
nginxdaemon-sm4fg                 1/1     Running   0             5m25s   172.16.126.32   k8s-worker2   <none>           <none>
nginxdaemon-xf792                 1/1     Running   0             5m25s   172.16.194.97   k8s-worker1   <none>           <none>
````
