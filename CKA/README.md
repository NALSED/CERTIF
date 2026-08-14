# ☸️ CKA — Checklist de Progression
**Certified Kubernetes Administrator** | CNCF / Linux Foundation | Version 2026  
Curriculum officiel v1.34 *(mise à jour Février 2025 — Gateway API, Helm/Kustomize, opérateurs)*

---

**Date de passage : *à définir***  
**Point de départ : 🟥 débutant complet — aucune notion Kubernetes préalable**

---

## Progression globale

🟥 Non commencé 🟨 En cours 🟩 Maîtrisé  🟦 Sans Aide

🟥 Section 0 — Fondations *(prérequis, hors curriculum officiel)*  
🟥 Section 1 — Architecture, installation et configuration du cluster — **25 %**  
🟥 Section 2 — Charges de travail et ordonnancement — **15 %**  
🟥 Section 3 — Services et réseau — **20 %**  
🟥 Section 4 — Stockage — **10 %**  
🟥 Section 5 — Dépannage — **30 %**

> 💡 Le dépannage pèse **30 %** — c'est le plus gros bloc de l'examen, mais il ne se travaille qu'**après** avoir compris le reste. À garder pour la fin.

---

🟥 Non commencé 🟨 En cours 🟩 Maîtrisé  🟦 Sans Aide

## 0. 🧱 Fondations — *prérequis, non listé au curriculum officiel*

🟥 **0.1** — Architecture Kubernetes — control plane (`kube-apiserver`, `etcd`, `kube-scheduler`, `kube-controller-manager`) vs nœuds (`kubelet`, `kube-proxy`, runtime)  
🟥 **0.2** — Structure d'un manifeste YAML — `apiVersion`, `kind`, `metadata`, `spec`  
🟥 **0.3** — Pods — cycle de vie, conteneurs multiples, `initContainers`, sidecars  
🟥 **0.4** — Namespaces — `kubectl get ns`, `-n`, `--all-namespaces`  
🟥 **0.5** — Labels, sélecteurs et annotations — `-l app=web`, `--show-labels`  
🟥 **0.6** — Verbes `kubectl` — `get`, `describe`, `create`, `apply`, `edit`, `delete`, `explain`  
🟥 **0.7** — Génération de YAML — `--dry-run=client -o yaml`, `kubectl create ... > f.yaml`  
🟥 **0.8** — Contextes multi-clusters — `kubectl config get-contexts`, `use-context`, `current-context`  
🟥 **0.9** — Vitesse d'exécution — `alias k=kubectl`, autocomplétion, `export do='--dry-run=client -o yaml'`, config `vim` (2 espaces)  

> 💡 L'examen fournit **plusieurs clusters** : la 1ʳᵉ ligne de chaque question donne le `kubectl config use-context` à exécuter. L'oublier = 0 à la question.

---

## 1. 🏗️ Architecture, installation et configuration du cluster — **25 %**

🟥 **1.1** — **RBAC** — `Role`, `ClusterRole`, `RoleBinding`, `ClusterRoleBinding`  
🟥 **1.1.1** — ServiceAccounts — `kubectl create sa`, `automountServiceAccountToken`, tokens  
🟥 **1.1.2** — Vérification des droits — `kubectl auth can-i --as=<user> -n <ns>`  

🟥 **1.2** — **Préparer l'infrastructure** — désactivation du swap (`swapoff -a` + `/etc/fstab`)  
🟥 **1.2.1** — Modules noyau et sysctl — `overlay`, `br_netfilter`, `net.ipv4.ip_forward=1`  
🟥 **1.2.2** — Runtime de conteneurs — `containerd`, `SystemdCgroup = true`, `crictl`  
🟥 **1.2.3** — Dépôts et paquets — `kubeadm`, `kubelet`, `kubectl` + `apt-mark hold`  

🟥 **1.3** — **Créer un cluster avec kubeadm** — `kubeadm init --pod-network-cidr`  
🟥 **1.3.1** — Kubeconfig admin — `/etc/kubernetes/admin.conf`, `~/.kube/config`  
🟥 **1.3.2** — Joindre des nœuds — `kubeadm token create --print-join-command`, `kubeadm join`  
🟥 **1.3.3** — Installer un CNI — Calico / Flannel / Cilium  

🟥 **1.4** — **Cycle de vie du cluster** — `kubeadm upgrade plan`, `kubeadm upgrade apply`  
🟥 **1.4.1** — Mise à jour des nœuds — `kubeadm upgrade node`, puis `kubelet` + `kubectl`  
🟥 **1.4.2** — Vidange et remise en service — `kubectl drain --ignore-daemonsets`, `uncordon`  
🟥 **1.4.3** — Sauvegarde/restauration `etcd` — `etcdctl snapshot save` / `restore`  

