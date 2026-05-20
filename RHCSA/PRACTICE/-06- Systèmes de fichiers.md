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

# 6.3 — Systèmes de fichiers réseau NFS — mount -t nfs, /etc/fstab

`[NOTE]`

Les prérequis sont disponible dans les menus déroulants ci dessous, la partie `NFS`, commence après.


<details>
<summary>
<h2>
 === INSTALL Serveur NFS ===
</h2>
</summary>

````
# Installer les prérequis NFS
dnf -y install nfs-utils

# Création dossier
 mkdir -p /nfsdata /home/ldap/ldapuser{1..9}

# Permission / Sécurité des répertoires à partager
# Editer le fichier de configuration
vim /etc/exports

/nfsdata      *(rw,no_root_squash)
/home/ldap    *(rw,no_root_squash)

# Autoriser / Activer le service nfs-server
systemctl enable --now nfs-server

# Régles firewalld
for i in nfs mountd rpc-bind; do firewall-cmd --add-service $i --permanent; done
# sorties attendues
success
success
success
# reload
firewall-cmd --reload

# TEST
# === Sur le serveur 192.168.0.6 ===
showmount -e localhost
# sorties attendues
Export list for localhost:
/home/ldap *
/nfsdata   *

exportfs -v
# sorties attendues
/nfsdata        <world>(sync,wdelay,hide,no_subtree_check,sec=sys,rw,secure,no_root_squash,no_all_squash)
/home/ldap      <world>(sync,wdelay,hide,no_subtree_check,sec=sys,rw,secure,no_root_squash,no_all_squash)
````

- Le serveur est actif.

</details>



<details>
<summary>
<h2>
=== INSTALL Repo sur client ===
</h2>
</summary>

- Sur le client pas de repo actif, création d'un repo depuis un .iso
````
# copie de l'iso
dd if=/dev/sr0 of=/rhel10.iso bs=1M

# Création point de montage
mkdir /mnt/repo

# Inscription à /etc/fstab
# Repo local
/rhel10.iso /mnt/repo iso9660 defaults 0 0

# Monter
mount -a

# Création du repo local dans /etc/yum.repo.d
vim /etc/yum.repo.d

[BaseOS]
name=BaseOS
baseurl=file:///mnt/repo/BaseOS
gpgcheck=0
enable=1

[AppStream]
name=AppStream
baseurl=file:///mnt/repo/AppStream
gpgcheck=0
enable=1

# TEST
dnf repoinfo
# Sorties attendues
Updating Subscription Management repositories.
Unable to read consumer identity

This system is not registered with an entitlement server. You can use "rhc" or "subscription-manager" to register.

BaseOS                                                                682 kB/s | 2.7 kB     00:00
AppStream                                                             110 MB/s | 1.5 MB     00:00
Repo-id            : AppStream
Repo-name          : AppStream
Repo-revision      : 1761027148
Repo-updated       : Tue 21 Oct 2025 10:12:28 +04
Repo-pkgs          : 4,514
Repo-available-pkgs: 4,514
Repo-size          : 6.5 G
Repo-baseurl       : file:///mnt/repo/AppStream
Repo-expire        : 172,800 second(s) (last: Wed 13 May 2026 10:54:08 +04)
Repo-filename      : /etc/yum.repos.d/local.repo

Repo-id            : BaseOS
Repo-name          : BaseOS
Repo-revision      : 1761027164
Repo-updated       : Tue 21 Oct 2025 10:12:45 +04
Repo-pkgs          : 946
Repo-available-pkgs: 946
Repo-size          : 1.3 G
Repo-baseurl       : file:///mnt/repo/BaseOS
Repo-expire        : 172,800 second(s) (last: Wed 13 May 2026 10:53:31 +04)
Repo-filename      : /etc/yum.repos.d/local.repo
Total packages: 5,460
````

</details>



- Installation des prérequis de nfs
````
dnf -y install nfs-utils

# test nfs depuis 192.168.0.11
showmount -e 192.168.0.6
# Sorties attendues
Export list for 192.168.0.6:
/home/ldap *
/nfsdata   *
```` 

---

## **NFS COMMENCE ICI**

`[NOTE]`

- Enregistrement DNS : 192.168.0.6 => serveur / 192.168.0.11 => client

- monter le partage `NFS` sur le client
````
# Depuis client
# Lister les partage dispo
showmount -e serveur
# Sorties
/home/ldap *
/nfsdata   *

# Créer le partage (le montage est temporaire)
mount serveur:/nfsdata /mnt

# Vérification
mount
# Sortie Recherchée
serveur:/nfsdata on /mnt type nfs4 (rw,relatime,vers=4.2,rsize=1048576,wsize=1048576,namlen=255,hard,fatal_neterrors=none,proto=tcp,timeo=600,retrans=2,sec=sys,clientaddr=192.168.0.11,local_lock=none,addr=192.168.0.6)
````


**Configurer autofs — /etc/auto.master, /etc/auto.***

`Fichier partagé`

1. Installer le paquet `autofs`

2. Éditer `/etc/auto.master` — définir le répertoire parent et pointer vers le fichier de map
````
/nfsdata /etc/auto.nfsdata
````

3. Créer `/etc/auto.nfsdata` — définir le sous-répertoire et le partage NFS
````
files -rw serveur:/nfsdata
````

4. Activer et démarrer le service `autofs`
````
systemctl enable --now autofs
# ou si déjà actif après modif
systemctl reload autofs
````

5. Tester en accédant au répertoire
````
# Sur le client
cd /nfsdata/files
ls
````

`Fichier /home`

1. Editer `/etc/auto.master`
````
/homes /etc/auto.homes
````

2. Créer / Editer `/etc/auto.homes`
````
* -rw serveur:/home/ldappuser/&
```` 

3. Activer et démarrer le service `autofs`
````
systemctl enable --now autofs
# ou si déjà actif après modif
systemctl reload autofs
````

4. Test
````
cd /homes/ldapuser1
# résultat attendu
root@client:/homes/ldapuser1#

````

---

# `[RESUME]`

1) `/etc/auto.master`
````
vim /etc/auto.master

/REPERTOIRE ou l'on trouvera le partage /etc/SOUS_FICHIER
/nfsdata                                /etc/auto.nfs
````

2) `/etc/auto.EDITER DANS auto.master`
````
# Fichier de partage
NOM_DU_REPERTOIRE_DU_PARTAGE      DROIT      NOM_DU_SERVEUR:/PARTAGE_NFS_SERVEUR 
file                              -rw        serveur:/nfsdata

# Fichier /home
WILDCARD      DROIT      NOM_DU_SERVEUR:/PARTAGE_NFS_SERVEUR/&
*             -rw        serveur:/home/ldap/&
````

---

# 6.5 — Problèmes de permissions — ls -lZ, stat, contexte SELinux
