````
════════════════════════════════════════════════════════════════════
                    FONCTIONNEMENT RÉSEAU DANS KUBERNETES
════════════════════════════════════════════════════════════════════

                              [ USER / Internet ]
                                      │
                                      v
                                 +---------+
                                 |   DNS   |  mon-site.com → IP du LB
                                 +---------+
                                      │
                                      v
                                 +---------+
                                 |   LB    |  (externe au cluster)
                                 +----+----+
                                      │  répartit vers n'importe quel nœud
              +-----------------------+-----------------------+
              v                       v                       v
        +-----------+           +-----------+           +-----------+
        | Node 1    |           | Node 2    |           | Node 3    |
        | :32000    |           | :32000    |           | :32000    |
        +-----+-----+           +-----+-----+           +-----+-----+
              │   (NodePort, ouvert sur TOUS les nœuds)        │
              +-----------------------+-----------------------+
                                      v
                        +--------------------------+
                        |   Ingress Controller      |  (= un Pod)
                        |   lit les règles Ingress  |
                        +-------------+--------------+
                                      │  route selon host/path
                                      v
════════════════════════ COUCHE SERVICE (virtuelle) ══════════════════
                                      │
                         +------------+------------+
                         v                         v
                 +--------------+          +--------------+
                 | Service      |          | Service      |
                 | ClusterIP    |          | ClusterIP     |
                 | 10.96.0.5    |          | 10.96.0.8     |
                 +------+-------+          +------+--------+
                        │                          │
         ┌──────────────┘                          │
         │   nom DNS construit par CoreDNS :        │
         │   <name>.<namespace>.svc.cluster.local   │
         │                                          │
         v                                          v
  +-------------+                          +----------------+
  |  CoreDNS    |<---- watch API server --->|   API server   |
  |  (cache DNS)|   (Service créé/supprimé) |   (+ etcd)     |
  +-------------+                          +----------------+
         ^
         │ résolution "mon-service" → 10.96.0.5
         │
    (toujours stable, même si les Pods changent)

════════════════════ SELECTOR → ENDPOINTS (dynamique) ═════════════════

   Service.spec.selector: app=web
         │
         v
   +--------------+        watch labels des Pods
   |  Endpoints   |<-------------------------------------+
   |  Controller  |                                       |
   +------+-------+                                       |
          │  met à jour la liste des IP réelles            |
          v                                               |
   +----------------------------+                         |
   | Endpoints de "mon-service" |                         |
   | 172.16.1.2:80              |                         |
   | 172.16.1.3:80               |                        |
   +-------------+--------------+                         |
                 │                                         |
                 v                                         |
         +---------------+                                 |
         |  kube-proxy   |  (sur chaque nœud)              |
         |  iptables/IPVS|  redirige ClusterIP → Pod IP    |
         +-------+-------+                                 |
                 │                                         |
                 v                                         |
════════════════ RÉSEAU DES PODS (géré par le CNI) ═════════════════
                 │                                         |
        +--------+--------+                      +---------+--------+
        v                 v                      v                  v
   +---------+       +---------+            +---------+       +---------+
   | Pod A   |       | Pod B   |            | Pod C   |       | Pod D   |
   | labels: |       | labels: |            | labels: |       | labels: |
   | app=web |       | app=web |            | app=db  |       | app=db  |
   | IP:     |       | IP:     |            | IP:     |       | IP:     |
   |172.16.1.2       |172.16.1.3           |172.16.2.4       |172.16.2.5
   +---------+       +---------+            +---------+       +---------+
        ^                 ^                      ^                  ^
        |                 |                      |                  |
        +-----------------+----------------------+------------------+
                 CNI (Calico/Flannel/Cilium) attribue les IP,
                 assure la connectivité Pod ↔ Pod sur tout le cluster
                 (peu importe le nœud physique)

════════════════════════════════════════════════════════════════════
 RÉCAPITULATIF — ce qui est STABLE vs ce qui CHANGE
════════════════════════════════════════════════════════════════════
 STABLE  : nom du Service, ClusterIP, nom DNS, labels des Pods
 CHANGE  : IP des Pods, nom des Pods (si Deployment/ReplicaSet)
 LIEN    : labels (selector) relient Service ↔ Pods, peu importe
           leur IP ou leur nom du moment
════════════════════════════════════════════════════════════════════
````
