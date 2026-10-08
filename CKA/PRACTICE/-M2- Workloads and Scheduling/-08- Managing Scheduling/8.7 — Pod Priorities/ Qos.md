## Pod Priority / Qos

---

- Les objet `Pod Priority` / `Qos` sont des outils qui permettent :
   - **Pod Priority** (Préemption - Clusterwide) : Garantit le déploiement des applications critiques en expulsant des Pods secondaires si le cluster n'a plus de place.
   - **QoS** (Éviction - Local au Node) : Garantit la stabilité d'un worker en définissant l'ordre de sacrifice des Pods si la mémoire ou le disque du nœud sature.
