# ☸️ CKA — Blueprint & Checklist de Progression
**Certified Kubernetes Administrator** | CNCF / Linux Foundation | Version 2026  
Curriculum officiel v1.34 *(mise à jour Février 2025 — Gateway API, Helm/Kustomize, opérateurs)*

---

**Date de passage : *à définir***  
**Point de départ : 🟥 débutant complet — aucune notion Kubernetes préalable**

---

## Comment lire ce document

Les compétences sont classées **par ordre d'apprentissage**, du plus simple au plus complexe — et non par domaine d'examen. Chaque palier ne suppose acquis **que les paliers précédents**. Aucun saut en avant nécessaire.

**Progression** : 🟥 Non commencé 🟨 En cours 🟩 Maîtrisé 🟦 Sans Aide

**Domaine d'examen** entre crochets, avec son poids officiel :

| Tag | Domaine officiel | Poids |
|---|---|---|
| `[BASE]` | Prérequis — *hors curriculum, mais indispensable* | — |
| `[ARCH]` | Architecture, installation et configuration du cluster | 25 % |
| `[WORK]` | Charges de travail et ordonnancement | 15 % |
| `[NET]` | Services et réseau | 20 % |
| `[STO]` | Stockage | 10 % |
| `[TS]` | Dépannage | 30 % |

Chaque palier se termine par un critère `✅ Validé quand :` — tant qu'il n'est pas atteint, ne pas passer au suivant.

> 📺 **Support vidéo : Sander van Vugt — CKA Complete Video Course, 4ᵉ édition.**  
> La correspondance leçon ↔ palier, l'ordre de visionnage recommandé et les **trous de couverture à combler** sont en [annexe, en fin de document](#-annexe--correspondance-avec-le-cours-sander-van-vugt-4ᵉ-éd).

---

## Progression globale

🟥 **ÉTAPE I** — Fondations `P1 → P4`  
🟥 **ÉTAPE II** — Applications `P5 → P10`  
🟥 **ÉTAPE III** — Réseau et stockage `P11 → P14`  
🟥 **ÉTAPE IV** — Ordonnancement et gouvernance `P15 → P19`  
🟥 **ÉTAPE V** — Administration du cluster `P20 → P23`  
🟥 **ÉTAPE VI** — Dépannage `P24 → P26`

---

## Carte de dépendances

```
ÉTAPE I — FONDATIONS
  P1 Linux/conteneurs ──► P2 Premier cluster ──► P3 Le Pod ──► P4 Vitesse & YAML
                                                                    │
ÉTAPE II — APPLICATIONS                                             ▼
  P5 Labels ──► P6 ConfigMap/Secret ──► P7 Ressources ──► P8 Multi-conteneurs
                                                                    │
                                          P9 Sondes ◄───────────────┤
                                              │                     │
                                              ▼                     │
                                          P10 Contrôleurs ◄─────────┘
                                              │
ÉTAPE III — RÉSEAU & STOCKAGE                 ▼
  P11 Services ──► P12 DNS ──► P13 Ingress/Gateway      P14 Stockage
                                              │              │
ÉTAPE IV — ORDONNANCEMENT & GOUVERNANCE       ▼              ▼
  P15 Scheduling ──► P16 RBAC/Quotas ──► P17 Métriques/HPA ──► P18 NetworkPolicy
                                                                    │
                                                    P19 Helm/Kustomize
                                                                    │
ÉTAPE V — ADMINISTRATION                                            ▼
  P20 Install kubeadm ──► P21 Lifecycle/etcd ──► P22 HA ──► P23 Extensions/CRD
                                                                    │
ÉTAPE VI — DÉPANNAGE                                                ▼
  P24 Applicatif ──► P25 Réseau/Services ──► P26 Nœud & control plane
```

> 💡 Le dépannage est **dernier** alors qu'il pèse 30 % : on ne répare pas ce qu'on ne sait pas construire. C'est un palier de **synthèse**, pas un palier d'apprentissage.

---
---

# ÉTAPE I — FONDATIONS

*Objectif : être capable de lire un cluster existant et d'écrire du YAML vite.*

---

## 🟥 P1 — Prérequis Linux et conteneurs `[BASE]`

**1.1** — SSH entre machines, `sudo`, gestion des droits fichiers  
**1.2** — `systemd` — `systemctl status/start/restart/enable`, unités  
**1.3** — Journaux — `journalctl -u <unité> -f`, `-n 100`, `--since`  
**1.4** — Édition `vim` — `dd`, `yy`, `p`, `/recherche`, `:set paste`, `:wq`, `:%s///g`  
**1.5** — Réseau Linux — `ip a`, `ip r`, `ss -tulpn`, `curl`, `nc -zv`, `dig` / `nslookup`  
**1.6** — Fichiers — `find`, `grep -r`, `tail -f`, `less`, redirections  
**1.7** — Notions conteneur — image, couches, registre, tag, `ENTRYPOINT` vs `CMD`  
**1.8** — Runtime `containerd` — `crictl ps -a`, `crictl images`, `crictl logs`, `crictl inspect`  
**1.9** — Syntaxe YAML — indentation 2 espaces, listes `-`, maps, blocs `|` et `>`, `---`

✅ **Validé quand :** tu édites un fichier de config système en `vim` et tu lis les logs d'un service planté sans chercher la syntaxe.

---

## 🟥 P2 — Premier contact avec un cluster `[BASE]`

**2.1** — Modèle mental — control plane (`kube-apiserver`, `etcd`, `kube-scheduler`, `kube-controller-manager`) vs nœud (`kubelet`, `kube-proxy`, runtime)  
**2.2** — Boucle de réconciliation — état désiré vs état réel  
**2.3** — Impératif vs déclaratif  
**2.4** — Fichier kubeconfig — `~/.kube/config`, blocs `clusters` / `users` / `contexts`  
**2.5** — Contextes — `kubectl config get-contexts`, `use-context`, `current-context`  
**2.6** — Namespace par défaut — `kubectl config set-context --current --namespace=<ns>`  
**2.7** — Lecture — `kubectl get <res>`, `-o wide`, `-o yaml`, `-n`, `-A`  
**2.8** — Inspection — `kubectl describe`, section `Events`  
**2.9** — Découverte de l'API — `kubectl api-resources`, `kubectl api-versions`  
**2.10** — Auto-documentation — `kubectl explain pod.spec.containers --recursive`  
**2.11** — Namespaces — création, isolation logique, ressources non-namespacées

