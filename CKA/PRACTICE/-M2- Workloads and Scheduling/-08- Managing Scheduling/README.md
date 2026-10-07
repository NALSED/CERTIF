## Fiche de Révision CKA : Mécanismes de Scheduling Kubernetes

### Synthèse des forces de placement

| Mécanisme | Direction de la force | Qui contrôle ? | Cible / Critère de filtrage |
| :--- | :--- | :--- | :--- |
| **Node Affinity** | **Attraction** (Pod => Nœud) | Le **Pod** | Labels du **Nœud** |
| **Taints & Tolerations** | **Répulsion** (Nœud => Pod) | Le **Nœud** | Pods **sans Toleration** |
| **Pod Affinity** | **Attraction** (Pod => Pod) | Le **Pod** | Labels des **autres Pods** |
| **Pod Anti-Affinity** | **Répulsion** (Pod => Pod) | Le **Pod** | Labels des **autres Pods** |

---

### Mémento réflexe pour l'examen

1. **`nodeAffinity` / `nodeSelector`**
   * **Usage :** Attirer un Pod vers un Nœud spécifique.
   * **Critère :** Inspecte les labels du Nœud (`metadata.labels`).

2. **`taints` & `tolerations`**
   * **Usage :** Réserver ou verrouiller un Nœud pour empêcher les Pods standards de s'y installer.
   * **Critère :** La Taint est appliquée sur le Nœud (`kubectl taint`), la Toleration dans la spec du Pod.

3. **`podAffinity`**
   * **Usage :** Colocaliser des Pods complémentaires sur la même machine/zone pour réduire la latence réseau (ex: Application + Cache local).
   * **Critère :** Inspecte les labels des Pods existants (`spec.affinity.podAffinity`).

4. **`podAntiAffinity`**
   * **Usage :** Éparpiller les répliques d'une application sur plusieurs Nœuds pour garantir la Haute Disponibilité (HA).
   * **Critère :** Inspecte les labels des Pods existants (`spec.affinity.podAntiAffinity`).