🟥 **1.5** — **Control plane hautement disponible** — etcd empilé vs externe, load balancer, quorum  

🟥 **1.6** — **Helm et Kustomize** — `helm repo add/update`, `helm install/upgrade/list/uninstall`  
🟥 **1.6.1** — Kustomize — `kustomization.yaml`, `kubectl apply -k`, overlays et patches  

🟥 **1.7** — **Interfaces d'extension** — CNI, CSI, CRI, device plugins — rôle de chacune  

🟥 **1.8** — **CRD et opérateurs** — `kubectl get crd`, `apiextensions.k8s.io`, installer un opérateur  

> 💡 `etcdctl` n'est plus une puce explicite du curriculum depuis 2025, mais reste un grand classique de l'examen. Les flags `--cacert`, `--cert`, `--key` s'apprennent par cœur.

---

## 2. 📦 Charges de travail et ordonnancement — **15 %**

🟥 **2.1** — **Déploiements** — `Deployment`, `ReplicaSet`, `kubectl scale`  
🟥 **2.1.1** — Mises à jour progressives — `strategy: RollingUpdate`, `maxSurge`, `maxUnavailable`  
🟥 **2.1.2** — Suivi et retour arrière — `kubectl rollout status/history/undo --to-revision`  

🟥 **2.2** — **ConfigMaps et Secrets** — `kubectl create configmap/secret --from-literal --from-file`  
🟥 **2.2.1** — Injection — `env.valueFrom`, `envFrom`, montage en volume  
🟥 **2.2.2** — Secrets — encodage base64, types (`generic`, `docker-registry`, `tls`)  

🟥 **2.3** — **Autoscaling** — `HorizontalPodAutoscaler`, `kubectl autoscale`, dépendance `metrics-server`  

🟥 **2.4** — **Applications auto-réparatrices** — `DaemonSet`, `StatefulSet`, `Job`, `CronJob`  
🟥 **2.4.1** — Sondes — `livenessProbe`, `readinessProbe`, `startupProbe`  
🟥 **2.4.2** — `restartPolicy`, `PodDisruptionBudget`  

🟥 **2.5** — **Admission et ordonnancement des Pods** — `resources.requests` / `limits`  
🟥 **2.5.1** — Placement simple — `nodeSelector`, `nodeName`  
🟥 **2.5.2** — Affinités — `nodeAffinity`, `podAffinity`, `podAntiAffinity`  
🟥 **2.5.3** — Taints et tolerations — `kubectl taint nodes`, `NoSchedule`, `NoExecute`  
🟥 **2.5.4** — Répartition — `topologySpreadConstraints`  
🟥 **2.5.5** — Priorité et préemption — `PriorityClass`  
🟥 **2.5.6** — Quotas — `ResourceQuota`, `LimitRange`  
🟥 **2.5.7** — Pods statiques — `/etc/kubernetes/manifests/`  

---

## 3. 🌐 Services et réseau — **20 %**

🟥 **3.1** — **Connectivité entre Pods** — modèle réseau plat, rôle du CNI, CIDR des pods  

🟥 **3.2** — **NetworkPolicy** — `podSelector`, `namespaceSelector`, `ipBlock`  
🟥 **3.2.1** — Règles `Ingress` et `Egress`, ports, deny-all par défaut  

🟥 **3.3** — **Services** — `ClusterIP`, `NodePort`, `LoadBalancer`, `ExternalName`  
🟥 **3.3.1** — Exposition — `kubectl expose`, `targetPort`, `selector`  
🟥 **3.3.2** — Endpoints — `kubectl get endpoints`, `EndpointSlice`  

🟥 **3.4** — **Gateway API** — `GatewayClass`, `Gateway`, `HTTPRoute`  

🟥 **3.5** — **Ingress** — contrôleur Ingress, ressource `Ingress`, `ingressClassName`, `pathType`  

🟥 **3.6** — **CoreDNS** — noms DNS `<svc>.<ns>.svc.cluster.local`, `dnsPolicy`, `/etc/resolv.conf`  

> 💡 La **Gateway API** est une nouveauté du curriculum 2025 — peu couverte par les anciens cours, à travailler directement sur la doc officielle.

---

## 4. 💾 Stockage — **10 %**

🟥 **4.1** — **StorageClass et provisionnement dynamique** — `provisioner`, `volumeBindingMode`  
🟥 **4.1.1** — StorageClass par défaut — annotation `storageclass.kubernetes.io/is-default-class`  

🟥 **4.2** — **Types de volumes** — `emptyDir`, `hostPath`, `configMap`, `secret`, `nfs`  
🟥 **4.2.1** — Modes d'accès — `ReadWriteOnce`, `ReadOnlyMany`, `ReadWriteMany`, `ReadWriteOncePod`  
🟥 **4.2.2** — Politiques de récupération — `Retain`, `Delete`  