✅ **Validé quand :** tu bascules entre 3 contextes et tu décris n'importe quel objet sans hésiter sur la syntaxe.

---

## 🟥 P3 — Le Pod `[WORK]`

**3.1** — `kubectl run <nom> --image=<img>`  
**3.2** — Phases — `Pending`, `Running`, `Succeeded`, `Failed`, `Unknown`  
**3.3** — Anatomie d'un manifeste Pod — `apiVersion`, `kind`, `metadata`, `spec.containers`  
**3.4** — Journaux — `kubectl logs`, `-f`, `--previous`, `-c <conteneur>`, `--tail`, `--since`  
**3.5** — Shell dans un conteneur — `kubectl exec -it <pod> -- sh`, `-c`  
**3.6** — Suppression — `kubectl delete pod`, `--force --grace-period=0`  
**3.7** — Accès local — `kubectl port-forward pod/<pod> 8080:80`  
**3.8** — `command` et `args` — surcharge de l'image  
**3.9** — Variables d'environnement — `env`, `value`  
**3.10** — Politique de récupération d'image — `imagePullPolicy`

✅ **Validé quand :** tu crées un Pod à la main en YAML, tu y entres, tu lis ses logs, tu le supprimes — sans documentation.

---

## 🟥 P4 — Vitesse et génération de YAML `[BASE]` ⚡

> ⚠️ **Palier le plus rentable de tout le blueprint.** 2 h pour ~20 tâches : celui qui écrit son YAML à la main ne finit pas.

**4.1** — Alias — `alias k=kubectl`, `complete -F __start_kubectl k`  
**4.2** — Variables — `export do='--dry-run=client -o yaml'`, `export now='--force --grace-period=0'`  
**4.3** — Config `vim` — `set tabstop=2 shiftwidth=2 expandtab` dans `~/.vimrc`  
**4.4** — Génération — `k run nginx --image=nginx $do > pod.yaml`  
**4.5** — Générateurs impératifs — `k create deploy/svc/cm/secret/job/cronjob/role/sa ... $do`  
**4.6** — Application — `k apply -f fichier.yaml`, `-f dossier/`, `-f -` (stdin)  
**4.7** — Modification en place — `k edit`, `k patch`, `k replace --force -f`  
**4.8** — Sauvegarde d'un objet — `k get <res> <nom> -o yaml > backup.yaml`  
**4.9** — Comparaison — `k diff -f fichier.yaml`  
**4.10** — Extraction ciblée — `-o jsonpath='{.items[*].metadata.name}'`, `--sort-by`, `-o custom-columns`  
**4.11** — Navigation `kubernetes.io/docs` — trouver un exemple copiable en < 30 s  

✅ **Validé quand :** ton environnement (alias, complétion, vim) est configuré en moins de 60 s, et tu n'écris plus jamais un manifeste de zéro.

---
---

# ÉTAPE II — APPLICATIONS

*Objectif : déployer, configurer et maintenir une application.*

---

## 🟥 P5 — Labels, sélecteurs et annotations `[WORK]`

**5.1** — Labels — clé/valeur sur `metadata.labels`  
**5.2** — Manipulation — `kubectl label pod x env=prod`, `--overwrite`, `env-` (retrait)  
**5.3** — Sélection par égalité — `-l env=prod`, `-l env!=dev`  
**5.4** — Sélection par ensemble — `-l 'env in (prod,staging)'`, `notin`, `!clé`  
**5.5** — Affichage — `--show-labels`, `-L env`  
**5.6** — Annotations vs labels — métadonnées non sélectionnables  
**5.7** — Lien sélecteur ↔ contrôleur — `spec.selector.matchLabels` ↔ `template.metadata.labels`

✅ **Validé quand :** tu comprends qu'un Service ou un Deployment **ne trouve rien** si le sélecteur et les labels divergent d'un caractère.

---

## 🟥 P6 — Configuration : ConfigMap et Secret `[WORK]`

**6.1** — Création ConfigMap — `--from-literal`, `--from-file`, `--from-env-file`  
**6.2** — Injection unitaire — `env.valueFrom.configMapKeyRef`  
**6.3** — Injection globale — `envFrom.configMapRef`  
**6.4** — Montage en volume — `volumes.configMap`, `items`, `subPath`, `defaultMode`  
**6.5** — Types de Secret — `generic`, `docker-registry`, `tls`  
**6.6** — Encodage — `base64 -w0`, `base64 -d`, `stringData` vs `data`  
**6.7** — Injection Secret — `secretKeyRef`, `envFrom.secretRef`, montage volume  
**6.8** — Accès registre privé — `imagePullSecrets`  
**6.9** — Objets immuables — `immutable: true`  
**6.10** — Rechargement — les volumes se mettent à jour, **pas les variables d'env**

✅ **Validé quand :** tu injectes la même clé par variable **et** par fichier monté, et tu sais laquelle survit à une mise à jour du ConfigMap.

---

## 🟥 P7 — Ressources et contexte de sécurité `[WORK]`

**7.1** — `resources.requests` — ce qui sert à l'**ordonnancement**  
**7.2** — `resources.limits` — ce qui sert à l'**exécution**  
**7.3** — Unités — CPU (`100m` = 0,1 cœur), mémoire (`Mi`, `Gi`)  
**7.4** — Classes QoS — `Guaranteed`, `Burstable`, `BestEffort` et ordre d'éviction  
**7.5** — Dépassement — CPU = throttling, mémoire = `OOMKilled` (code 137)  
**7.6** — `securityContext` niveau Pod — `runAsUser`, `runAsGroup`, `fsGroup`, `runAsNonRoot`  
**7.7** — `securityContext` niveau conteneur — `capabilities.add/drop`, `privileged`, `allowPrivilegeEscalation`, `readOnlyRootFilesystem`  
**7.8** — ServiceAccount — notion, `automountServiceAccountToken: false`

