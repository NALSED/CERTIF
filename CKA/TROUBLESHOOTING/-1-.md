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
