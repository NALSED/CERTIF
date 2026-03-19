# -02- Gestion des logiciels

---

- Ici sera exposé dans l'odre du document [README.md](https://github.com/NALSED/CERTIF/blob/main/RHCSA/README.md), section -02- Gestion des logiciels.

---

### **=== Définitions ===**

1️⃣ `RPM` :

- RPM Package Manager (RPM) est un `système`, bas niveau, qui exécute sur Red Hat Enterprise Linux, et permet `d'installer des binaires`, via une `archive compressé`.
- Il contient les métadata (stoquées dans `/var/lib/rpm`) du paquet, ainsi que les dépendences et est identifié avec `.rpm` 
- RPM est utilisé pour :
   - Inspecter un .rpm sans l'installer
   - Vérifier l'intégrité d'un paquet installé (Taille, checksum MD5, timestamp changés)
   - Interroger la base RPM (paquets installés)
   - Installer un .rpm local isolé (sans dépôt)
   - Forcer une opération (usage avancé/debug)


2️⃣ `Flatpak`

---

## **2.1** — Configurer l'accès aux dépôts RPM 

`[NOTE]` 
Pour la syntaxe 
````
man dnf.conf
````

<details>
<summary>
<h2>
I) Création repo local, sans vérification de clé GPG.
</h2>
</summary>

⚠️ Ici la persistance du point de montage `/repo`, à été effectué via `/etc/fstab`, voir => [lab](https://github.com/NALSED/CERTIF/blob/main/RHCSA/-01-Labs.md#-4-monter-les-repo-dans-etcfstab).

- Utilisation de `dnf config-manager`
````
sudo dnf config-manager --add-repo="file:///repo/BaseOS"
sudo dnf config-manager --add-repo="file:///repo/AppStream"

#Test
dnf repolist
#Sortie
repo id                                         repo name
repo_AppStream                                  created by dnf config-manager from file:///repo/AppStream
repo_BaseOS                                     created by dnf config-manager from file:///repo/BaseOS
rhel-10-for-x86_64-appstream-rpms               Red Hat Enterprise Linux 10 for x86_64 - AppStream (RPMs)
rhel-10-for-x86_64-baseos-rpms                  Red Hat Enterprise Linux 10 for x86_64 - BaseOS (RPMs)
````


</details>


---


<details>
<summary>
<h2>
II) Création repo local depuis iso, avec vérification de clé GPG.
</h2>
</summary>


Test sur Virtual Box avec un Iso `RHEL 10`
⚠️ Sans persistance du point de montage avec fstab le repo dans `/etc/yum.repo.d`, pointera vers /mnt qui sera vide, donc dnf échoura. ⚠️

`1)` Monter le disque RHEL 10 depuis Virtual Box.
````
sudo mount /dev/sr0 /mnt/
````
g
`2)` Regarder l'architecture de l'ISO
````
ls /mnt/
#Sortie
AppStream  BaseOS  boot  EFI  EULA  extra_files.json  Flatpaks  GPL  images  media.repo  RPM-GPG-KEY-redhat-beta  RPM-GPG-KEY-redhat-release

# Vérifier quel dossier contient des .rpm, avec tree ou find .
# Ici
AppStream  BaseOS
````

`3)` Création du fichier

- Les `repo` se place dans ce dossier :
`/etc/yum.repos.d`

- Editer le fichier en .repo


````
sudo tee /etc/yum.repos.d/local.repo << EOF
[AppStream]
name=AppStream local
baseurl=file:///mnt/AppStream/
gpgchek=1
gpgkey=file:///mnt/RPM-GPG-KEY-redhat-release

[BaseOS]
name=BaseOS Local
baseurl=file:///mnt/BaseOS/
gpgcheck=1
gpgkey=file:///mnt/RPM-GPG-KEY-redhat-release

EOF
````

4) Test

- repo enregistré en conforme
````
dnf repolist
# Sortie attendu
Not root, Subscription Management repositories not updated
repo id                                                        repo name
AppStream                                                      AppStream local
BaseOS                                                         BaseOS Local
rhel-10-for-x86_64-appstream-rpms                              Red Hat Enterprise Linux 10 for x86_64 - AppStream (RPMs)
rhel-10-for-x86_64-baseos-rpms                                 Red Hat Enterprise Linux 10 for x86_64 - BaseOS (RPMs)
````

- Test d'installation (en forcant l'install local car le compte RH est actif)
````
# Si compte non actif (chercher un paquet non installé sur la machine)
sudo dnf install aide.x86_64 -y

# Si compte actif
sudo dnf install --disablerepo "*" --enablerepo "BaseOS,AppStream"  acpid.x86_64 -y
# Sortie attendu
Updating Subscription Management repositories.
Last metadata expiration check: 0:09:03 ago on Wed 18 Mar 2026 12:42:16 +04.
Dependencies resolved.
=====================================================================================================================================================
 Package                         Architecture                     Version                                  Repository                           Size
=====================================================================================================================================================
Installing:
 acpid                           x86_64                           2.0.34-10.el10                           AppStream                            73 k

Transaction Summary
=====================================================================================================================================================
Install  1 Package

