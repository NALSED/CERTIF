## `-1-` Cluster Node Upgrade

Dans la doc utiliser `Upgrading kubadm clusters`

---

## `-2-` HELP
 kubectl ARGUMENT FLAG -h pour help

- Exemple role
````
kubectl create role -h | less
````

## `-3-` !!! EDITION DE CONFIGURATION !!!
- Un bon reflexe à prendre tout de suite

=== COMBO ===

-1-
````
COMMANDE --dry-run=client -o yaml > fichier.yaml
````

-2-
````
kubectl apply -f fichier.yaml
````