✅ **Validé quand :** tu expliques pourquoi un Pod sans `requests` peut être évincé en premier alors qu'il consomme peu.

---

## 🟥 P8 — Pods multi-conteneurs `[WORK]`

**8.1** — Namespace réseau partagé — communication via `localhost`  
**8.2** — Volume partagé — `emptyDir` entre conteneurs  
**8.3** — `initContainers` — exécution séquentielle, bloquante  
**8.4** — Sidecar natif — `initContainers` avec `restartPolicy: Always`  
**8.5** — Motifs — sidecar, ambassador, adapter  
**8.6** — Ciblage — `kubectl logs -c`, `kubectl exec -c`

✅ **Validé quand :** tu construis un Pod où un initContainer prépare un fichier qu'un sidecar sert et que le conteneur principal lit.

---

## 🟥 P9 — Sondes et auto-réparation `[WORK]`

**9.1** — `livenessProbe` — redémarre le conteneur  
**9.2** — `readinessProbe` — retire le Pod des **endpoints** du Service  
**9.3** — `startupProbe` — protège les démarrages lents  
**9.4** — Mécanismes — `exec`, `httpGet`, `tcpSocket`, `grpc`  
**9.5** — Réglages — `initialDelaySeconds`, `periodSeconds`, `timeoutSeconds`, `failureThreshold`, `successThreshold`  
**9.6** — `restartPolicy` — `Always`, `OnFailure`, `Never`  
**9.7** — `CrashLoopBackOff` — backoff exponentiel jusqu'à 5 min  
**9.8** — `terminationGracePeriodSeconds`, `preStop`

✅ **Validé quand :** tu distingues sans hésiter un problème de *liveness* (redémarrages en boucle) d'un problème de *readiness* (Pod Running mais trafic absent).

---

## 🟥 P10 — Contrôleurs de charge `[WORK]`

**10.1** — `ReplicaSet` — `replicas`, `selector`, `template`  
**10.2** — `Deployment` — gère les ReplicaSets, une révision par version  
**10.3** — Mise à l'échelle — `kubectl scale --replicas=N`  
**10.4** — Changement d'image — `kubectl set image deploy/x c=img:tag`  
**10.5** — Stratégies — `RollingUpdate` (`maxSurge`, `maxUnavailable`) vs `Recreate`  
**10.6** — Suivi — `kubectl rollout status`, `history`, `--revision=N`  
**10.7** — Retour arrière — `kubectl rollout undo`, `--to-revision=N`  
**10.8** — Pause — `kubectl rollout pause` / `resume`  
**10.9** — Rétention — `revisionHistoryLimit`, annotation `kubernetes.io/change-cause`  
**10.10** — `DaemonSet` — un Pod par nœud, tolérations implicites  
**10.11** — `Job` — `completions`, `parallelism`, `backoffLimit`, `activeDeadlineSeconds`  
**10.12** — `CronJob` — `schedule`, `concurrencyPolicy`, `suspend`, `startingDeadlineSeconds`, `successfulJobsHistoryLimit`

✅ **Validé quand :** tu fais une mise à jour progressive, tu la casses volontairement, tu la reviens en arrière et tu retrouves la révision fautive dans l'historique.

---
---

# ÉTAPE III — RÉSEAU ET STOCKAGE

*Objectif : exposer une application et lui donner de la persistance.*

---

## 🟥 P11 — Services `[NET]`

**11.1** — Modèle réseau — une IP par Pod, réseau plat, pas de NAT entre Pods  
**11.2** — `ClusterIP` — IP virtuelle stable, interne  
**11.3** — Chaîne sélecteur → Pods → **Endpoints**  
**11.4** — Vérification — `kubectl get endpoints`, `kubectl get endpointslices`  
**11.5** — Ports — `port` (Service) vs `targetPort` (conteneur) vs `nodePort` (nœud)  
**11.6** — `NodePort` — plage `30000-32767`  
**11.7** — `LoadBalancer` — dépend du provider / MetalLB en lab  
**11.8** — `ExternalName` — alias DNS, aucun proxy  
**11.9** — Service *headless* — `clusterIP: None`, retourne les IP de Pods  
**11.10** — Création rapide — `kubectl expose deploy/x --port=80 --target-port=8080`  
**11.11** — `kube-proxy` — modes `iptables`, `ipvs`, `nftables`

✅ **Validé quand :** face à un Service qui ne répond pas, ton **premier réflexe** est `kubectl get endpoints`.

---

## 🟥 P12 — DNS et CoreDNS `[NET]`

**12.1** — Nom pleinement qualifié — `<svc>.<ns>.svc.cluster.local`  
**12.2** — Résolution courte — `<svc>` dans le même namespace, `<svc>.<ns>` ailleurs  
**12.3** — CoreDNS — Deployment dans `kube-system` + ConfigMap `Corefile`  
**12.4** — Service `kube-dns` — IP DNS du cluster  
**12.5** — `/etc/resolv.conf` d'un Pod — `search`, `nameserver`, `ndots:5`  
**12.6** — `dnsPolicy` — `ClusterFirst`, `Default`, `None`, `ClusterFirstWithHostNet`  
**12.7** — `dnsConfig` — serveurs et recherches personnalisés  
**12.8** — Test — `kubectl run tmp --rm -it --image=busybox:1.28 -- nslookup <svc>`  
**12.9** — Enregistrements SRV et Pods d'un service headless

✅ **Validé quand :** tu résous un Service depuis un Pod d'un autre namespace et tu sais lire le `search` de son `resolv.conf`.

---

## 🟥 P13 — Ingress et Gateway API `[NET]`

**13.1** — Distinction **contrôleur Ingress** (le logiciel) vs **ressource Ingress** (la règle)  
**13.2** — Installation d'un contrôleur — `ingress-nginx`  
**13.3** — `IngressClass` et `spec.ingressClassName`  
**13.4** — Règles — `host`, `http.paths`, `backend.service.name/port`  
**13.5** — `pathType` — `Exact`, `Prefix`, `ImplementationSpecific`  
**13.6** — TLS — `spec.tls`, Secret de type `tls`  
**13.7** — `defaultBackend`  
**13.8** — Gateway API — installation des CRD (hors distribution standard)  
**13.9** — `GatewayClass` — l'implémentation  
**13.10** — `Gateway` — `listeners`, `protocol`, `port`, `allowedRoutes`  
**13.11** — `HTTPRoute` — `parentRefs`, `hostnames`, `rules.matches`, `backendRefs`  
**13.12** — Répartition de trafic — `backendRefs[].weight`  
**13.13** — Séparation des rôles : Gateway (infra) ≠ HTTPRoute (application)

