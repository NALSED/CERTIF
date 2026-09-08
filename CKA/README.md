# ☸️ CKA — Progression
**Certified Kubernetes Administrator** | CNCF / Linux Foundation | Version 2026  
Support : **Sander van Vugt — CKA Complete Video Course, 4ᵉ édition**  
Curriculum officiel v1.34 *(mise à jour Février 2025)*

---

**Date de passage : *à définir***  
**Point de départ : 🟥 débutant complet — aucune notion Kubernetes préalable**  
**Volume vidéo : ~10 h 07** — 6 modules, 16 leçons

---

## Comment lire ce document

Ce document suit **exactement** l'ordre des leçons du cours. Chaque leçon liste ses sous-leçons avec leur durée et les commandes/objets à maîtriser.

**Progression** : 🟥 Non commencé 🟨 En cours 🟩 Maîtrisé 🟦 Sans Aide

> ⚠️ Un ✅ dans la plateforme = **vidéo vue**. Le marqueur ici = **niveau de maîtrise**. Une vidéo vue passe en 🟨, pas en 🟩 : le 🟩 s'obtient au clavier, le 🟦 sans documentation.

**Domaine d'examen** entre crochets, avec son poids officiel :

| Tag | Domaine officiel | Poids |
|---|---|---|
| `[ARCH]` | Architecture, installation et configuration du cluster | 25 % |
| `[WORK]` | Charges de travail et ordonnancement | 15 % |
| `[NET]` | Services et réseau | 20 % |
| `[STO]` | Stockage | 10 % |
| `[TS]` | Dépannage | 30 % |

