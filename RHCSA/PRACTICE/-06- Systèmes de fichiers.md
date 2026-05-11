# -6- Créer et configurer des systèmes de fichiers

---
---

# 6.1 — Créer/monter/démonter vfat, ext4, xfs — mkfs.*, mount, umount

- Les partie `6.1` et `6.2` sont, dans le flux de gestion des espaces disque juste à la suite.

 Pour rappel du flux complet, 

1. parted /dev/sdb mkpart ...         =>  crée la partition (5.1)
2. mkfs.ext4 /dev/sdb1                => formate (système de fichier) (6.1)
3. mkdir /mnt/monpoint                => crée le point de montage (6.2)
4. mount /dev/sdb1 /mnt/monpoint      => monte (6.2)
5. /etc/fstab avec UUID               => persistant au reboot (6.2)

---

`[INTRO]`

- Une partition seule est juste de l'espace vide.

- Le système de fichiers, organise et administre cet espace.

- Le system de fichier organiser les données en blocs, créer la hiérarchie de fichiers et dossiers,
mémoriser les métadonnées (nom, taille, permissions, dates), suivre l'espace libre,
et protéger l'intégrité des données grâce à un journal en cas de coupure brutale.


---

**Systeme de fichier pour RHEL 10**

- XFS systeme par défaut => Scalabilité, gros volumes

- ext4 systeme alternatif => stable / réduction de taille possible

---

- L'utilitaire pour éditer des systemes de fichier est **mkfs**

**Commandes**
````
# Créer un systeme de fichier
mkfs.SYSTEME DE FICHIER /dev/sdX

# monter
mount

# démonter
unmount

# Inspecter démontage impossible
lsof /POINT DE MONTAGE
````

---


# 6.2 Montage au démarrage par UUID/label — /etc/fstab, blkid, lsblk -f, systemd

### **/etc/fstab**

`[INTRO]`

Pour identifier un point de montage et le rendre persistant dans `/etc/fstab`, il est possible d'utiliser 2 option  le `label` et `UUID`.

- **Label** : est défini par l'admnin sys (après la création du systemr de fichier), il peux être intégré dans le fichier `/etc/fstab`, mais si par mégarde 2 points de montage partage le même nom cela peux poser des problémes au niveau du stockage.

- **UUID** : numéro d'identification unique généré au moment du formatage.

Priviligier `UUID`

---

**Commandes Label**
````
# Label Ext
tune2fs -L

# Label XFS
xfs-admin -L

# mkfs
mkfs.* -L
````

**Commandes UUID**
````
# Lister les UUID
blkid

# Extraire les UUID vers /etc/fstab
blkid | grep "sdDEVICE" | awk '{print $2}' >> /etc/fstab
````
---

### **systemd**

- Alternative à fstab => `avantage` :

  - Dépendances — conditionner le démarrage d'un service à la disponibilité du point de montage.

  - Target — intégration native dans le système de targets systemd.

  - Logs — journalctl pour déboguer un montage raté, plus lisible que fstab.

  - Montage à la demande — possible via .automount

- Les points de montages fstab sont converti en points demontage `systemd`, présent dans le fichier `run/systemd/generator`
ou alors sous le format : point de montage.mount
````
/mnt/ext4/sdb1

deviens :
mnt-ext4-sdb1.mount
````
---
















---

# 6.3 — Systèmes de fichiers réseau NFS — mount -t nfs, /etc/fstab

---

# 6.4 — Configurer autofs — /etc/auto.master, /etc/auto.*

---

# 6.5 — Étendre des volumes logiques — lvextend, resize2fs, xfs_growfs

---

# 6.6 — Problèmes de permissions — ls -lZ, stat, contexte SELinux