✅ **Validé quand :** tu exposes la même application deux fois — une via Ingress, une via Gateway API — et tu expliques ce que la seconde apporte.

---

## 🟥 P14 — Stockage `[STO]`

**14.1** — `emptyDir` — cycle de vie du Pod, `medium: Memory`  
**14.2** — `hostPath` — chemin du nœud, `type:` (`Directory`, `File`, `DirectoryOrCreate`)  
**14.3** — `volumeMounts` — `mountPath`, `subPath`, `readOnly`  
**14.4** — `PersistentVolume` — `capacity`, `accessModes`, `persistentVolumeReclaimPolicy`, `storageClassName`  
**14.5** — `PersistentVolumeClaim` — demande de ressource, liaison automatique  
**14.6** — Modes d'accès — `ReadWriteOnce`, `ReadOnlyMany`, `ReadWriteMany`, `ReadWriteOncePod`  
**14.7** — Politiques de récupération — `Retain`, `Delete`  
**14.8** — Phases d'un PV — `Available`, `Bound`, `Released`, `Failed`  
**14.9** — `StorageClass` — `provisioner`, `parameters`, `reclaimPolicy`, `allowVolumeExpansion`  
**14.10** — `volumeBindingMode` — `Immediate` vs `WaitForFirstConsumer`  
**14.11** — Classe par défaut — annotation `storageclass.kubernetes.io/is-default-class`  
**14.12** — Provisionnement dynamique — PVC sans PV préexistant  
**14.13** — Redimensionnement — édition du PVC, `allowVolumeExpansion: true`  
**14.14** — `StatefulSet` — `volumeClaimTemplates`, identité stable, Service headless, ordre de déploiement

