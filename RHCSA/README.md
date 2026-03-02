# 📋 RHCSA — Guide de Connaissances Requises
**Examen EX200** | Red Hat Enterprise Linux 10 | Version 2026  
Certification : *Red Hat Certified System Administrator*

---

**Date de passage : 27/05/2026**

---

## Progression globale

- [ ] Section 1 — Outils essentiels
- [ ] Section 2 — Scripts shell
- [ ] Section 3 — Systèmes en cours d'exécution
- [ ] Section 4 — Stockage local
- [ ] Section 5 — Systèmes de fichiers
- [ ] Section 6 — Déploiement et gestion
- [ ] Section 7 — Réseau
- [ ] Section 8 — Utilisateurs et groupes
- [ ] Section 9 — Sécurité
- [ ] Section 10 — Conteneurs

---

## 1. 🛠️ Comprendre et utiliser les outils essentiels

| # | Statut | Objectif | Notes RHEL 10 |
|---|--------|----------|---------------|
| 1.1 | - [ ] | Accéder à une invite shell et écrire des commandes avec la syntaxe appropriée | Bash 5.x par défaut |
| 1.2 | - [ ] | Utiliser la redirection des entrées/sorties (`>`, `>>`, `<`, `2>`, `\|`, `tee`) | — |
| 1.3 | - [ ] | Utiliser `grep` et les expressions régulières pour analyser du texte | `grep -E`, `grep -P`, `egrep` |
| 1.4 | - [ ] | Accéder à des systèmes distants à l'aide de `ssh` | OpenSSH 9.x — ED25519 privilégié |
| 1.5 | - [ ] | Se connecter et changer d'utilisateur (`su`, `su -`, `sudo`) | — |
| 1.6 | - [ ] | Archiver, compresser, décompresser avec `tar`, `gzip`, `bzip2`, `xz` | `star` moins courant — focus `tar` |
| 1.7 | - [ ] | Créer et éditer des fichiers texte (`vim`, `nano`) | `vim` recommandé pour l'examen |
| 1.8 | - [ ] | Créer, supprimer, copier et déplacer fichiers et répertoires | `mkdir -p`, `cp -r`, `rm -rf`, `mv` |
| 1.9 | - [ ] | Créer des liens physiques (`ln`) et symboliques (`ln -s`) | — |
| 1.10 | - [ ] | Lister, définir et modifier les permissions `ugo/rwx` | `chmod`, `chown`, `chgrp`, `umask` |
| 1.11 | - [ ] | Localiser et utiliser la documentation système | `man`, `info`, `/usr/share/doc`, `man -k` |

---

## 2. 📜 Créer des scripts shell simples

| # | Statut | Objectif | Syntaxe clé |
|---|--------|----------|-------------|
| 2.1 | - [ ] | Exécution conditionnelle (`if`, `test`, `[ ]`, `[[ ]]`) | `if [ $var -eq 1 ]; then ... fi` |
| 2.2 | - [ ] | Boucles `for`, `while` pour traiter fichiers et arguments | `for i in $(cat file); do ... done` |
| 2.3 | - [ ] | Traiter les entrées de script (`$1`, `$2`, `$@`, `$#`) | — |
| 2.4 | - [ ] | Traiter les codes de retour (`$?`, `exit`, `&&`, `\|\|`) | `command && echo OK \|\| echo FAIL` |


---

## 3. ⚙️ Utiliser des systèmes en cours d'exécution

| # | Statut | Objectif | Commandes / Outils |
|---|--------|----------|--------------------|
| 3.1 | - [ ] | Démarrer, redémarrer et éteindre le système | `systemctl reboot`, `systemctl poweroff`, `shutdown` |
| 3.2 | - [ ] | Démarrer dans différentes cibles manuellement | `systemctl isolate multi-user.target` |
| 3.3 | - [ ] | Interrompre le démarrage pour accès root | Édition GRUB → `rd.break` ou `init=/bin/bash` |
| 3.4 | - [ ] | Identifier les processus gourmands, les arrêter | `top`, `htop`, `ps aux`, `kill`, `killall` |
| 3.5 | - [ ] | Adapter la priorité des processus | `nice`, `renice` |
| 3.6 | - [ ] | Gérer les profils de tuning | `tuned-adm list`, `tuned-adm profile <nom>` |
| 3.7 | - [ ] | Localiser et interpréter les journaux système | `journalctl`, `journalctl -u`, `/var/log/` |
| 3.8 | - [ ] | Préserver les journaux système | `journald.conf` → `Storage=persistent` |
| 3.9 | - [ ] | Démarrer, arrêter et vérifier les services réseau | `systemctl start/stop/status/enable` |
| 3.10 | - [ ] | Transférer des fichiers en toute sécurité | `scp`, `sftp`, `rsync` |

