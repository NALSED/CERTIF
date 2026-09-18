# Informations utiles à propos du cluster de révision de la `CKA`

---

## `=== Identification ===`
- `API-Server` : https://192.168.0.15:6443 (VIP — point d'entrée du cluster)

- `API-Server` (direct) : https://192.168.0.5:6443 | https://192.168.0.8:6443 | https://192.168.0.9:6443

- `VIP` : 192.168.0.15 — HAProxy (frontend `:6443`) + keepalived (VRRP), portée par l'un des 3 masters

- `Master` : 192.168.0.5 / k8s-master.sednal.lan

- `Master-2` : 192.168.0.8 / k8s-master-2.sednal.lan

- `Master-3` : 192.168.0.9 / k8s-master-3.sednal.lan

- `Worker1` : 192.168.0.6 / k8s-worker1.sednal.lan

- `Worker2` : 192.168.0.7 / k8s-worker2.sednal.lan

---

## === Plages réseaux ===

- `Nodes` : 192.168.0.0/24 | 172.16.0.0/24
 
- `Pods` : 172.16.0.0/16

- `Services` : 10.96.0.0/12


## === IP ===

### `NODES`



### - `SERVICE`

- `kubernetes` : 10.96.0.1

- `kube-dns` (CoreDNS) :