🟥 **4.3** — **PV et PVC** — cycle de liaison, `kubectl get pv,pvc`, redimensionnement  
🟥 **4.3.1** — `volumeClaimTemplates` dans un `StatefulSet`  

---

## 5. 🔍 Dépannage — **30 %**

🟥 **5.1** — **Clusters et nœuds** — `kubectl get nodes`, `describe node`, conditions (`NotReady`, `DiskPressure`)  
🟥 **5.1.1** — Kubelet — `systemctl status kubelet`, `journalctl -u kubelet -f`, `/var/lib/kubelet/config.yaml`  
🟥 **5.1.2** — Certificats — expiration, `kubeadm certs check-expiration`, `kubeadm certs renew`  

🟥 **5.2** — **Composants du control plane** — manifestes statiques dans `/etc/kubernetes/manifests/`  
🟥 **5.2.1** — Diagnostic API server / scheduler / controller-manager / etcd  
🟥 **5.2.2** — Niveau runtime — `crictl ps -a`, `crictl logs`, `/var/log/pods/`  

🟥 **5.3** — **Consommation de ressources** — `kubectl top nodes`, `kubectl top pods`, `metrics-server`  
🟥 **5.3.1** — Événements — `kubectl get events --sort-by=.lastTimestamp`  

🟥 **5.4** — **Flux de sortie des conteneurs** — `kubectl logs -f`, `--previous`, `-c <conteneur>`  
🟥 **5.4.1** — États d'erreur — `CrashLoopBackOff`, `ImagePullBackOff`, `Pending`, `OOMKilled`, `Evicted`  

🟥 **5.5** — **Services et réseau** — endpoints vides, sélecteur qui ne correspond pas  
🟥 **5.5.1** — Test depuis un pod — `kubectl exec -it`, `kubectl run tmp --rm -it --image=busybox`  
🟥 **5.5.2** — Résolution DNS — `nslookup <svc>`, pods CoreDNS  
🟥 **5.5.3** — Accès local — `kubectl port-forward`, `kube-proxy`  

---

## 🗺️ Plan de démarrage — *départ à zéro*

**Phase 1 — Bases** : Section 0 en entier, sur un cluster déjà monté (`kind` ou `minikube` en local pour aller vite).  
**Phase 2 — Monter le cluster** : Section 1.2 → 1.3 sur les 3 VM Proxmox (`-01- Labs.md`), avec snapshot avant chaque étape.  
**Phase 3 — Applications** : Section 2 puis Section 3 (services d'abord, Ingress et Gateway ensuite).  
**Phase 4 — Stockage** : Section 4, la plus courte.  
**Phase 5 — Ops** : retour sur 1.4 → 1.8 (upgrade, etcd, HA, Helm, CRD) en cassant volontairement le cluster.  
**Phase 6 — Dépannage** : Section 5, en se faisant casser le cluster puis en réparant au chrono.  
**Phase 7 — Simulation** : killer.sh ×2 + examens blancs chronométrés.

---

## 📝 Informations examen

| | |
|---|---|
| **Durée** | 2 heures |
| **Format** | Pratique, en ligne, surveillé — ~15 à 20 tâches |
| **Score minimum** | **66 %** |
| **Environnement** | Terminal Linux, plusieurs clusters, `kubectl` / `helm` / `crictl` disponibles |
| **Documentation autorisée** | `kubernetes.io/docs`, `kubernetes.io/blog`, `helm.sh/docs` — **un seul onglet** |
| **Validité** | 2 ans |
| **Inclus** | 1 repassage gratuit + 2 sessions du simulateur killer.sh |

> ⚠️ La version de Kubernetes de l'examen suit la release courante et change tous les ~4 mois — **vérifier le curriculum officiel CNCF avant de réserver**.

---

## ✅ Checklist finale avant l'examen

🟥 Cluster kubeadm monté **from scratch** au moins 3 fois sans notes  
🟥 Sauvegarde + restauration `etcd` réussie sur un cluster cassé  
🟥 Upgrade de version complète (control plane + workers) réussie  
🟥 NetworkPolicy deny-all puis autorisation ciblée, validée par un test réel  
🟥 Ingress **et** Gateway API déployés et testés  
🟥 RBAC : créer un utilisateur limité et le prouver avec `auth can-i`  
🟥 Navigation dans `kubernetes.io/docs` sous 30 s pour tout objet  
🟥 `--dry-run=client -o yaml` utilisé par réflexe (jamais de YAML écrit à la main)  
🟥 Alias et autocomplétion configurés en moins de 60 s en début d'examen  
🟥 killer.sh terminé 2 fois avec toutes les questions comprises  
🟥 Score > 66 % sur examen blanc chronométré

---

*CKA — CNCF / Linux Foundation — Curriculum 2026*