✅ **Validé quand :** tu crées un PVC qui reste `Pending` **volontairement**, et tu diagnostiques la cause (classe absente, mode d'accès incompatible, `WaitForFirstConsumer`).

---
---

# ÉTAPE IV — ORDONNANCEMENT ET GOUVERNANCE

*Objectif : décider où les Pods tournent, et qui a le droit de faire quoi.*

---

## 🟥 P15 — Ordonnancement `[WORK]`

**15.1** — Fonctionnement du scheduler — phase de **filtrage** puis de **scoring**  
**15.2** — `nodeName` — court-circuite le scheduler  
**15.3** — `nodeSelector` + labels de nœud — `kubectl label node <n> disk=ssd`  
**15.4** — `nodeAffinity` — `requiredDuringSchedulingIgnoredDuringExecution` vs `preferred...`  
**15.5** — Opérateurs — `In`, `NotIn`, `Exists`, `DoesNotExist`, `Gt`, `Lt`  
**15.6** — `podAffinity` / `podAntiAffinity` + `topologyKey`  
**15.7** — Taints — `kubectl taint nodes <n> clé=valeur:NoSchedule`, `PreferNoSchedule`, `NoExecute`  
**15.8** — Tolerations — `operator: Equal|Exists`, `tolerationSeconds`  
**15.9** — Taint du control plane — `node-role.kubernetes.io/control-plane:NoSchedule`  
**15.10** — `topologySpreadConstraints` — `maxSkew`, `topologyKey`, `whenUnsatisfiable`  
**15.11** — `PriorityClass` — `value`, `globalDefault`, préemption  
**15.12** — Pods statiques — `/etc/kubernetes/manifests/`, suffixe `-<nom-du-nœud>`, gérés par le kubelet seul  
**15.13** — `schedulerName` et ordonnanceurs multiples

✅ **Validé quand :** tu forces un Pod sur un nœud teinté, et tu expliques la différence entre `NoSchedule` (nouveaux Pods) et `NoExecute` (Pods déjà présents).

---

## 🟥 P16 — Gouvernance et RBAC `[ARCH]`

**16.1** — `ResourceQuota` — `hard` sur `pods`, `requests.cpu`, `limits.memory`, `count/<res>`  
**16.2** — `LimitRange` — `default`, `defaultRequest`, `min`, `max`, `type: Container|Pod|PersistentVolumeClaim`  
**16.3** — Interaction quota ↔ Pod sans `requests` → refus d'admission  
**16.4** — Modèle RBAC — **sujet** + **verbe** + **ressource**  
**16.5** — `Role` (namespacé) vs `ClusterRole` (global)  
**16.6** — `RoleBinding` vs `ClusterRoleBinding`  
**16.7** — Cas particulier : `RoleBinding` → `ClusterRole` = droits limités à un namespace  
**16.8** — Règles — `apiGroups`, `resources`, `verbs`, `resourceNames`, `subresources` (`pods/log`, `pods/exec`)  
**16.9** — Verbes — `get`, `list`, `watch`, `create`, `update`, `patch`, `delete`, `deletecollection`  
**16.10** — Génération — `kubectl create role/clusterrole/rolebinding/clusterrolebinding`  
**16.11** — Liaison à un ServiceAccount — `--serviceaccount=<ns>:<sa>`  
**16.12** — Vérification — `kubectl auth can-i <verbe> <res> --as=<user> -n <ns>`, `--as-group`, `--list`  
**16.13** — ClusterRoles par défaut — `cluster-admin`, `admin`, `edit`, `view`  
**16.14** — ClusterRoles agrégés — `aggregationRule`  
**16.15** — Construire un kubeconfig pour un ServiceAccount

✅ **Validé quand :** tu crées un compte limité à la lecture des Pods d'un seul namespace, et tu le **prouves** avec `auth can-i --as`.

---

## 🟥 P17 — Observabilité et autoscaling `[WORK]` `[TS]`

**17.1** — Installation `metrics-server` — en lab, `--kubelet-insecure-tls`  
**17.2** — `kubectl top nodes`, `kubectl top pods --containers`, `-A`  
**17.3** — Événements — `kubectl get events --sort-by=.lastTimestamp`, `-w`, `--field-selector`  
**17.4** — HPA rapide — `kubectl autoscale deploy/x --min=2 --max=10 --cpu-percent=70`  
**17.5** — HPA v2 — `metrics` (`Resource`, `Pods`, `Object`), `behavior`, stabilisation  
**17.6** — Dépendance stricte : **sans `requests`, pas de HPA sur CPU**  
**17.7** — Vérification — `kubectl get hpa`, colonne `TARGETS` à `<unknown>` = métriques absentes  
**17.8** — Notions — Cluster Autoscaler (nœuds) vs VPA (dimensionnement vertical)

✅ **Validé quand :** ton HPA passe de `<unknown>` à une valeur réelle et tu sais pourquoi il était à `<unknown>`.

---

## 🟥 P18 — NetworkPolicy `[NET]`

**18.1** — État par défaut — **tout est autorisé** entre tous les Pods  
**18.2** — Dès qu'une policy sélectionne un Pod, tout le reste est refusé pour le type concerné  
**18.3** — `policyTypes` — `Ingress`, `Egress`  
**18.4** — `podSelector: {}` — sélectionne **tous** les Pods du namespace  
**18.5** — Refus global — deny-all ingress + egress  
**18.6** — Sources — `podSelector`, `namespaceSelector`, `ipBlock` (+ `except`)  
**18.7** — ⚠️ Piège classique — deux entrées de liste `-` = **OU**, deux clés dans la **même** entrée = **ET**  
**18.8** — Ports et protocoles — `ports.port`, `protocol`, `endPort`  
**18.9** — Egress et DNS — toujours autoriser UDP/TCP **53** vers CoreDNS  
**18.10** — Prérequis CNI — Calico/Cilium oui, **Flannel seul n'applique rien**  
**18.11** — Validation — test réel `curl` / `nc` depuis un Pod autorisé puis un Pod interdit

✅ **Validé quand :** tu poses un deny-all, tu rouvres un seul flux, et le test `curl` échoue depuis partout ailleurs.

---

## 🟥 P19 — Helm et Kustomize `[ARCH]`

**19.1** — `helm repo add`, `repo update`, `search repo`  
**19.2** — `helm install <release> <chart> -n <ns> --create-namespace`  
**19.3** — `helm list -A`, `helm status`, `helm get values/manifest/all`  
**19.4** — Valeurs — `-f values.yaml`, `--set clé=valeur`, `helm show values`  
**19.5** — `helm upgrade --install`, `helm rollback <release> <rev>`, `helm history`  
**19.6** — `helm uninstall`  
**19.7** — Rendu hors cluster — `helm template`, `--dry-run`  
**19.8** — Structure d'un chart — `Chart.yaml`, `values.yaml`, `templates/`, `charts/`  
**19.9** — `kustomization.yaml` — `resources`, `namespace`, `namePrefix`, `commonLabels`, `images`  
**19.10** — Générateurs — `configMapGenerator`, `secretGenerator`, `generatorOptions`  
**19.11** — Bases et overlays — structure `base/` + `overlays/{dev,prod}/`  
**19.12** — Patches — `patches`, merge stratégique, JSON 6902  
**19.13** — Application — `kubectl kustomize <dir>`, `kubectl apply -k <dir>`

✅ **Validé quand :** tu installes un chart, tu changes une valeur par upgrade, tu reviens en arrière — et tu produis deux overlays Kustomize à partir d'une même base.

---
---

# ÉTAPE V — ADMINISTRATION DU CLUSTER

*Objectif : construire, faire évoluer et sauvegarder le cluster lui-même.*

---

## 🟥 P20 — Installation d'un cluster avec kubeadm `[ARCH]`

**20.1** — Prérequis — 2 vCPU, 2 Go RAM, hostname/MAC/`product_uuid` uniques, ports ouverts  
**20.2** — Swap — `swapoff -a` + commentaire dans `/etc/fstab`  
**20.3** — Modules noyau — `overlay`, `br_netfilter` via `/etc/modules-load.d/k8s.conf`  
**20.4** — Sysctl — `net.bridge.bridge-nf-call-iptables=1`, `net.ipv4.ip_forward=1`, `sysctl --system`  
**20.5** — Runtime — installation `containerd`, `config.toml`, **`SystemdCgroup = true`**  
**20.6** — Dépôt `pkgs.k8s.io` — installation `kubeadm` `kubelet` `kubectl` + `apt-mark hold`  
**20.7** — Pré-téléchargement — `kubeadm config images pull`  
**20.8** — Initialisation — `kubeadm init --pod-network-cidr=<cidr> --apiserver-advertise-address=<ip>`  
**20.9** — Kubeconfig admin — copie de `/etc/kubernetes/admin.conf` vers `~/.kube/config`  
**20.10** — Installation du CNI — Calico / Flannel / Cilium, cohérence avec le `--pod-network-cidr`  
**20.11** — Jonction des workers — `kubeadm token create --print-join-command`  
**20.12** — Anatomie du join — token + `--discovery-token-ca-cert-hash sha256:...`  
**20.13** — Gestion des tokens — `kubeadm token list/create/delete`, expiration 24 h  
**20.14** — Configuration par fichier — `kubeadm init --config <fichier>`  
**20.15** — Remise à zéro — `kubeadm reset` + nettoyage `/etc/cni/net.d`, `iptables`, `~/.kube`  
**20.16** — Vérification — `kubectl get nodes`, `kubectl get pods -n kube-system`

✅ **Validé quand :** tu montes un cluster 1 master + 2 workers **from scratch, sans notes**, trois fois de suite.

---

## 🟥 P21 — Cycle de vie et etcd `[ARCH]`

**21.1** — `kubectl cordon` / `uncordon` — marquage `SchedulingDisabled`  
**21.2** — `kubectl drain <nœud> --ignore-daemonsets --delete-emptydir-data --force`  
**21.3** — `kubeadm upgrade plan` — versions cibles disponibles  
**21.4** — Ordre de mise à jour — **control plane d'abord**, puis workers  
**21.5** — Séquence control plane — `apt-mark unhold` → maj `kubeadm` → `kubeadm upgrade apply vX.Y.Z` → maj `kubelet`/`kubectl` → `daemon-reload` + `restart kubelet` → `hold`  
**21.6** — Séquence worker — `drain` → maj `kubeadm` → `kubeadm upgrade node` → maj `kubelet` → restart → `uncordon`  
**21.7** — Politique d'écart de versions — kubelet jamais plus récent que l'apiserver, 3 versions mineures d'écart max  
**21.8** — Certificats — `kubeadm certs check-expiration`, `kubeadm certs renew all`  
**21.9** — etcd — Pod statique, données dans `/var/lib/etcd`  
**21.10** — Localiser les certificats — `/etc/kubernetes/pki/etcd/{ca.crt,server.crt,server.key}`  
**21.11** — Sauvegarde — `ETCDCTL_API=3 etcdctl snapshot save <fic> --endpoints=https://127.0.0.1:2379 --cacert= --cert= --key=`  
**21.12** — Vérification — `etcdctl snapshot status <fic> -w table`  
**21.13** — Restauration — `etcdctl snapshot restore <fic> --data-dir=<nouveau>` (ou `etcdutl` sur etcd ≥ 3.5)  
**21.14** — Après restauration — modifier le `hostPath` dans `/etc/kubernetes/manifests/etcd.yaml`, attendre le redémarrage  
**21.15** — Retrait d'un nœud — `drain` → `kubectl delete node` → `kubeadm reset` sur la machine

✅ **Validé quand :** tu casses volontairement le cluster (suppression de ressources), tu restaures un snapshot etcd, et tout revient.

---

## 🟥 P22 — Control plane hautement disponible `[ARCH]`

**22.1** — Topologies — etcd **empilé** (stacked) vs etcd **externe**  
**22.2** — Quorum — nombre **impair** de membres, tolérance `(n-1)/2` pannes  
**22.3** — Load balancer devant l'apiserver — HAProxy + Keepalived / VIP  
**22.4** — `kubeadm init --control-plane-endpoint=<vip>:6443 --upload-certs`  
**22.5** — Join control plane — `kubeadm join ... --control-plane --certificate-key <clé>`  
**22.6** — Régénérer la clé — `kubeadm init phase upload-certs --upload-certs`  
**22.7** — Vérification etcd — `etcdctl member list -w table`, `endpoint health --cluster`  
**22.8** — Domaines de panne — ce qui survit à la perte d'un nœud, de deux nœuds

✅ **Validé quand :** tu expliques pourquoi un cluster etcd à 2 membres est **moins** disponible qu'à 1 seul.

---

## 🟥 P23 — Interfaces d'extension, CRD et opérateurs `[ARCH]`

**23.1** — **CRI** — contrat kubelet ↔ runtime, `containerd` / `CRI-O`, socket `/run/containerd/containerd.sock`  
**23.2** — **CNI** — binaires `/opt/cni/bin`, configuration `/etc/cni/net.d`, plugin unique actif  
**23.3** — **CSI** — driver, plugin de nœud, plugin contrôleur, objets `CSIDriver` / `CSINode`  
**23.4** — Device plugins — exposition de ressources matérielles (GPU)  
**23.5** — `CustomResourceDefinition` — `apiextensions.k8s.io/v1`  
**23.6** — Anatomie d'une CRD — `group`, `names` (`kind`/`plural`/`singular`/`shortNames`), `scope`, `versions`, `schema`  
**23.7** — Exploitation — `kubectl get crd`, `kubectl explain <kind>`, `kubectl get <cr>`  
**23.8** — Motif opérateur — ressource personnalisée + contrôleur en boucle de réconciliation  
**23.9** — Installation d'un opérateur — manifeste, Helm ou OLM  
**23.10** — Contrôleurs d'admission — mutants vs validants, `ValidatingAdmissionPolicy`

✅ **Validé quand :** tu installes une CRD, tu crées une ressource personnalisée, et tu la retrouves via `kubectl explain`.

---
---

# ÉTAPE VI — DÉPANNAGE

*Objectif : réparer sous contrainte de temps. 30 % de l'examen.*

---

## 🟥 P24 — Dépannage applicatif `[TS]`

**24.1** — Méthode — `describe` → `Events` → `logs` → `logs --previous` → `exec`  
**24.2** — `Pending` — aucun nœud compatible : ressources, taints, affinité, PVC non lié  
**24.3** — `ImagePullBackOff` / `ErrImagePull` — nom, tag, registre, `imagePullSecrets`  
**24.4** — `CrashLoopBackOff` — l'application sort : `logs --previous`, code de sortie  
**24.5** — `OOMKilled` — code **137**, limite mémoire trop basse  
**24.6** — `ContainerCreating` bloqué — volume, Secret/ConfigMap absent, CNI  
**24.7** — `Evicted` — pression disque ou mémoire sur le nœud  
**24.8** — `Init:Error` / `Init:CrashLoopBackOff` — initContainer fautif  
**24.9** — `Running` mais sans trafic — readiness en échec, absent des endpoints  
**24.10** — `Terminating` bloqué — finalizers, `--force --grace-period=0`  
**24.11** — Conteneurs éphémères — `kubectl debug -it <pod> --image=busybox --target=<c>`  
**24.12** — Copie de debug — `kubectl debug <pod> --copy-to=<nom> --set-image=...`  
**24.13** — Codes de sortie — `0`, `1`, `125`, `126`, `127`, `137` (SIGKILL), `143` (SIGTERM)

✅ **Validé quand :** on te donne un Pod cassé au hasard et tu identifies la cause en moins de 2 minutes.

---

## 🟥 P25 — Dépannage réseau et services `[TS]`

**25.1** — Endpoints vides — sélecteur qui ne correspond pas, ou aucun Pod `Ready`  
**25.2** — Comparaison — `kubectl get pods --show-labels` vs `kubectl describe svc`  
**25.3** — `targetPort` erroné — le Service pointe vers un port non exposé  
**25.4** — Test par couches — `curl <podIP>` → `curl <clusterIP>` → `curl <nom-svc>`  
**25.5** — DNS — `nslookup kubernetes.default`, état des Pods CoreDNS, `Corefile`  
**25.6** — `kube-proxy` — DaemonSet présent, logs, règles `iptables -t nat -L`  
**25.7** — NetworkPolicy qui bloque — supprimer temporairement pour confirmer  
**25.8** — Ingress — contrôleur en marche, `ingressClassName` correct, Service backend existant  
**25.9** — CNI défaillant — Pods bloqués en `ContainerCreating`, nœud `NotReady`  
**25.10** — Contournement de test — `kubectl port-forward svc/<x> 8080:80`  
**25.11** — Boîte à outils — `busybox:1.28`, `nicolaka/netshoot`

✅ **Validé quand :** tu remontes une panne réseau couche par couche (Pod → Service → DNS → Ingress) sans sauter d'étape.

---

## 🟥 P26 — Dépannage nœud et control plane `[TS]` 🔥

> **Palier le plus difficile.** Il mobilise P1, P2, P15, P20 et P21 en même temps.

**26.1** — Nœud `NotReady` — kubelet arrêté, CNI absent, pression disque, certificat expiré  
**26.2** — Diagnostic kubelet — `systemctl status kubelet`, `journalctl -u kubelet -n 100 --no-pager`  
**26.3** — Fichiers kubelet — `/var/lib/kubelet/config.yaml`, `/etc/kubernetes/kubelet.conf`, `/var/lib/kubelet/kubeadm-flags.env`  
**26.4** — Incohérence de cgroup driver — `systemd` côté kubelet vs `cgroupfs` côté containerd  
**26.5** — Swap réactivé après reboot — le kubelet refuse de démarrer  
**26.6** — Conditions de nœud — `MemoryPressure`, `DiskPressure`, `PIDPressure`  
**26.7** — Manifestes statiques — `/etc/kubernetes/manifests/` : une erreur YAML fait tomber l'apiserver  
**26.8** — Quand `kubectl` ne répond plus — bascule sur `crictl ps -a`, `crictl logs <id>`  
**26.9** — Journaux bruts — `/var/log/pods/`, `/var/log/containers/`  
**26.10** — Scheduler arrêté — Pods `Pending` indéfiniment, aucun événement d'ordonnancement  
**26.11** — Controller-manager arrêté — Deployment sans ReplicaSet, nœuds non nettoyés  
**26.12** — etcd en panne — apiserver refuse de démarrer, erreurs de connexion `2379`  
**26.13** — Certificats expirés — erreurs `x509: certificate has expired`  
**26.14** — Mauvais kubeconfig ou mauvais contexte — `Unable to connect to the server`  
**26.15** — Fichiers du control plane — `/etc/kubernetes/{admin,controller-manager,scheduler}.conf`  
**26.16** — Forcer le redémarrage d'un Pod statique — déplacer le manifeste hors du dossier puis le remettre  
**26.17** — Ports à connaître — `6443` apiserver, `2379-2380` etcd, `10250` kubelet, `10259` scheduler, `10257` controller-manager

✅ **Validé quand :** on casse ton control plane sans te dire comment, et tu le remontes en moins de 10 minutes.

---
---

## 📊 Synthèse

| Étape | Paliers | Domaines couverts | Poids examen |
|---|---|---|---|
| I — Fondations | P1 → P4 | `[BASE]` `[WORK]` | *prérequis* |
| II — Applications | P5 → P10 | `[WORK]` | 15 % |
| III — Réseau & stockage | P11 → P14 | `[NET]` `[STO]` | 30 % |
| IV — Ordonnancement & gouvernance | P15 → P19 | `[WORK]` `[ARCH]` `[NET]` | — |
| V — Administration | P20 → P23 | `[ARCH]` | 25 % |
| VI — Dépannage | P24 → P26 | `[TS]` | 30 % |

**Points de bascule** — les paliers où le niveau de difficulté change nettement :

- **P4** — le palier le plus rentable : sans lui, le temps manque à l'examen
- **P11** — première abstraction non intuitive (Service ≠ Pod, endpoints)
- **P14** — première chaîne à 3 objets (SC → PV → PVC)
- **P20** — passage de *consommateur* à *administrateur* du cluster
- **P26** — synthèse finale : tout ce qui précède, sous chronomètre

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

> 💡 L'examen fournit **plusieurs clusters** : la 1ʳᵉ ligne de chaque question donne le `kubectl config use-context` à exécuter. L'oublier = 0 à la question.

---

## ✅ Checklist finale avant l'examen

🟥 Les 26 paliers passés en 🟦 *(sans aide)*  
🟥 Cluster kubeadm monté **from scratch** au moins 3 fois sans notes  
🟥 Sauvegarde + restauration `etcd` réussie sur un cluster cassé  
🟥 Upgrade de version complète (control plane + workers) réussie  
🟥 NetworkPolicy deny-all puis autorisation ciblée, validée par un test réel  
🟥 Ingress **et** Gateway API déployés et testés  
🟥 RBAC : créer un compte limité et le prouver avec `auth can-i --as`  
🟥 Navigation dans `kubernetes.io/docs` sous 30 s pour tout objet  
🟥 `--dry-run=client -o yaml` utilisé par réflexe (jamais de YAML écrit à la main)  
🟥 Alias et autocomplétion configurés en moins de 60 s en début d'examen  
🟥 killer.sh terminé 2 fois avec toutes les questions comprises  
🟥 Score > 66 % sur examen blanc chronométré

---
---

# 📺 ANNEXE — Correspondance avec le cours Sander van Vugt (4ᵉ éd.)

**Volume total : ~8 h 15 de vidéo**, 13 leçons réparties en 5 modules.

## Divergence d'ordre — à comprendre avant de commencer

Le cours et ce blueprint sont **inversés sur le bloc administration** :

```
SANDER      L1 Overview → L2 Install → L3 Nœuds → L4 Maintenance → L5 Sécurité
            → L6-8 Applications → L9-10 Réseau → L11-12 Stockage → L13 Dépannage

BLUEPRINT   P1-P4 Fondations → P5-P10 Applications → P11-P14 Réseau/Stockage
            → P15-P19 Ordo/Gouvernance → P20-P23 Administration → P24-P26 Dépannage
```

Son **Module 1 (L2→L5) correspond à mes P20, P21, P22, P16** — soit la fin de mon blueprint, livrée en premier. C'est normal : un cours vidéo doit te donner un cluster pour suivre les démos.

**Résolution** : suis **son** ordre pour les vidéos, et utilise les critères `✅ Validé quand :` du blueprint comme grille de validation. Le cluster monté en L2 est une **recette** ; le passage en 🟦 de P20 (monter sans notes, 3 fois) se fera plus tard.

---

## Table de correspondance

| Leçon | Titre | Paliers couverts | Couverture |
|---|---|---|---|
| **L1** | Kubernetes Overview | P2.1 · P2.2 | partielle |
| **L2** | Building a Kubernetes Cluster | **P20.1 → P20.14** · P23.1 · P23.2 | ✅ complète |
| **L3** | Managing Cluster Nodes | P1.8 · P15.12 · P21.1 · P21.2 · P26.2 · P26.3 · P26.8 | ✅ complète |
| **L4** | Cluster Maintenance | P17.1 · P17.2 · **P21.3 → P21.14** · **P22 entier** | ✅ complète |
| **L5** | Managing Security | P7.6 · P7.7 · P7.8 · **P16.4 → P16.15** | ✅ complète |
| **L6** | Running Applications | P3.x · P8 · P10.1-10.3 · P10.10 · P14.14 · P17.4-17.6 | ⚠️ voir trous |
| **L7** | Managing Applications (Helm/Kustomize) | **P19 entier** · P4.6 | ✅ complète |
| **L8** | Scheduling | P7.1-7.4 · **P15.1 → P15.11** · P16.1 → P16.3 | ✅ complète |
| **L9** | Networking | **P11 entier** · **P13 entier** · P3.7 · P25.10 | ✅ complète |
| **L10** | Advanced Networking | P12.1-12.4 · **P18.1 → P18.10** · P23.2 | ✅ complète |
| **L11** | Storage | P14.1 → P14.8 · P6.4 · P6.7 | ✅ complète |
| **L12** | StorageClass | P14.9 · P14.11 · P14.12 | ✅ complète |
| **L13** | Troubleshooting | P17.3 · P24 · P25 · P26 | ⚠️ **survolé** |

---

## ⚠️ Trous de couverture — à combler hors cours

Le cours est excellent sur l'administration, mais **ces paliers n'ont aucune leçon dédiée**. Trois d'entre eux sont des puces **explicites du curriculum officiel** :

| Palier manquant | Statut curriculum | Gravité |
|---|---|---|
| **P9 — Sondes** `liveness` / `readiness` / `startup` | ✅ puce officielle *(« self-healing »)* | 🔴 critique |
| **P23.5-23.10 — CRD et opérateurs** | ✅ puce officielle *(« understand CRDs, install operators »)* | 🔴 critique |
| **P10.4-10.9 — Rolling update et rollback** | ✅ puce officielle | 🟠 3 min 32 en L6.1, très léger |
| **P4 — Vitesse, `--dry-run`, alias, jsonpath** | hors curriculum, **décisif à l'examen** | 🔴 critique |
| **P5 — Labels, sélecteurs, annotations** | transverse, supposé acquis | 🟠 important |
| **P3 — Pod : phases, `logs`, `exec`** | supposé acquis (L6.4 = 1 min 9) | 🟠 important |
| **P6.1-6.3, 6.5-6.10 — ConfigMap/Secret en variables** | vu **uniquement en volume** (L11.7) | 🟠 important |
| **P10.11-10.12 — `Job` et `CronJob`** | absent | 🟡 secondaire |
| **P24.11-24.12 — `kubectl debug`, conteneurs éphémères** | absent | 🟡 secondaire |
| **P14.10, P14.13 — `volumeBindingMode`, resize PVC** | non explicite | 🟡 secondaire |
| **P20.15 — `kubeadm reset`** | absent | 🟡 secondaire |

> 🔴 **Le trou le plus dangereux : le dépannage.** La leçon 13 fait **~24 min pour 30 % de l'examen** — soit 5 % du cours. Elle donne la *méthode* (13.2 « Troubleshooting Flow »), pas le volume. Mes P24, P25 et P26 comptent ~40 items : ils se travaillent en **cassant le cluster**, pas en regardant des vidéos.

---

## Points forts du cours — à exploiter à fond

- **Gateway API** — 4 leçons, ~28 min, TLS inclus (L9.7→9.10). C'était le risque principal du curriculum 2025 : il est parfaitement couvert.
- **Haute disponibilité** — L4.6 (14 min) + L4.7 (7 min). Va au-delà du strict nécessaire.
- **RBAC** — 7 leçons dont « RBAC for Users » (13 min 49). Très complet, couvre tout P16.
- **etcd et upgrades** — L4.2→4.5, ~32 min + lab. Exactement le niveau attendu.
- **Provisionneur NFS** — L12.3 (11 min 29), directement applicable à ton lab Proxmox.

---

## Ordre de visionnage recommandé

| Étape | Contenu | Ajout hors cours |
|---|---|---|
| 1 | **L1 + L2** — monter le cluster sur les 3 VM Proxmox | — |
| 2 | ⏸️ **Pause** | **P2, P3, P4, P5** en autonomie — sans ça, tout le reste sera subi |
| 3 | **L3 + L4 + L5** | — |
| 4 | ⏸️ **Pause** | **P6** (injection par variables) + **P9** (sondes) |
| 5 | **L6** | **P10.4→10.12** (rollout undo/history, Jobs, CronJobs) |
| 6 | **L7 + L8** | — |
| 7 | **L9 + L10** | — |
| 8 | **L11 + L12** | **P14.10, P14.13** |
| 9 | ⏸️ **Pause** | **P23.5→23.10** (CRD et opérateurs) |
| 10 | **L13** | **P24, P25, P26 en profondeur** — casser le cluster et réparer au chrono |
| 11 | — | killer.sh ×2 + examens blancs |

> 💡 L'étape **2** est la plus importante du plan. Le cours suppose que tu sais déjà manipuler `kubectl` : partant de zéro, sauter cette pause te fera subir les leçons 3 à 13 au lieu de les pratiquer.

---

*CKA — Blueprint des compétences — CNCF / Linux Foundation — 2026*