> **RHEL 10** : `journalctl` avec persistance activée par défaut si `/var/log/journal/` existe.

---

## 4. 💾 Configurer le stockage local

| # | Statut | Objectif | Outils |
|---|--------|----------|--------|
| 4.1 | - [ ] | Lister, créer, supprimer des partitions MBR et GPT | `fdisk` (MBR), `gdisk` / `parted` (GPT) |
| 4.2 | - [ ] | Créer et supprimer des volumes physiques LVM | `pvcreate`, `pvremove`, `pvs` |
| 4.3 | - [ ] | Attribuer des volumes physiques aux groupes de volumes | `vgcreate`, `vgextend`, `vgs` |
| 4.4 | - [ ] | Créer et supprimer des volumes logiques | `lvcreate`, `lvremove`, `lvs` |
| 4.5 | - [ ] | Monter des FS au démarrage par UUID ou label | `/etc/fstab` — `blkid`, `lsblk -f` |
| 4.6 | - [ ] | Ajouter partitions, LV et swap de manière non destructive | `mkswap`, `swapon`, `swapoff` |

> **RHEL 10** : GPT est le format de partition **recommandé par défaut**. `parted` privilégié sur `fdisk`.

---

## 5. 📂 Créer et configurer des systèmes de fichiers

| # | Statut | Objectif | Commandes |
|---|--------|----------|-----------|
| 5.1 | - [ ] | Créer, monter, démonter `vfat`, `ext4`, `xfs` | `mkfs.xfs`, `mkfs.ext4`, `mkfs.fat`, `mount`, `umount` |
| 5.2 | - [ ] | Monter et démonter des systèmes de fichiers réseau NFS | `mount -t nfs`, `/etc/fstab`, `autofs` |
| 5.3 | - [ ] | Étendre des volumes logiques existants | `lvextend`, `resize2fs`, `xfs_growfs` |
| 5.4 | - [ ] | Créer des répertoires Set-GID pour la collaboration | `chmod g+s`, `chown :groupe` |
| 5.5 | - [ ] | Configurer la compression de disque | **VDO** (intégré LVM dans RHEL 10) |
| 5.7 | - [ ] | Gérer le stockage en couches (layered storage) | `lvm thin`, `stratis` |
| 5.8 | - [ ] | Détecter et résoudre les problèmes de permissions | `ls -lZ`, `stat`, contexte SELinux |

> **RHEL 10** : **Stratis** pleinement supporté. **VDO** intégré dans LVM (`lvcreate --type vdo`).

---

## 6. 🚀 Déployer, configurer et gérer des systèmes

| # | Statut | Objectif | Outils / Commandes |
|---|--------|----------|--------------------|
| 6.1 | - [ ] | Planifier des tâches | `cron`, `crontab -e`, `anacron`, `systemd timers` |
| 6.2 | - [ ] | Gérer les services au démarrage | `systemctl enable --now`, `systemctl disable` |
| 6.3 | - [ ] | Configurer la cible de démarrage par défaut | `systemctl set-default graphical.target` |
| 6.4 | - [ ] | Configurer les services de temps | `chronyc`, `timedatectl`, `/etc/chrony.conf` |
| 6.5 | - [ ] | Installer et mettre à jour des paquetages | `dnf install`, `dnf update`, `rpm -ivh` |
| 6.6 | - [ ] | Modifier le chargeur de démarrage | `grubby`, `/etc/default/grub`, `grub2-mkconfig` |
| 6.7 | - [ ] | Travailler avec le gestionnaire de paquets | `dnf5` (défaut RHEL 10), `dnf search/info/provides` |

> **RHEL 10** : **DNF5** remplace DNF comme gestionnaire de paquets par défaut.

---

## 7. 🌐 Gestion de base du réseau

