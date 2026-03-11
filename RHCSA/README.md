# 📋 RHCSA — Checklist de Progression
**Examen EX200** | Red Hat Enterprise Linux 10 | Version 2026  
Certification : *Red Hat Certified System Administrator*

---

**Date de passage : 27/05/2026**


---

## Progression globale

✅ 

⬜ Section 1 — Outils essentiels  
⬜ Section 2 — Scripts shell  
⬜ Section 3 — Systèmes en cours d'exécution  
⬜ Section 4 — Stockage local  
⬜ Section 5 — Systèmes de fichiers  
⬜ Section 6 — Déploiement et gestion  
⬜ Section 7 — Réseau  
⬜ Section 8 — Utilisateurs et groupes  
⬜ Section 9 — Sécurité  
⬜ Section 10 — Conteneurs  

---

## 1. 🛠️ Comprendre et utiliser les outils essentiels

⬜ **1.1** — Accéder à une invite shell et écrire des commandes — *Bash 5.x par défaut*  
⬜ **1.2** — Redirection des entrées/sorties — `>` `>>` `<` `2>` `|` `tee`  
⬜ **1.3** — `grep` et expressions régulières — `grep -E`, `grep -P`, `egrep`  
⬜ **1.4** — Accès distant via `ssh` — *OpenSSH 9.x, ED25519 privilégié*  
⬜ **1.5** — Changer d'utilisateur — `su`, `su -`, `sudo`  
⬜ **1.6** — Archiver et compresser — `tar`, `gzip`, `bzip2`, `xz`  
⬜ **1.7** — Créer et éditer des fichiers texte — `vim`, `nano` *(vim recommandé)*  
⬜ **1.8** — Gérer fichiers et répertoires — `mkdir -p`, `cp -r`, `rm -rf`, `mv`  
⬜ **1.9** — Liens physiques (`ln`) et symboliques (`ln -s`)  
⬜ **1.10** — Permissions `ugo/rwx` — `chmod`, `chown`, `chgrp`, `umask`  
⬜ **1.11** — Documentation système — `man`, `info`, `/usr/share/doc`, `man -k`  

---

## 2. 📜 Créer des scripts shell simples

⬜ **2.1** — Exécution conditionnelle — `if`, `test`, `[ ]`, `[[ ]]`  
⬜ **2.2** — Boucles — `for`, `while`  
⬜ **2.3** — Entrées de script — `$1`, `$2`, `$@`, `$#`  
⬜ **2.4** — Codes de retour — `$?`, `exit`, `&&`, `||`  

> 💡 Shebang obligatoire `#!/bin/bash` + `chmod +x script.sh`

---

## 3. ⚙️ Utiliser des systèmes en cours d'exécution

⬜ **3.1** — Démarrer, redémarrer, éteindre — `systemctl reboot`, `poweroff`, `shutdown`  
⬜ **3.2** — Démarrer dans différentes cibles — `systemctl isolate multi-user.target`  
⬜ **3.3** — Interrompre le démarrage pour accès root — GRUB → `rd.break` / `init=/bin/bash`  
⬜ **3.4** — Processus gourmands — `top`, `htop`, `ps aux`, `kill`, `killall`  
⬜ **3.5** — Priorité des processus — `nice`, `renice`  
⬜ **3.6** — Profils de tuning — `tuned-adm list`, `tuned-adm profile <nom>`  
⬜ **3.7** — Journaux système — `journalctl`, `journalctl -u`, `/var/log/`  
⬜ **3.8** — Persistance des journaux — `journald.conf` → `Storage=persistent`  
⬜ **3.9** — Services réseau — `systemctl start/stop/status/enable`  
⬜ **3.10** — Transfert sécurisé de fichiers — `scp`, `sftp`, `rsync`  

---

## 4. 💾 Configurer le stockage local

⬜ **4.1** — Partitions MBR/GPT — `fdisk`, `gdisk`, `parted`  
⬜ **4.2** — Volumes physiques LVM — `pvcreate`, `pvremove`, `pvs`  
⬜ **4.3** — Groupes de volumes — `vgcreate`, `vgextend`, `vgs`  
⬜ **4.4** — Volumes logiques — `lvcreate`, `lvremove`, `lvs`  
⬜ **4.5** — Montage au démarrage par UUID/label — `/etc/fstab`, `blkid`, `lsblk -f`  
⬜ **4.6** — Ajout non destructif de partitions, LV et swap — `mkswap`, `swapon`, `swapoff`  

> 💡 RHEL 10 : GPT recommandé par défaut — privilégier `parted` sur `fdisk`

---

## 5. 📂 Créer et configurer des systèmes de fichiers

