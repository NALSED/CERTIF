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

- Résumé des flux :
````
=== Création ===
# Création du Physical Volume
pvcreate /dev/sdx

# Création du Group Volume
vgcreate NOM_DU_GROUPE /dev/sdx

# Création du volume logique
lvcreate -L TAILLE -n NAME NOM_DU_GROUPE 

# Créer le systeme de fichier
mkfs.ext4 /dev/NOM_DU_GROUPE/NAME

# Créer un point de montage
mkdir /mnt/monpoint

# Le rendre persistant dans fstab
````

**<============>**

````
=== Redimentionner VG et LV ===
# Avoir une partition disponible 
# Etendre le VG
vgextend NOM_GROUPE NOM_DU_DEVICE

# Etendre le LV

# 1) Partition non monté
lvextend -r -l 50%FREE  /dev/NOM_DU_VG/NOM_DU_LV # -r automatise le resize, si oublie xfs_grow (xfs) ou resize2fs (ext4)
mount /dev/NOM_DU_VG/NOM_DU_LV /POINT_DE_MONTAGE

# 2) Partition monté
# !!! le resize en fonction du systeme de fichier se fait après !!!
lvextend -L +10G /dev/NOM_DU_VG/NOM_DU_LV

# ext4
resize2fs /DEVICE

# xfs
xfs_growfs /POINT_DE_MONTAGE
````

**<============>**

````
# Démonter le point de montage
umount POINT_DE_MONTAGE

# Déplacer les data
pvmove -v /dev/sdx2 /dev/sdx1

# Supprimer le VG
vgreduce NOM_VG /dev/sdx1

#Supprimer le PV
pvremove /dev/sdx1
````

---


## **[EXEMPLE]**

### - 1) `Création`

-1.1- création de la partition
````
fdisk /dev/sdc n + t + w # n => nouvelle partition / t => type , ici lvm (optionel mais fait partie des bonnes pratiques) / w => write
````

-1.2- Création du `PV` => `Physical Volume`
````
pvcreate /dev/sdc1
````

-1.3- Création du `VG` => `Volum Group`
````
vgcreate vg_data /dev/sdc1
````

-1.4- Création du `LV` => `Logical Volume`
````
# Création par Taille => -L
lvcreate -L 10G -n lv_data vg_data

# Création la % d'espace du groupe => -l
lvcreate -l 50%FREE -n lv_data vg_data
````

-1.5- Création du systeme de fichier
````
mkfs.ext4 /dev/vg_data/lv_data
````

-1.6- Créer un point de montage
````
mkdir /mnt/lvm
````

-1.7- (Optionel) Inscription à fstab
⚠️ Bien récupérer `UUID` de /dev/mapper, du volume concerné et pas /dev/sdc1 ⚠️
````
# Récupérer l'UUID et l'envoyer à /etc/fstab
blkid /dev/mapper/vg_data/lv_data | grep "UUID" | awk '{print $2}' >> /etc/fstab

# Editer /etc/fstab
vim /etc/fstab

UUID /mnt/lvm ext4 defaults 0 0 
````

---
 
### - 2) `Redimentionner`

- On se servira de l'exemple précédent comme base

-2.1- Créer un partition ou utiliser un volume disponible

-2.2- Etendre le `VG` sur le volume disponible
````
vgextend vg_data /dev/sdd1
````

-2.3- Etendre le `LV`

`=== Volume non monté ===`
````
# Par taille
lvextend -r -L +5G /dev/vg_data/lv_data
mount /dev/vg_data/lv_data /mnt/lvm
# Par %
lvextend -r -l 50%FREE /dev/vg_data/lv_data
 ````

`=== Volume monté ===`
````
# Les deux options -L et -l sont possible
lvextend -L +5G /dev/vg_data/lv_data

# !!! Attention !!!
# Si etx4 (c'est le cas ICI)
resize2fs /dev/vg_data/lv_data

#si xfs
xfs_growfs /mnt/lvm
````

### - 3) `Supprimer`  


````
# Démonter le point de montage
umount /mnt/lvm

# Déplacer les data
pvmove -v /dev/sdc2 /dev/sdc1

# Supprimer le VG
vgreduce vg_data /dev/sdc1

#Supprimer le PV
pvremove /dev/sdc1
````

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

---

# 5.4 - Stratis

`[NOTE]`

- Fonctionnement de `Stratis` :
````
┌─────────────────────────────────┐
│        Applications / VFS       │
├─────────────────────────────────┤
│     XFS (système de fichiers)   │  <= toujours XFS, pas de choix
├─────────────────────────────────┤
│   thin provisioning (dm-thin)   │  <= via device-mapper
├─────────────────────────────────┤
│   cache optionnel (dm-cache)    │
├─────────────────────────────────┤
│        Pool Stratis             │  <= agrège les blocs bruts
├────────────┬────────────────────┤
│  /dev/sdb  │  /dev/sdc  │  ...  │  <= block devices
└────────────┴────────────────────┘
````

-1- Création d'un `pool` dedans on met des espace de stockage (/dev/sda /dev/sdb etc..)

-2- Création de `fs` ils partagent l'espace au sein d'un `pool`

-3- `Thin provisioning` : Quand un filesystem Stratis est créé, aucune taille fixe n'est allouée. Il a une taille "virtuelle" (exemple : 1 TiB), mais l'espace réel sur le pool n'est consommé qu'au fur et à mesure que des données sont écrites.


---

**=== Commandes Création ===**

### - Rechercher les paquet `Stratis` et installation
````
dnf search "stratis"

# Ici nous avont besoin de :
stratisd.x86_64 
stratis-cli.noarch 

dnf install -y stratisd stratis-cli
````

### - Démarrer de daemon de stratis
````
systemctl enable --now stratisd
````


### - Créer un `pool`
````
stratis pool create my_pool /dev/sde
````

### - Lister `pool` 
````
stratis pool list
# Sortie
Name                 Total / Used / Free        Properties                                   UUID   Alerts
my_pool   10 GiB / 833.00 MiB / 9.19 GiB   ~Le,~Ca,~Cr, Op   e512490f-bc76-4233-adfb-97d1df39abb6   WS001
````

### - Ajouter de l'espace
````
stratis pool add-data my_pool /dev/sdf
stratis pool list
# Sortie
Name                Total / Used / Free        Properties                                   UUID   Alerts
my_pool   20 GiB / 1.10 GiB / 18.90 GiB   ~Le,~Ca,~Cr, Op   e512490f-bc76-4233-adfb-97d1df39abb6
# la pool fait bien 20 GiB
````

### - Créer un `fs` et lister
````
stratis fs create my_pool my_fs

stratis fs list
# Sortie
Pool      Filesystem   Total / Used / Free / Limit            Device                       UUID       
my_pool   my_fs        1 TiB / 546 MiB / 1023.47 GiB / None   /dev/stratis/my_pool/my_fs   8d403998-c7c9-4472-8a5e-8aa2c56b4256
````

### - `/etc/fstab`
````
mkdir /stratis

blkid /dev/stratis/my_pool/my_fs | awk '{print $2}' >> /etc/fstab

UUID /POINT_DE_MONTAGE xfs default,x-systemd.requires=stratisd.service 0 0

systemctl daemon-reload
mount -a
````
⚠️ Stratis, dépend du daemon stratisd pour assembler les couches device-mapper avant que le filesystem soit accessible. Si systemd essaie de monter le filesystem avant que stratisd soit démarré => échec. ⚠️


---

**=== Snapshoot ===** 



