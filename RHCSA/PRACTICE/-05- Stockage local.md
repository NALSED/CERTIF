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
parted /dev/sdb mkpart primary 1MiB  10GiB  # partition 1
parted /dev/sdb mkpart primary 10GiB 20GiB  # partition 2
````

### **Etape suivante**

-  Création d'un systeme de fichier, voir Section 6 de la progression RHCSA.
[ICI](https://github.com/NALSED/CERTIF/blob/main/RHCSA/PRACTICE/-06-%20Syst%C3%A8mes%20de%20fichiers.md)

---
---

# 5.2 - LVM

`[INTRO]`

- LVM permet de gérer le stockage de manière flexible — redimensionner, étendre ou réduire des volumes à chaud, sans se soucier des limites physiques des disques.

```
┌──────────────────────────────────────────────────────┐
│                    PV (Physical Volume)              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  │
│  │  /dev/sda1  │  │  /dev/sdb1  │  │  /dev/sdc1  │  │
│  │    20G      │  │    20G      │  │    10G      │  │
│  └─────────────┘  └─────────────┘  └─────────────┘  │
├──────────────────────────────────────────────────────┤
│                    VG (Volume Group)                 │
│                        vg0                           │
│                    Total : 50G                       │
├──────────────────────────────────────────────────────┤
│                    LV (Logical Volume)               │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  │
│  │ /dev/vg0/lv1│  │ /dev/vg0/lv2│  │ /dev/vg0/lv3│  │
│  │   ext4 10G  │  │   xfs  20G  │  │   swap  2G  │  │
│  └─────────────┘  └─────────────┘  └─────────────┘  │
└──────────────────────────────────────────────────────┘
```

- **PV (Physical Volume)** — partition ou disque physique initialisé pour LVM via `pvcreate`.
- **VG (Volume Group)** — pool de stockage regroupant un ou plusieurs PV via `vgcreate`.
- **LV (Logical Volume)** — volume logique découpé dans le VG, formatable et montable via `lvcreate`.

Pour allez plus loin => [ICI](https://github.com/NALSED/TUTO/tree/main/PERSO/SAUVEGARDE/LVM)

---


---
---



# 5.2.1 — Volumes physiques LVM — pvcreate, pvremove, pvs


---

# 5.2.2 — Groupes de volumes — vgcreate, vgextend, vgs

---

# 5.2.3 — Volumes logiques — lvcreate, lvremove, lvs

---


---
---

# 5.3 — Ajout non destructif de partitions, LV et swap — mkswap, swapon, swapoff

-  Création d'une partion swap via fdisk :
**Etapes**
````
# -1- Avec fdisk création de la partion
# Comme pour une partion classique utiliser l'option 'n'

# Donner un type de partition
t => swap

# créer la fartion swap
mkswap /dev/sdb7

# Récupérer l'UUID et l'envoyer dans /etc/fstab
blkid /dev/sdb7 | grep "UUID" | awk '{print $2}' >> /etc/fstab
 
# Incription à /etc/fstab
UUID none swap defaults 0 0

# Activation
swapon /dev/sdb7
````

- Vérification
````
swapon --show

free -h
````






