⬜ **5.1** — Créer/monter/démonter `vfat`, `ext4`, `xfs` — `mkfs.*`, `mount`, `umount`  
⬜ **5.2** — Systèmes de fichiers réseau NFS — `mount -t nfs`, `/etc/fstab`, `autofs`  
⬜ **5.3** — Étendre des volumes logiques — `lvextend`, `resize2fs`, `xfs_growfs`  
⬜ **5.4** — Répertoires Set-GID — `chmod g+s`, `chown :groupe`  
⬜ **5.5** — Compression de disque VDO — `lvcreate --type vdo` *(intégré LVM RHEL 10)*  
⬜ **5.7** — Stockage en couches — `stratis`, `lvm thin`  
⬜ **5.8** — Problèmes de permissions — `ls -lZ`, `stat`, contexte SELinux  

---

## 6. 🚀 Déployer, configurer et gérer des systèmes

⬜ **6.1** — Planification de tâches — `cron`, `crontab -e`, `anacron`, `systemd timers`  
⬜ **6.2** — Services au démarrage — `systemctl enable --now`, `systemctl disable`  
⬜ **6.3** — Cible de démarrage par défaut — `systemctl set-default`  
⬜ **6.4** — Services de temps — `chronyc`, `timedatectl`, `/etc/chrony.conf`  
⬜ **6.5** — Gestion des paquetages — `dnf install`, `dnf update`, `rpm -ivh`  
⬜ **6.6** — Chargeur de démarrage — `grubby`, `/etc/default/grub`, `grub2-mkconfig`  
⬜ **6.7** — Gestionnaire de paquets — `dnf5` *(défaut RHEL 10)*, `dnf search/info/provides`  

---

## 7. 🌐 Gestion de base du réseau

⬜ **7.1** — Adresses IPv4 et IPv6 — `nmcli`, `nmtui`, `/etc/NetworkManager/`  
⬜ **7.2** — Résolution du nom d'hôte — `hostnamectl`, `/etc/hosts`, `/etc/resolv.conf`  
⬜ **7.3** — Services réseau au démarrage — `nmcli con mod ... connection.autoconnect yes`  
⬜ **7.4** — Pare-feu — `firewall-cmd --permanent`, `firewall-cmd --reload`  

> 💡 RHEL 10 : NetworkManager uniquement — `network-scripts` supprimé, `ip`/`ss` remplacent `ifconfig`/`netstat`
---

## 8. 👥 Gérer des groupes et utilisateurs système

⬜ **8.1** — Comptes utilisateur — `useradd`, `usermod`, `userdel -r`  
⬜ **8.2** — Mots de passe et validité — `passwd`, `chage`, `chage -l`  
⬜ **8.3** — Groupes — `groupadd`, `groupmod`, `groupdel`, `gpasswd -a`  
⬜ **8.4** — Accès super-utilisateur — `/etc/sudoers`, `visudo`, `/etc/sudoers.d/`  

---

## 9. 🔒 Gérer la sécurité

⬜ **9.1** — Pare-feu firewalld — `firewall-cmd --add-service`, `--add-port`, `--zone`  
⬜ **9.2** — ACL sur fichiers — `getfacl`, `setfacl -m u:user:rwx`  
⬜ **9.3** — Authentification SSH par clé — `ssh-keygen`, `ssh-copy-id`, `authorized_keys`  
⬜ **9.4** — Modes SELinux — `setenforce`, `/etc/selinux/config`  
⬜ **9.5** — Contextes SELinux — `ls -Z`, `ps -Z`, `id -Z`  
⬜ **9.6** — Restaurer les contextes — `restorecon -Rv`, `semanage fcontext`  
⬜ **9.7** — Booléens SELinux — `getsebool -a`, `setsebool -P`  
⬜ **9.8** — Violations SELinux — `ausearch -m avc`, `sealert`, `audit2why`  

> 🔐 SELinux en mode **enforcing par défaut** sur RHEL 10 — ne jamais le désactiver !

---

## 10. 📦 Gérer les conteneurs

⬜ **10.1** — Récupérer des images — `podman search`, `podman pull`  
⬜ **10.2** — Inspecter des images — `podman inspect`, `skopeo inspect`  
⬜ **10.3** — Gestion avec podman/skopeo — `podman images`, `podman ps -a`, `skopeo copy`  
⬜ **10.4** — Gestion de base — `podman run`, `podman start/stop`, `podman rm`  
⬜ **10.5** — Service dans un conteneur — `podman run -d --name`, `-e`, `-p`  
⬜ **10.6** — Conteneur comme service systemd — Quadlet / `~/.config/systemd/user/`  
⬜ **10.7** — Stockage persistant — `podman run -v /host/path:/container/path:Z`  

> 💡 RHEL 10 : Podman 5.x — conteneurs rootless privilégiés + `loginctl enable-linger <user>`

---

## ✅ Checklist finale avant l'examen

⬜ Toutes les sections pratiquées en lab  
⬜ Chaque configuration testée après reboot  
⬜ SELinux maîtrisé — contextes, booléens, violations  
⬜ LVM / Stratis / VDO pratiqués sur disques vierges  
⬜ Podman rootless + service systemd fonctionnel  
⬜ `man` et `--help` utilisés sans filet  
⬜ Score > 210/300 sur examen blanc  

---

*RHCSA EX200 — RHEL 10 — 2026*