Total size: 73 k
Installed size: 146 k
Downloading Packages: <========== DOWNLOAD ABCENT Donc repo local utilisé
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.
Running transaction
  Preparing        :                                                                                                                             1/1
  Running scriptlet: acpid-2.0.34-10.el10.x86_64                                                                                                 1/1
  Installing       : acpid-2.0.34-10.el10.x86_64                                                                                                 1/1
  Running scriptlet: acpid-2.0.34-10.el10.x86_64                                                                                                 1/1
Installed products updated.

Installed:
  acpid-2.0.34-10.el10.x86_64

Complete!
````


</details>




## **=== Récapitulatif commandes ===**
````
# créer le repo
sudo dnf config-manager --add-repo="file:///CHEMIN REPO"

# Liste les repos actif (enable=1, par defaut dans les fichier de configuration .repo)
dnf repolist

#Instalation paquet
sudo dnf install NOM PAQUET -y

sudo dnf install --disablerepo "*" --enablerepo "NOM REPO" NOM PAQUET -y

# Activer désactiver Repo
dnf config-manager --enable NOM DU REPO
````




---

## **2.2** — Installer et supprimer des paquets RPM 

### `2.2.1` **===  Commandes ===**
 

### => Interroger un paquet 
- Différence notable sur les options :

   - `q` interroge la base RPM (paquet déjà installé)

   - `p` interroge le fichier .rpm (paquet local, avant installation)

 En fonction des besoin avec les commande ci dessous adapter en fonction.

```
rpm -qa                        # lister tous les paquets installés
rpm -qi bash                   # infos détaillées (version, date, description)
rpm -ql bash                   # fichiers installés par le paquet
rpm -qc bash                   # fichiers de configuration uniquement
rpm -qd bash                   # fichiers de documentation uniquement
rpm -q --scripts bash          # scripts pre/post install
rpm -q --requires bash         # dépendances requises
rpm -q --provides bash         # ce que le paquet fournit
```

## Interroger un fichier

```
rpm -qf /usr/bin/bash          # quel paquet a installé ce fichier
```

## Interroger un `.rpm` local (pas encore installé)

```
rpm -qip monpaquet.rpm         # infos du paquet local
rpm -qlp monpaquet.rpm         # fichiers qu'il va installer
```

> Le `p` = "package file" (fichier local, pas installé)

## Installer / Mettre à jour / Supprimer

```
rpm -ivh monpaquet.rpm         # installer (i=install, v=verbose, h=progress)
rpm -Uvh monpaquet.rpm         # upgrade (installe si absent, met à jour si présent)
rpm -Fvh monpaquet.rpm         # freshen (met à jour seulement si déjà installé)
rpm -e monpaquet               # désinstaller
rpm -e --nodeps monpaquet      # désinstaller sans vérifier les dépendances
```

## Vérifier l'intégrité

```
rpm -V bash                    # vérifier les fichiers d'un paquet installé
rpm -Va                        # vérifier tous les paquets
rpm --checksig monpaquet.rpm   # vérifier la signature GPG
```

## Filtrer / chercher

```
rpm -qa | grep http                        # chercher un paquet par nom
rpm -qa --qf "%{NAME} %{VERSION}\n"        # format personnalisé
```
## cpio (HORS SCOPE)
Est l'archiveur utilisé par RPM en interne:

````
# Voir ce qu'il y a dans l'archive sans extraire
rpm2cpio NOM DU PAQUET.rpm | cpio -tv

# Extraire un seul fichier
rpm2cpio NOM DU PAQUET.rpm | cpio -idmv CHEMIN

# Restaurer un fichier système corrompu sans réinstaller le paquet
rpm2cpio NOM DU PAQUET.rpm | cpio -idmv CHEMIN
````


1) Trouver un .rpm non installé en local dans `/mtn/AppStream/Package`
````
dnf list --available | head -20 | grep "AppStream"
# Sortie
CUnit.x86_64                                           2.1.3-34.el10                      AppStream
HdrHistogram_c.x86_64                                  0.11.8-7.el10                      AppStream
Judy.x86_64                                            1.0.5-38.el10                      AppStream
````

2) Installer le paquet
````
cd /mnt/AppStream/Packages/

sudo rpm -ihv CUnit.x86_64  
#Sortie
Verifying...                          ################################# [100%]
Preparing...                          ################################# [100%]
Updating / installing...
   1:CUnit-2.1.3-34.el10              ################################# [100%]
````

— Règle des arguments
 
| Option | Argument |
|--------|----------|
| `-i`, `-U`, `-F` | fichier `.rpm` |
| `-q`, `-e` | nom du paquet |
| `-qf` | chemin d'un fichier système |

`[NOTE]`
- Pour allez plus loin (hors scope) : [création / signature gpg](https://www.youtube.com/watch?v=dk0fwOQzZ2s&list=PLTY9BjMMGESFaq6TYB0E2RsmIxuQaZbFz) et [Configurer un serveur repo HTTP](https://www.youtube.com/watch?v=K7mgEKGVUkg&list=PLTY9BjMMGESFaq6TYB0E2RsmIxuQaZbFz) )


---

## **2.3** — Configurer l'accès aux dépôts Flatpak 


---

## **2.4** — Installer et supprimer des applications Flatpak 
