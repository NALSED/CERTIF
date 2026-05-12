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

````
=== Extention VG et LV ===
# Avoir une partition disponible 
# Etendre le VG
vgextend NOM_GROUPE NOM_DU_DEVICE

# Etendre le LV

# 1) Partition non monté
lvextend -r -l +50%FREE  /dev/NOM_DU_VG/NOM_DU_LV # -r automatise le resize, si oublie xfs_grow (xfs) ou resize2fs (ext4)
mount /dev/NOM_DU_VG/NOM_DU_LV /POINT_DE_MONTAGE

# 2) Partition monté
# !!! le resize en fonction du systeme de fichier se fait après !!!
lvextend -L +10G /dev/NOM_DU_VG/NOM_DU_LV

# ext4
resize2fs /DEVICE

--- 

## **[EXEMPLE]**


# xfs
xfs_growfs /POINT_DE_MONTAGE
````
