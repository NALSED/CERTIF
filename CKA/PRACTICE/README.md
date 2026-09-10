````

                                  kubectl
                                     │
┌────────────────────────────────────┼──────────────────────────────────────┐
│ CLUSTER K8S                        │                                      │
│                                    ▼                                      │
│  ┌──────────────────────── CONTROL PLANE ────────────────────────┐        │
│  │  (k8s-master 192.168.0.5)      Pods statiques                 │        │
│  │                                                               │        │
│  │   ┌─────────────────┐  écrit/lit  ┌──────────────────┐        │        │
│  │   │  kube-apiserver │◄───────────►│      etcd        │        │        │
│  │   │  point d'entrée │             │  état du cluster │        │        │
│  │   └───▲────────▲────┘             └──────────────────┘        │        │
│  │       │        │                                              │        │
│  │  watch│        │watch                                         │        │
│  │       │        │                                              │        │
│  │  ┌────┴─────┐  └──┬────────────────────────┐                  │        │
│  │  │ scheduler│     │ controller-manager     │                  │        │
│  │  │ choisit  │     │ réconcilie état désiré │                  │        │
│  │  │ le node  │     │ (replicas, endpoints)  │                  │        │
│  │  └──────────┘     └────────────────────────┘                  │        │
│  └────────────────────────────▲──────────────────────────────────┘        │
│                               │                                           │
│                     watch     │     remonte l'état du node                │
│                               │                                           │
│  ┌────────────────────── NODE (worker) ──────────────────────────┐        │
│  │  (k8s-worker1 192.168.0.6)                                    │        │
│  │                                                               │        │
│  │   ┌──────────────┐   CRI    ┌──────────────────┐              │        │
│  │   │   kubelet    │─────────►│   containerd     │              │        │
│  │   │  service     │          │  crée/arrête     │              │        │
│  │   │  systemd     │          │  les conteneurs  │              │        │
│  │   └──────┬───────┘          └────────┬─────────┘              │        │
│  │          │                           │                        │        │
│  │          │  surveille                │ démarre                │        │
│  │          │  /etc/kubernetes/         ▼                        │        │
│  │          │  manifests/     ┌──────── POD ────────┐            │        │
│  │          │                 │  conteneur(s)       │            │        │
│  │          └────────────────►│  IP: 172.16.1.5     │            │        │
│  │                            └──────────▲──────────┘            │        │
│  │                                       │                       │        │
│  │   ┌──────────────┐   règles           │                       │        │
│  │   │  kube-proxy  │   iptables/IPVS    │                       │        │
│  │   │  DaemonSet   │────────────────────┤                       │        │
│  │   └──────────────┘                    │                       │        │
│  │                                       │                       │        │
│  │   ┌──────────────┐   attribue IP      │                       │        │
│  │   │ CNI          │   + connectivité   │                       │        │
│  │   │ calico-node  │───────────────────►│                       │        │
│  │   │ DaemonSet    │   Pod <=> Pod      │                       │        │
│  │   └──────────────┘                    │                       │        │
│  └───────────────────────────────────────┼───────────────────────┘        │
│                                          │                                │
│                       ┌──────────────────┴──────────────┐                 │
│                       │           SERVICE               │                 │
│                       │  ClusterIP 10.96.x.x + DNS      │                 │
│                       │  selector: app=web              │                 │
│                       │  L4 (IP + port)                 │                 │
│                       └─────────────▲───────────────────┘                 │
│                                     │                                     │
└─────────────────────────────────────┼─────────────────────────────────────┘
                                      │
                                   CLIENT
````

````
Plages :  Nodes 192.168.0.0/24  |  Pods 172.16.0.0/16  |  Services 10.96.0.0/12
````

### === ANALOGIES SYSADMIN ===

`[NOTE]` Repères pour ancrer les rôles. Les limites de chaque analogie sont notées.

---

