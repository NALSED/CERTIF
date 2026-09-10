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

### Où les analogies cassent

`-1-` **L'apiserver n'est pas qu'un péage.** Un péage laisse passer vers une
destination. Ici la requête **s'arrête** : elle est validée puis écrite dans etcd.
Personne ne reçoit de courrier — les autres composants viennent consulter le
registre eux-mêmes (`watch`).

`-2-` **kube-proxy n'est pas un firewall.** Il fait du DNAT, il ne filtre rien.
Le filtrage, c'est `NetworkPolicy`, appliqué par Calico.

`-3-` **Le scheduler n'est pas un chef d'orchestre.** Il ne commande personne :
il écrit `nodeName` dans l'apiserver et s'arrête là. Le kubelet découvre ensuite
que le Pod porte le nom de son nœud.

`-4-` **Le Namespace n'isole pas le réseau.** Contrairement à un VLAN ou une VRF,
un Pod du ns `dev` joint un Pod du ns `prod` par défaut.

`-5-` **Le Service n'est pas un process.** Aucun daemon ne tourne. C'est une règle
iptables/IPVS écrite sur chaque nœud. Rien à voir avec un service `systemd`.

---

`[CLÉ]` Modèle **déclaratif** : personne ne donne d'ordre. Chacun lit l'apiserver
et agit de son côté. À l'opposé d'un script shell impératif.

