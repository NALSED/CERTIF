## Pod Priority / Qos

[https://kubernetes.io/docs/concepts/scheduling-eviction/pod-priority-preemption/#priorityclass](https://kubernetes.io/docs/concepts/scheduling-eviction/pod-priority-preemption/#priorityclass)
[https://kubernetes.io/docs/concepts/workloads/pods/pod-qos/#quality-of-service-classes](https://kubernetes.io/docs/concepts/workloads/pods/pod-qos/#quality-of-service-classes)
---

- Les objet `Pod Priority` / `Qos` sont des outils qui permettent :
   - **Pod Priority** (Préemption - Clusterwide) : Garantit le déploiement des applications critiques en expulsant des Pods secondaires si le cluster n'a plus de place.
   - **QoS** (Éviction - Local au Node) : Garantit la stabilité d'un worker en définissant l'ordre de sacrifice des Pods si la mémoire ou le disque du nœud sature.

---

## `-1-` **Pod Priority**

**=== Scheduler ===**

- Fonctionnement de l'objet `Pod Piority`

   - Il est rendu possible grace à l'objet `PriorityClass`
   - `PriorityClass` est ensuite intégré au .yaml de déploiement.
   - En fonction du niveau (Valeur Numérique) de priorité le `Scheduler` peux fair de la préemption sur des pod moins prioritaire (Niveau Cluster).

### `-1-` Créer les différent niveau `PriorityClass`

- l'idée est de créer plusieurs niveaux de priorité, pour par la suite les utiliser comme des `flag` lors des déploiement.

- Une valeur est importante pour le comportemennt de `PriorityClass` => **preemptionPolicy**, en effet si
   - preemptionPolicy: `PreemptLowerPriority` (Régle par défaut / valeur absente du .yaml ) Kubernetes tue (preempt) les Pods moins prioritaires s'il manque de ressources.
   - preemptionPolicy: `Never` Kubernetes place le Pod en tête de la file d'attente (queue jumping), mais ne tue jamais de Pods existants.

````

````



---

## `-2-` **Qos**

**=== Kubelet ===**