| Composant K8S | Équivalent que tu connais |
|---|---|
| `kubectl` | Client CLI distant, comme `ssh` ou `curl`. Pas un composant du cluster. |
| `kube-apiserver` | Péage + douane + **greffe**. Contrôle l'identité, les droits, puis **enregistre au registre**. |
| `etcd` | Le **`/etc` du cluster**, distribué. (C'est littéralement l'origine du nom.) |
| `kube-scheduler` | Le **placeur de VM de Proxmox** : choisit sur quel hôte démarrer, puis écrit son choix. |
| `kube-controller-manager` | **Ansible idempotent joué en boucle infinie**. Compare, corrige, recommence. |
| `kubelet` | Le **systemd du nœud** + un agent d'inventaire qui remonte l'état. |
| `containerd` | Le moteur d'exécution, équivalent de `dockerd` ou de `qemu` sous Proxmox. |
| `/etc/kubernetes/manifests/` | Un **répertoire drop-in surveillé**, façon `/etc/cron.d`. Tout fichier déposé est lancé. |
| `Pod` | Plusieurs conteneurs dans le **même network namespace** (`docker run --network=container:x`). |
| `kube-proxy` | Les **règles DNAT de nftables**. Écrit les règles, ne voit pas passer le trafic. |
| `CNI (calico)` | **Routeur / switch L3** entre nœuds. |
| `NetworkPolicy` | **nftables** appliqué par Calico. Le vrai firewall. |
| `Service` | **VIP keepalived + HAProxy L4**, avec une entrée DNS. |
| `CoreDNS` | Ton **dnsmasq / bind** interne. |
| `Ingress` | **Reverse-proxy nginx L7** : vhosts, routage par path. |
| `Namespace` | Un **répertoire avec ACL (RBAC) et quota**. **Pas** un VLAN : aucune isolation réseau. |

---

### === Réseau ===

## Trace d'une requête : `curl http://web` depuis un Pod

---

````
Pod A (172.16.1.5) veut joindre le Service "web"
````

---

`-1-` **CoreDNS** — le Pod résout `web.default.svc.cluster.local`

- Réponse : `10.96.45.12` (la ClusterIP)
- Rôle : **annuaire**. Aucun trafic ne passe par lui après.

`-2-` **Le paquet part** vers `10.96.45.12:80`.

- Cette IP n'existe nulle part. Aucune interface ne la porte, aucun serveur ne l'écoute.

`-3-` **kube-proxy** — enfin, ses règles. Dans `PREROUTING` / `OUTPUT`, une règle DNAT écrite à l'avance réécrit la destination :

````
10.96.45.12:80  →  172.16.2.8:8080   (un Pod du Service, choisi aléatoirement)
````

- Rôle : **table NAT**. kube-proxy le process ne voit jamais ce paquet.

`-4-` **NetworkPolicy** — Calico vérifie dans ses chaînes si Pod A a le droit de joindre Pod B.

- Rôle : **filtrage**. Si refus, le paquet meurt ici.

`-5-` **CNI (Calico)** — le paquet doit aller de `172.16.1.5` (worker1) à `172.16.2.8` (worker2). Calico a posé les routes :

````
172.16.2.0/24 via 192.168.0.7 dev tunl0
````

- Rôle : **routage L3**. C'est lui qui fait traverser le réseau physique.

`-6-` **Arrivée** dans le network namespace du Pod B, via son interface `veth`.

---

### Séparation des rôles

| Brique | Moment | Question à laquelle elle répond |
|---|---|---|
| `CoreDNS` | avant l'envoi | « quelle IP pour ce nom ? » |
| `kube-proxy` | à l'envoi | « quelle IP réelle derrière cette VIP ? » |
| `NetworkPolicy` | en transit | « a-t-il le droit ? » |
| `CNI` | en transit | « par quelle route ? » |
| `Ingress` | en amont de tout | « quel Service pour cette URL ? » |

`[NOTE]` **Ingress est à part** : il n'est pas dans ce chemin. C'est un Pod nginx
qui tourne dans le cluster, reçoit le trafic externe, et **redevient un client
normal** qui refait tout le parcours ci-dessus vers le Service cible.

---

### Les 4 couches, dans l'ordre de traversée

````
NOM       →  CoreDNS        (annuaire)
ADRESSE   →  kube-proxy     (NAT : VIP → IP réelle)
CHEMIN    →  CNI            (routage L3 entre nœuds)
DROIT     →  NetworkPolicy  (filtrage)
````

`[CLÉ]` Mécanique identique à `bind` + `nat` nftables + table de routage +
`filter`. La seule vraie différence : **tout est réécrit dynamiquement** à chaque
création ou suppression de Pod, par des agents qui `watch` l'apiserver.
Rien n'est statique.

---

`[CLÉ]` Modèle **déclaratif** : personne ne donne d'ordre. Chacun lit l'apiserver
et agit de son côté. À l'opposé d'un script shell impératif.