| # | Statut | Objectif | Outils |
|---|--------|----------|--------|
| 7.1 | - [ ] | Configurer les adresses IPv4 et IPv6 | `nmcli`, `nmtui`, fichiers `/etc/NetworkManager/` |
| 7.2 | - [ ] | Configurer la résolution du nom d'hôte | `hostnamectl set-hostname`, `/etc/hosts`, `/etc/resolv.conf` |
| 7.3 | - [ ] | Configurer les services réseau au démarrage | `nmcli con mod ... connection.autoconnect yes` |
| 7.4 | - [ ] | Restreindre l'accès réseau avec un pare-feu | `firewall-cmd --permanent`, `firewall-cmd --reload` |

> **RHEL 10** : **NetworkManager** est l'unique gestionnaire réseau. `
---

## 8. 👥 Gérer des groupes et utilisateurs système

| # | Statut | Objectif | Commandes |
|---|--------|----------|-----------|
| 8.1 | - [ ] | Créer, supprimer et modifier des comptes utilisateur | `useradd`, `usermod`, `userdel -r` |
| 8.2 | - [ ] | Modifier mots de passe et durée de validité | `passwd`, `chage`, `chage -l` |
| 8.3 | - [ ] | Créer, supprimer et modifier des groupes | `groupadd`, `groupmod`, `groupdel`, `gpasswd -a` |
| 8.4 | - [ ] | Configurer l'accès super-utilisateur | `/etc/sudoers`, `visudo`, `/etc/sudoers.d/` |

---

## 9. 🔒 Gérer la sécurité

| # | Statut | Objectif | Commandes / Fichiers |
|---|--------|----------|----------------------|
| 9.1 | - [ ] | Configurer le pare-feu avec `firewalld` | `firewall-cmd --add-service`, `--add-port`, `--zone` |
| 9.2 | - [ ] | Créer et utiliser des ACL sur les fichiers | `getfacl`, `setfacl -m u:user:rwx` |
| 9.3 | - [ ] | Configurer l'authentification SSH par clé | `ssh-keygen`, `ssh-copy-id`, `~/.ssh/authorized_keys` |
| 9.4 | - [ ] | Définir les modes SELinux `enforcing` / `permissive` | `setenforce`, `/etc/selinux/config` |
| 9.5 | - [ ] | Lister et identifier le contexte SELinux | `ls -Z`, `ps -Z`, `id -Z` |
| 9.6 | - [ ] | Restaurer les contextes de fichiers par défaut | `restorecon -Rv`, `semanage fcontext` |
| 9.7 | - [ ] | Modifier les booléens SELinux | `getsebool -a`, `setsebool -P` |
| 9.8 | - [ ] | Détecter et gérer les violations SELinux | `ausearch -m avc`, `sealert`, `audit2why` |

> **RHEL 10** : SELinux en mode **enforcing par défaut** — ne jamais le désactiver pendant l'examen !

---

## 10. 📦 Gérer les conteneurs

| # | Statut | Objectif | Commandes |
|---|--------|----------|-----------|
| 10.1 | - [ ] | Trouver et récupérer des images depuis un registre | `podman search`, `podman pull` |
| 10.2 | - [ ] | Inspecter les images de conteneurs | `podman inspect`, `skopeo inspect` |
| 10.3 | - [ ] | Gestion des conteneurs avec `podman` et `skopeo` | `podman images`, `podman ps -a`, `skopeo copy` |
| 10.4 | - [ ] | Gestion de base : lancer, démarrer, arrêter | `podman run`, `podman start/stop`, `podman rm` |
| 10.5 | - [ ] | Exécuter un service à l'intérieur d'un conteneur | `podman run -d --name`, variables `-e`, ports `-p` |
| 10.6 | - [ ] | Configurer un conteneur comme service systemd | `podman generate systemd` → `~/.config/systemd/user/` |
| 10.7 | - [ ] | Attacher un stockage persistant à un conteneur | `podman run -v /host/path:/container/path:Z` |

> **RHEL 10** : **Podman 5.x** — Quadlet recommandé pour les services. Conteneurs rootless privilégiés.  

---

## ✅ Checklist finale avant l'examen

- [ ] Toutes les sections ont été pratiquées en lab
- [ ] Chaque configuration testée après reboot
- [ ] SELinux maîtrisé — contextes, booléens, violations
- [ ] LVM / Stratis / VDO pratiqués sur disques vierges
- [ ] Podman rootless + service systemd fonctionnel
- [ ] `man` et `--help` utilisés sans filet
- [ ] Score > 210/300 sur examen blanc

---

*RHCSA EX200 — RHEL 10 — 2026*
