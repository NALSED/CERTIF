## Labs taint Toleration

`-1-` Créer Taint => k8s-worker2
````
kubectl taint nodes k8s-worker2 storage=hdd:NoSchedule
````

`-2-` Créer le pod avec toleration
````
kubectl run test-taint --image=nginx --dry-run=client -o yaml > nginx-taints.yaml 
````

````
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: test-taint
  name: test-taint
spec:
  containers:
  - image: nginx
    name: test-taint
    resources: {}
  tolerations:
  - key: "storage"
    operator: "Equal"
    value: "hdd"
    effect: "NoSchedule"
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}
````

`-3-` Test
````
kubectl cordon k8s-worker2
````

`-4-` Déployer le pod
````
kubectl apply -f nginx-taints.yaml 
````

`-5-` Vérif et fix
````
kubectl get pods

NAME    READY   STATUS    RESTARTS   AGE
nginx   0/1     Pending   0          6s
````

````
kubectl describe pods nginx

Type     Reason            Age   From               Message
  ----     ------            ----  ----               -------
  Warning  FailedScheduling  19s   default-scheduler  0/5 nodes are available: 1 node(s) were unschedulable, 4 node(s) had untolerated taint(s). preemption: 0/5 nodes are available: 5 Preemption is not helpful for scheduling.
````


- Fix
````
kubectl uncordon k8s-worker2

kubectl describe pods nginx

Type     Reason            Age   From               Message
----     ------            ----  ----               -------
Normal   Pulled            3s    kubelet            spec.containers{nginx}: Container image "nginx" already present on machine and can be accessed by the pod
Normal   Created           3s    kubelet            spec.containers{nginx}: Container created
Normal   Started           3s    kubelet            spec.containers{nginx}: Container started
````