📌 **Le cours ne couvre pas tout le curriculum.** Les manques sont listés en fin de document : [Compléments hors cours](#-compléments-hors-cours--obligatoire). Ce ne sont pas des approfondissements optionnels.

---

## Progression globale

| Module | Contenu | Durée | État |
|---|---|---|---|
| **M1** | Cluster Architecture, Installation, and Configuration | 3 h 08 | 🟥 |
| **M2** | Workloads and Scheduling | 2 h 02 | 🟥 |
| **M3** | Services and Networking | 1 h 42 | 🟥 |
| **M4** | Storage | 55 min | 🟥 |
| **M5** | Troubleshooting | 24 min | 🟥 |
| **M6** | Sample Exams | 1 h 51 | 🟥 |

🟨 Introduction *(4m08)* — vue

---
---

# 🏗️ Module 1 — Cluster Architecture, Installation, and Configuration
`[ARCH]` · **3 h 08** · *Module Introduction (36s)*

> Ce module correspond au domaine le plus lourd de l'examen après le dépannage. Il te fait construire ton cluster avant de savoir t'en servir — c'est normal, il faut une machine pour suivre les démos.

---

## 🟨 Leçon 1 — Understanding Kubernetes Architecture
**9 min** · *Learning objectives (27s)*

🟩 **1.1** — Vanilla Kubernetes and the Ecosystem *(2m36)* —  
🟩 **1.2** — Running Kubernetes in Cloud or on Premises *(50s)*  
🟩 **1.3** — Kubernetes Distributions *(1m36)* — vanilla, OpenShift, Rancher, k3s  
🟨 **1.4** — Kubernetes Node Roles *(3m55)* — control plane (`kube-apiserver`, `etcd`, `kube-scheduler`, `kube-controller-manager`) vs worker (`kubelet`, `kube-proxy`, runtime)



---

## 🟥 Leçon 2 — Creating a Kubernetes Cluster with kubeadm
**46 min** · *Learning objectives (47s)*

🟥 **2.1** — Cluster Node Requirements *(2m25)* — 2 vCPU, 2 Go RAM, hostname/MAC/`product_uuid` uniques  
🟥 **2.2** — Provisioning an Infrastructure *(1m45)* — cf. [`-1- Labs.md`](./-1-%20Labs.md) (3 VM Proxmox)  
🟥 **2.3** — Installation Procedure Overview *(1m21)*  
🟥 **2.4** — Linux Kernel Settings *(2m40)* — `swapoff -a` + `/etc/fstab`, modules `overlay` / `br_netfilter`, `net.bridge.bridge-nf-call-iptables=1`, `net.ipv4.ip_forward=1`  
🟥 **2.5** — Installing CRI and Tools *(4m54)* — `containerd`, `config.toml`, **`SystemdCgroup = true`**, dépôt `pkgs.k8s.io`, `apt-mark hold`  

> 📄 **2.4 et 2.5 sont automatisés** dans [`-2- Prérequis.md`](./-2-%20Pr%C3%A9requis.md) (script à lancer sur chaque machine).  
> ⚠️ Pour l'examen il faut savoir les refaire **à la main** : le script fait gagner du temps en lab, pas en révision.

🟥 **2.6** — Using kubeadm init *(6m)* — `--pod-network-cidr`, `--apiserver-advertise-address`, `kubeadm config images pull`  
🟥 **2.7** — Configuring the Kubernetes Client *(7m47)* — `/etc/kubernetes/admin.conf` → `~/.kube/config`, contextes, `kubectl config use-context`  
🟥 **2.8** — Setting up Node Networking *(5m14)* — installation du CNI (Calico / Flannel / Cilium)  
🟥 **2.9** — Adding Nodes to the Cluster *(2m55)* — `kubeadm token create --print-join-command`, `--discovery-token-ca-cert-hash`  
🟥 **2.10** — kubeadm init with a Configuration File *(3m56)* — `kubeadm init --config`  
🟥 **Lab** — Building a Kubernetes Cluster *(31s + 6m05 solution)*

✅ **Validé quand :** tu montes le cluster 1 master + 2 workers **sans notes**, trois fois de suite.

> ⏸️ **PAUSE OBLIGATOIRE APRÈS CETTE LEÇON.** Voir [Complément A](#complément-a--bases-kubectl-et-vitesse-) — le cours suppose désormais que tu sais manipuler `kubectl`. Sauter cette pause te fera *subir* les leçons 3 à 16.

---

## 🟥 Leçon 3 — Managing Kubernetes Clusters
**25 min** · *Learning objectives (35s)*

🟥 **3.1** — Analyzing Cluster Nodes *(4m52)* — `kubectl get nodes -o wide`, `describe node`, conditions  
🟥 **3.2** — Using crictl *(4m59)* — `crictl ps -a`, `crictl logs`, `crictl images`, `crictl inspect`  
🟥 **3.3** — Running Static Pods *(4m18)* — `/etc/kubernetes/manifests/`, suffixe `-<nom-du-nœud>`, gérés par le kubelet seul  
🟥 **3.4** — Managing Node State *(4m44)* — `kubectl cordon` / `uncordon`, `drain --ignore-daemonsets --delete-emptydir-data`  
🟥 **3.5** — Managing Node Services *(4m10)* — `systemctl status kubelet`, `journalctl -u kubelet`, `/var/lib/kubelet/config.yaml`  
🟥 **Lab** — Running Static Pods *(24s + 1m19 solution)*

✅ **Validé quand :** tu crées un pod statique, tu le vois apparaître dans `kubectl get pods`, et tu le supprimes en déplaçant son manifeste.

---

## 🟥 Leçon 4 — Performing Node Maintenance Tasks
**66 min** — *la leçon la plus longue du cours* · *Learning objectives (51s)*

🟥 **4.1** — Metrics Server *(5m21)* — installation (`--kubelet-insecure-tls` en lab), `kubectl top nodes`, `kubectl top pods --containers`  
🟥 **4.2** — Backing up the Etcd *(7m50)* — `ETCDCTL_API=3 etcdctl snapshot save`, `--endpoints`, `--cacert`, `--cert`, `--key`, certificats dans `/etc/kubernetes/pki/etcd/`  
🟥 **4.3** — Restoring the Etcd *(6m41)* — `etcdctl snapshot restore --data-dir`, modification du `hostPath` dans `/etc/kubernetes/manifests/etcd.yaml`  
🟥 **4.4** — Cluster Node Upgrades *(12m15)* — `kubeadm upgrade plan`, `upgrade apply`, ordre control plane d'abord, `apt-mark unhold/hold`  
🟥 **4.5** — Cluster Worker Upgrades *(5m42)* — `drain` → `kubeadm upgrade node` → maj `kubelet` → `uncordon`  
🟥 **4.6** — Cluster High Availability Options *(14m21)* — etcd empilé vs externe, quorum `(n/2)+1`, nombre impair  
🟥 **4.7** — Setting up a Highly Available Cluster *(7m33)* — `--control-plane-endpoint`, `--upload-certs`, `join --control-plane --certificate-key`  
🟥 **Lab** — Etcd Backup and Restore *(24s + 4m37 solution)*

✅ **Validé quand :** tu casses volontairement le cluster (suppression de ressources), tu restaures un snapshot etcd, et tout revient.

---

## 🟥 Leçon 5 — Managing Security Settings
**41 min** · *Learning objectives (48s)*

🟥 **5.1** — Understanding API Access *(3m21)* — sujet + verbe + ressource  
🟥 **5.2** — Managing Security Context *(4m49)* — `runAsUser`, `runAsNonRoot`, `fsGroup`, `capabilities`, `allowPrivilegeEscalation`, `readOnlyRootFilesystem`  
🟥 **5.3** — Users, ServiceAccounts, and API Access *(1m45)* — `kubectl create sa`, `automountServiceAccountToken`  
🟥 **5.4** — Understanding RBAC *(2m01)* — `Role` (namespacé) vs `ClusterRole` (global)  
🟥 **5.5** — RBAC for ServiceAccounts *(10m32)* — `kubectl create role/rolebinding --serviceaccount=<ns>:<sa>`, `apiGroups`, `resources`, `verbs`  
🟥 **5.6** — ClusterRoles and ClusterRoleBindings *(1m35)* — `cluster-admin`, `admin`, `edit`, `view` ; RoleBinding → ClusterRole = droits limités au namespace  
🟥 **5.7** — RBAC for Users *(13m49)* — certificats client, kubeconfig, `kubectl auth can-i --as=<user>`  
🟥 **Lab** — Managing Security *(22s + 2m11 solution)*

✅ **Validé quand :** tu crées un compte limité à la lecture des Pods d'un seul namespace, et tu le **prouves** avec `auth can-i --as`.

---
---

# 📦 Module 2 — Workloads and Scheduling
`[WORK]` · **2 h 02** · *Module Introduction (27s)*

---

## 🟥 Leçon 6 — Deploying Kubernetes Applications
**41 min** · *Learning objectives (37s)*

🟥 **6.1** — Using Deployments *(3m32)* — `replicas`, `selector.matchLabels`, `template`, `kubectl set image`  
🟥 **6.2** — Running Agents with DaemonSets *(2m48)* — un Pod par nœud, tolérations implicites  
🟥 **6.3** — Using StatefulSets *(6m54)* — identité stable, `volumeClaimTemplates`, Service headless, ordre de déploiement  
🟥 **6.4** — The Case for Running Individual Pods *(1m09)*  
🟥 **6.5** — Managing Pod Initialization *(3m38)* — `initContainers`, exécution séquentielle et bloquante  
🟥 **6.6** — Scaling Applications *(3m10)* — `kubectl scale --replicas=N`  
🟥 **6.7** — Configuring Autoscaling *(7m50)* — `kubectl autoscale`, HPA, **dépend de `requests` et de metrics-server**  
🟥 **6.8** — Sidecar Containers for Application Logging *(9m31)* — namespace réseau partagé, `emptyDir` commun, sidecar natif (`initContainers` + `restartPolicy: Always`)  
🟥 **Lab** — Running a DaemonSet *(20s + 1m33 solution)*

✅ **Validé quand :** tu génères chaque contrôleur avec `--dry-run=client -o yaml` sans consulter la doc.

> ⏸️ **PAUSE.** Voir [Complément B](#complément-b--sondes-rollback-et-jobs-) — sondes, rollback et Jobs/CronJobs sont absents de cette leçon alors qu'ils sont au programme.

---

## 🟥 Leçon 7 — Using Templating Tools
**34 min** · *Learning objectives (25s)*

🟥 **7.1** — Running Applications from YAML Files *(1m)* — `kubectl apply -f`  
🟥 **7.2** — The Helm Package Manager *(10m58)* — `helm repo add/update`, `helm install -n --create-namespace`, `helm list -A`  
🟥 **7.3** — Creating a Template from a Helm Chart *(5m55)* — `helm template`, `Chart.yaml`, `values.yaml`, `templates/`  
🟥 **7.4** — Managing Applications with Helm *(6m15)* — `helm upgrade -f/--set`, `helm rollback`, `helm history`, `helm uninstall`  
🟥 **7.5** — Using Kustomize *(4m52)* — `kustomization.yaml`, `resources`, `configMapGenerator`, bases/overlays, `kubectl apply -k`  
🟥 **Lab** — Managing Applications with Helm *(17s + 4m09 solution)*

✅ **Validé quand :** tu installes un chart, tu changes une valeur par upgrade, tu reviens en arrière — et tu produis deux overlays Kustomize à partir d'une même base.

---

## 🟥 Leçon 8 — Managing Scheduling
**47 min** · *Learning objectives (47s)*

🟥 **8.1** — Exploring the Scheduling Process *(2m32)* — phase de filtrage puis de scoring  
🟥 **8.2** — Setting Node Preferences *(3m10)* — `nodeName`, `nodeSelector`, `kubectl label node`  
🟥 **8.3** — Affinity and anti-Affinity Rules *(10m21)* — `requiredDuringScheduling...` vs `preferred...`, `podAffinity` / `podAntiAffinity`, `topologyKey`, opérateurs `In` / `NotIn` / `Exists`  
🟥 **8.4** — Taints and Tolerations *(8m34)* — `kubectl taint nodes k=v:NoSchedule`, `PreferNoSchedule`, `NoExecute`, `tolerationSeconds`  
🟥 **8.5** — Resource Limits and Requests *(2m08)* — `100m` CPU, `Mi`/`Gi`, classes QoS, `OOMKilled` (code 137)  
🟥 **8.6** — Setting Namespace Quota *(6m38)* — `ResourceQuota`, `count/<res>`  
🟥 **8.7** — Configuring LimitRange *(3m13)* — `default`, `defaultRequest`, `min`, `max`  
🟥 **8.8** — Configuring Pod Priorities *(5m05)* — `PriorityClass`, préemption, `globalDefault`  
🟥 **Lab** — Configuring Taints *(44s + 3m43 solution)*

✅ **Validé quand :** tu forces un Pod sur un nœud teinté, et tu expliques la différence entre `NoSchedule` (nouveaux Pods) et `NoExecute` (Pods déjà présents).

---
---

# 🌐 Module 3 — Services and Networking
`[NET]` · **1 h 42** · *Module Introduction (20s)*

---

## 🟥 Leçon 9 — Managing Application Access
**67 min** — *la leçon la plus longue en contenu* · *Learning objectives (47s)*

🟥 **9.1** — Exploring Kubernetes Networking *(6m35)* — une IP par Pod, réseau plat, pas de NAT entre Pods  
🟥 **9.2** — Understanding Network Plugins *(2m51)* — rôle du CNI  
🟥 **9.3** — Using Services to Access Applications *(4m19)* — `ClusterIP`, `NodePort` (30000-32767), `LoadBalancer`, `ExternalName`, headless ; `port` vs `targetPort` vs `nodePort` ; **`kubectl get endpoints`**  
🟥 **9.4** — Running an Ingress Controller *(10m48)* — installation `ingress-nginx`, `IngressClass`  
🟥 **9.5** — Configuring Ingress *(7m21)* — `ingressClassName`, `host`, `http.paths`, `pathType` (`Exact` / `Prefix`)  
🟥 **9.6** — Port Forwarding *(2m19)* — `kubectl port-forward svc/<x> 8080:80`  
🟥 **9.7** — Understanding Gateway API *(3m39)* — séparation des rôles : Gateway (infra) ≠ HTTPRoute (application)  
🟥 **9.8** — Configuring Gateway API *(4m04)* — installation des CRD, `GatewayClass`, `Gateway`, `listeners`  
🟥 **9.9** — Gateway API to Provide Access *(10m06)* — `HTTPRoute`, `parentRefs`, `hostnames`, `rules.matches`, `backendRefs`  
🟥 **9.10** — Gateway API for TLS Access *(10m16)* — terminaison TLS, Secret `tls`  
🟥 **Lab** — Managing Networking *(22s + 3m52 solution)*

✅ **Validé quand :** face à un Service qui ne répond pas, ton **premier réflexe** est `kubectl get endpoints` — et tu exposes la même app via Ingress **et** via Gateway API.

> 💡 La Gateway API est l'ajout le plus récent du curriculum (2025). Le cours y consacre ~28 min avec TLS : c'est la meilleure couverture disponible, exploite-la à fond.

---

## 🟥 Leçon 10 — Networking
**34 min** · *Learning objectives (39s)*

🟥 **10.1** — Managing the CNI and Network Plugins *(3m59)* — `/etc/cni/net.d`, `/opt/cni/bin`, un seul plugin actif  
🟥 **10.2** — Service Auto Registration and Kubernetes DNS *(6m27)* — `<svc>.<ns>.svc.cluster.local`, `/etc/resolv.conf`, `ndots:5`  
🟥 **10.3** — NetworkPolicies Between Pods *(6m04)* — tout est autorisé par défaut ; `policyTypes`, `podSelector: {}`, deny-all  
🟥 **10.4** — NetworkPolicies Between Namespaces *(9m41)* — `namespaceSelector`, `ipBlock` ; ⚠️ deux entrées `-` = **OU**, deux clés dans la même entrée = **ET** ; toujours autoriser le port **53**  
🟥 **10.5** — Managing CoreDNS *(50s)* — Deployment `kube-system`, ConfigMap `Corefile`  
🟥 **Lab** — Using NetworkPolicies *(48s + 5m28 solution)*

✅ **Validé quand :** tu poses un deny-all, tu rouvres un seul flux, et le test `curl` échoue depuis partout ailleurs.

> ⚠️ NetworkPolicy exige un CNI qui l'implémente — **Calico/Cilium oui, Flannel seul n'applique rien**. À vérifier sur ton lab.

---
---

# 💾 Module 4 — Storage
`[STO]` · **55 min** · *Module Introduction (27s)*

---

## 🟥 Leçon 11 — Managing Storage
**33 min** · *Learning objectives (38s)*

🟥 **11.1** — Understanding Storage Options *(2m49)*  
🟥 **11.2** — Accessing Storage Through Pod Volumes *(2m56)* — `emptyDir` (`medium: Memory`), `hostPath`, `volumeMounts`, `subPath`  
🟥 **11.3** — Configuring PersistentVolume *(4m35)* — `capacity`, `accessModes` (`RWO`/`ROX`/`RWX`/`RWOP`), `storageClassName`  
🟥 **11.4** — Configuring PersistentVolumeClaim *(2m50)* — liaison automatique, phases `Available`/`Bound`/`Released`  
🟥 **11.5** — Pod Storage with PVs and PVCs *(2m55)*  
🟥 **11.6** — Volume Reclaim Policies *(1m28)* — `Retain`, `Delete`  
🟥 **11.7** — ConfigMaps and Secrets as Volumes *(7m)* — `volumes.configMap`, `items`, `defaultMode`, Secret `tls` / `generic` / `docker-registry`  
🟥 **Lab** — Setting up Storage *(41s + 6m47 solution)*

✅ **Validé quand :** tu crées un PVC qui reste `Pending` **volontairement**, et tu diagnostiques la cause.

> ⚠️ **11.7 ne montre ConfigMap/Secret qu'en volume.** L'injection par variables d'environnement (`envFrom`, `configMapKeyRef`) est au programme et n'est vue nulle part → [Complément C](#complément-c--configmapsecret-en-variables-denvironnement-).

---

## 🟥 Leçon 12 — Auto-provisioning Storage
**22 min** · *Learning objectives (29s)*

🟥 **12.1** — Using StorageClass *(2m20)* — `provisioner`, `reclaimPolicy`, `allowVolumeExpansion`, annotation `is-default-class`  
🟥 **12.2** — Understanding Storage Provisioners *(1m48)* — provisionnement dynamique, notion CSI  
🟥 **12.3** — Setting up an NFS Storage Provisioner *(11m29)* — directement applicable à ton lab Proxmox  
🟥 **Lab** — Using the Hostpath Storage Provisioner *(51s + 4m37 solution)*

✅ **Validé quand :** un PVC sans PV préexistant obtient son volume tout seul, et tu sais dire pourquoi il resterait `Pending` avec `WaitForFirstConsumer`.

---
---

# 🔍 Module 5 — Troubleshooting
`[TS]` · **24 min** · *Module Introduction (16s)*

> 🔴 **Déséquilibre majeur à connaître : 24 minutes de vidéo pour 30 % de l'examen** — soit 4 % du cours. Cette leçon donne la *méthode*, pas le volume. Le Module 6 compense partiellement en pratique, mais le gros du travail est à faire toi-même sur ton lab.

---

## 🟥 Leçon 13 — Logging, Monitoring, and Troubleshooting
**24 min** · *Learning objectives (30s)*

🟥 **13.1** — Monitoring Kubernetes Resources *(1m24)* — `kubectl top`, `kubectl get events --sort-by=.lastTimestamp`  
🟥 **13.2** — Understanding the Troubleshooting Flow *(5m32)* — `describe` → `Events` → `logs` → `logs --previous` → `exec`  
🟥 **13.3** — Troubleshooting Applications *(2m24)* — `Pending`, `ImagePullBackOff`, `CrashLoopBackOff`, `OOMKilled` (137), `ContainerCreating`, `Evicted`  
🟥 **13.4** — Troubleshooting Cluster Nodes *(7m55)* — nœud `NotReady`, kubelet, cgroup driver, swap réactivé, `/etc/kubernetes/manifests/`, `crictl` quand `kubectl` ne répond plus, `/var/log/pods/`  
🟥 **13.5** — Fixing Application Access Problems *(3m42)* — endpoints vides, sélecteur qui ne correspond pas, `targetPort` erroné, DNS  
🟥 **Lab** — Troubleshooting Nodes *(19s + 1m56 solution)*

✅ **Validé quand :** on casse ton control plane sans te dire comment, et tu le remontes en moins de 10 minutes.

> ⏸️ **PAUSE LA PLUS IMPORTANTE DU PARCOURS.** Voir [Complément E](#complément-e--dépannage-intensif-) — c'est ici que se joue le tiers de ta note.

---
---

# 🎯 Module 6 — Sample Exams
**1 h 51** · *Module Introduction (33s)*

> C'est le vrai atout du cours : **24 questions d'examen corrigées** avec un script de notation. À traiter en conditions réelles — chronomètre, docs limitées à `kubernetes.io`.

---

## 🟥 Leçon 14 — Sample Exam Instructions
**4 min** · *Learning objectives (25s)*

🟥 **14.1** — Preparing an Environment for the Sample Exams *(1m56)*  
🟥 **14.2** — Working Through the Sample Exams *(49s)*  
🟥 **14.3** — Using the exam-grade Script *(45s)*

---

## 🟥 Leçon 15 — CKA Sample Exam 1
**56 min** · *Learning objectives (41s)*

🟥 **15.1** — Questions Overview *(3m58)*  
🟥 **15.2** — Configuring a HA Cluster *(9m17)* `[ARCH]`  
🟥 **15.3** — Scheduling a Pod *(5m22)* `[WORK]`  
🟥 **15.4** — Managing Application Initialization *(2m53)* `[WORK]`  
🟥 **15.5** — Setting up Persistent Storage *(1m55)* `[STO]`  
🟥 **15.6** — Configuring Application Access *(2m57)* `[NET]`  
🟥 **15.7** — Securing Network Traffic *(8m31)* `[NET]`  
🟥 **15.8** — Setting up Quota *(5m47)* `[WORK]`  
🟥 **15.9** — Creating a Static Pod *(2m07)* `[ARCH]`  
🟥 **15.10** — Troubleshooting Node Services *(1m40)* `[TS]`  
🟥 **15.11** — Configuring Cluster Access *(5m50)* `[ARCH]`  
🟥 **15.12** — Configuring Taints and Tolerations *(5m09)* `[WORK]`

✅ **Validé quand :** tu traites les 12 questions **avant** de regarder les corrections, et le script `exam-grade` te valide.

---

## 🟥 Leçon 16 — CKA Sample Exam 2
**51 min** · *Learning objectives (27s)*

🟥 **16.1** — Questions Overview *(4m16)*  
🟥 **16.2** — Creating a Cluster *(3m25)* `[ARCH]`  
🟥 **16.3** — Performing a Control Node Upgrade *(5m09)* `[ARCH]`  
🟥 **16.4** — Configuring Application Logging *(8m23)* `[WORK]`  
🟥 **16.5** — Managing PersistentVolumeClaims *(9m41)* `[STO]`  
🟥 **16.6** — Investigating Pod Logs *(1m27)* `[TS]`  
🟥 **16.7** — Analyzing Performance *(3m27)* `[TS]`  
🟥 **16.8** — Managing Application Scheduling *(2m28)* `[WORK]`  
🟥 **16.9** — Configuring Ingress *(3m17)* `[NET]`  
🟥 **16.10** — Preparing for Node Maintenance *(1m36)* `[ARCH]`  
🟥 **16.11** — Scaling Applications *(1m43)* `[WORK]`  
🟥 **16.12** — Etcd Backup and Restore *(5m23)* `[ARCH]`

✅ **Validé quand :** idem — 12 questions à froid, chronométrées, puis correction.

---

🟥 **Summary** *(33s)*

---
---

# ⚠️ Compléments hors cours — OBLIGATOIRE

Ces sujets sont **au curriculum officiel** (ou décisifs à l'examen) et **n'apparaissent nulle part** dans les 16 leçons. Ce ne sont pas des approfondissements : sans eux, tu arrives à l'examen avec des trous.

---

### Complément A — Bases `kubectl` et vitesse ⚡
**Quand : juste après la leçon 2** · Estimation : 25-30 h

Le cours suppose ces bases acquises dès la leçon 3. Elles n'ont aucune leçon dédiée.

🟥 **A.1** — Lecture — `kubectl get -o wide/-o yaml`, `describe`, `-A`, `-n`  
🟥 **A.2** — Auto-documentation — `kubectl explain pod.spec.containers --recursive`, `api-resources`  
🟥 **A.3** — Le Pod — phases, `logs -f --previous -c`, `exec -it`, `delete --force --grace-period=0`  
🟥 **A.4** — Labels et sélecteurs — `-l env=prod`, `'env in (a,b)'`, `--show-labels`, `spec.selector.matchLabels` ↔ `template.metadata.labels`  
🟥 **A.5** — **Vitesse** — `alias k=kubectl`, `complete -F __start_kubectl k`, `export do='--dry-run=client -o yaml'`, `~/.vimrc` (`tabstop=2 expandtab`)  
🟥 **A.6** — Génération — `k create deploy/svc/cm/secret/job/role ... $do > f.yaml`  
🟥 **A.7** — Extraction — `-o jsonpath`, `--sort-by`, `-o custom-columns`, `kubectl diff -f`

> 🔴 **Le palier le plus rentable du parcours.** 2 h pour ~20 tâches : celui qui écrit son YAML à la main ne finit pas.

---

### Complément B — Sondes, rollback et Jobs 🩺
**Quand : après la leçon 6** · Estimation : 10-12 h

🟥 **B.1** — `livenessProbe` (redémarre) vs `readinessProbe` (retire des endpoints) vs `startupProbe` — ✅ **puce officielle « self-healing », absente du cours**  
🟥 **B.2** — Mécanismes `exec` / `httpGet` / `tcpSocket`, `initialDelaySeconds`, `periodSeconds`, `failureThreshold`  
🟥 **B.3** — Rolling update et **rollback** — `kubectl rollout status/history/undo --to-revision`, `maxSurge`, `maxUnavailable`, `Recreate` — ✅ **puce officielle, 3m32 seulement en 6.1**  
🟥 **B.4** — `Job` — `completions`, `parallelism`, `backoffLimit`  
🟥 **B.5** — `CronJob` — `schedule`, `concurrencyPolicy`, `suspend`  
🟥 **B.6** — `restartPolicy`, `terminationGracePeriodSeconds`, `preStop`

---

### Complément C — ConfigMap/Secret en variables d'environnement 🔧
**Quand : après la leçon 11** · Estimation : 4-6 h

Le cours ne les montre qu'en **volume** (11.7).

🟥 **C.1** — Création — `--from-literal`, `--from-file`, `--from-env-file`  
🟥 **C.2** — Injection unitaire — `env.valueFrom.configMapKeyRef` / `secretKeyRef`  
🟥 **C.3** — Injection globale — `envFrom.configMapRef` / `secretRef`  
🟥 **C.4** — `imagePullSecrets`, `stringData` vs `data`, `immutable: true`  
🟥 **C.5** — Différence clé : les **volumes** se mettent à jour, **pas les variables d'env**

---

### Complément D — CRD et opérateurs 🧩
**Quand : après la leçon 12** · Estimation : 6-8 h

✅ **Puce officielle du curriculum — absente du cours.**

🟥 **D.1** — `CustomResourceDefinition` — `apiextensions.k8s.io/v1`  
🟥 **D.2** — Anatomie — `group`, `names`, `scope`, `versions`, `schema`  
🟥 **D.3** — Exploitation — `kubectl get crd`, `kubectl explain <kind>`  
🟥 **D.4** — Motif opérateur — CR + contrôleur en boucle de réconciliation  
🟥 **D.5** — Installer un opérateur (manifeste / Helm / OLM)  
🟥 **D.6** — Interfaces d'extension — CRI, CNI, **CSI**, device plugins

---

### Complément E — Dépannage intensif 🔥
**Quand : après la leçon 13, avant le Module 6** · Estimation : 35-45 h

La leçon 13 fait 24 min pour 30 % de l'examen. Le volume se fait ici, **en cassant le cluster** — pas en vidéo. Tes snapshots Proxmox sont l'outil clé.

🟥 **E.1** — Scénarios applicatifs — `Init:Error`, `Terminating` bloqué (finalizers), readiness en échec  
🟥 **E.2** — `kubectl debug -it --image=busybox --target=<c>`, `--copy-to`, conteneurs éphémères  
🟥 **E.3** — Codes de sortie — `0`, `1`, `125`, `126`, `127`, `137`, `143`  
🟥 **E.4** — Réseau par couches — `curl <podIP>` → `<clusterIP>` → `<nom-svc>` ; `nslookup kubernetes.default` ; `nicolaka/netshoot`  
🟥 **E.5** — `kube-proxy` — DaemonSet, logs, `iptables -t nat -L`  
🟥 **E.6** — Control plane — apiserver mort par YAML invalide, scheduler arrêté (Pods `Pending`), controller-manager arrêté (pas de ReplicaSet), etcd en panne  
🟥 **E.7** — Certificats — `kubeadm certs check-expiration`, `renew all`, erreurs `x509`  
🟥 **E.8** — Ports — `6443` apiserver, `2379-2380` etcd, `10250` kubelet, `10259` scheduler, `10257` controller-manager  
🟥 **E.9** — Redémarrer un Pod statique — déplacer le manifeste puis le remettre  
🟥 **E.10** — `kubeadm reset` + nettoyage `/etc/cni/net.d`, `iptables`

---

## 📊 Plan de charge

| Bloc | Vidéo | Travail total |
|---|---|---|
| Module 1 | 3 h 08 | 55-65 h |
| **Complément A** *(après L2)* | — | 25-30 h |
| Module 2 | 2 h 02 | 35-40 h |
| **Complément B** *(après L6)* | — | 10-12 h |
| Module 3 | 1 h 42 | 30-35 h |
| Module 4 | 55 min | 15-20 h |
| **Compléments C + D** | — | 10-14 h |
| Module 5 | 24 min | 5 h |
| **Complément E** *(dépannage)* | — | 35-45 h |
| Module 6 *(examens blancs)* | 1 h 51 | 15-20 h |
| killer.sh ×2 | — | 10 h |
| **TOTAL** | **~10 h** | **~200-235 h** |

À raison de **25 h/semaine** (5 h × 5 jours), cela représente **8 à 9 semaines**, soit **~2 à 2,5 mois** — comparable à ton RHCSA (~215 h).

> 💡 La vidéo ne représente que **5 %** du temps total. Le reste, c'est du clavier.

---

## 📝 Informations examen

| | |
|---|---|
| **Durée** | 2 heures |
| **Format** | Pratique, en ligne, surveillé — ~15 à 20 tâches |
| **Score minimum** | **66 %** |
| **Environnement** | Terminal Linux, plusieurs clusters, `kubectl` / `helm` / `crictl` |
| **Documentation autorisée** | `kubernetes.io/docs`, `kubernetes.io/blog`, `helm.sh/docs` — **un seul onglet** |
| **Validité** | 2 ans |
| **Inclus** | 1 repassage gratuit + 2 sessions du simulateur killer.sh |

> ⚠️ La version de Kubernetes de l'examen suit la release courante et change tous les ~4 mois — **vérifier le curriculum officiel CNCF avant de réserver**.

> 💡 L'examen fournit **plusieurs clusters** : la 1ʳᵉ ligne de chaque question donne le `kubectl config use-context` à exécuter. L'oublier = 0 à la question.

---

## ✅ Checklist finale avant l'examen

🟥 Les 16 leçons en 🟦 *(sans aide)*  
🟥 Les 5 compléments A → E traités  
🟥 Cluster kubeadm monté **from scratch** au moins 3 fois sans notes  
🟥 Sauvegarde + restauration `etcd` réussie sur un cluster cassé  
🟥 Upgrade de version complète (control plane + workers) réussie  
🟥 NetworkPolicy deny-all puis autorisation ciblée, validée par un test réel  
🟥 Ingress **et** Gateway API déployés et testés  
🟥 RBAC : compte limité créé et prouvé avec `auth can-i --as`  
🟥 Sondes liveness/readiness/startup maîtrisées *(complément B)*  
🟥 CRD installée et ressource personnalisée créée *(complément D)*  
🟥 Sample Exam 1 et 2 réussis **à froid**, avant correction  
🟥 `--dry-run=client -o yaml` utilisé par réflexe  
🟥 Alias et autocomplétion configurés en moins de 60 s  
🟥 killer.sh terminé 2 fois avec toutes les questions comprises  
🟥 Score > 66 % sur examen blanc chronométré

---

*CKA — Sander van Vugt 4ᵉ éd. — CNCF / Linux Foundation — 2026*
