# -5- Configurer le stockage local

`[INTRO]`

### Partitions
Découper un disque en zones indépendantes. On utilise **parted** (GPT, standard moderne) ou **fdisk** (MBR, legacy). Chaque partition peut ensuite être formatée et montée indépendamment.

### LVM (Logical Volume Manager)
Couche d'abstraction au-dessus des partitions qui permet de redimensionner, étendre ou réduire des volumes à chaud. Composé de Physical Volumes (PV), Volume Groups (VG) et Logical Volumes (LV).

### Stratis
Solution de gestion de stockage avancée introduite sur RHEL 8, orientée simplicité. Elle gère automatiquement le thin provisioning et les snapshots via un **daemon (`stratisd`)** exposant une **API D-Bus** — ce qui permet une intégration et une automatisation plus poussée que LVM.

---
---

# 5.1 — Partitions GPT / MBR — fdisk, gdisk, parted

`[INTRO]`

- Différences partition **MBR** et **GPT**

| | MBR | GPT |
|---|---|---|
| Année | Ancien (1983) | Moderne (années 2000) |
| Taille max disque | 2 To | 9,4 Zo (illimité en pratique) |
| Nombre de partitions | 4 primaires max | 128 partitions max |
| UEFI | ✗ | ✓ obligatoire |
| BIOS legacy | ✓ | ✓ (compatible) |

### => Outils de partitionnement

- **fdisk** — outil interactif historique, MBR et GPT.
- **gdisk** — Spécialisé GPT.
- **parted** — outil recommandé par Red Hat sur RHEL 10, supporte MBR et GPT.

⚠️ La grosse différence, c'est que `parted` écrit immédiatement quand la commande est lancée, alors que `fdisk` et `gdisk` ont besoin de l'option **w** pour écrire la partition. ⚠️


---

**- Commandes Disk**
````
# List block devices
lsblk
````

---

### **=== FDISK ===**

**Syntaxe**
````
fdisk /dev/DISQUE DE DESTINATION
````

- `m` pour help puis suivre les instruction
 
---


### **=== GDISK ===**

`[NOTE]`
Son utilité historique :

Quand fdisk ne supportait pas encore GPT, gdisk était le seul outil en ligne de commande avec la logique "écriture à la confirmation (w)" pour le GPT.

---


### **=== PARTED ===**

- `parted` fait la même chose que `fdisk` en une seul ligne et les commandes sont donc scriptable.
Attention pas de demande de confirmation.

 **=== Principales commandes ===**
````
# liste tous les disques et partitions
parted --list

# initialise la table de partition
parted /dev/sdb mklabel LABEL (gpt / dos / etc...)

# crée de partition avec systeme de fichier
parted /dev/sdb mkpart primary ext4 1MiB  10GiB  # partition 1
parted /dev/sdb mkpart primary ext4 10GiB 20GiB  # partition 2
````



---
---

# 5.2 - LVM

---



# 5.2.1 — Volumes physiques LVM — pvcreate, pvremove, pvs


---

# 5.2.2 — Groupes de volumes — vgcreate, vgextend, vgs

---

# 5.2.3 — Volumes logiques — lvcreate, lvremove, lvs

---

# 5.2.4 — Montage au démarrage par UUID/label — /etc/fstab, blkid, lsblk -f

---
---

# 5.3 — Ajout non destructif de partitions, LV et swap — mkswap, swapon, swapoff
