# 📋 RHCSA — Checklist de Progression
**Examen EX200** | Red Hat Enterprise Linux 10 | Version 2026  
Certification : *Red Hat Certified System Administrator*

---

**Date de passage : 27/05/2026**

---

## Progression globale

🟥 Non commencé 🟨 En cours 🟩 Maîtrisé  🟦 Sans Aide

🟩 Section 1 — Outils essentiels  
🟨 Section 2 — Gestion des logiciels  
🟥 Section 3 — Scripts shell  
🟨 Section 4 — Systèmes en cours d'exécution  
🟥 Section 5 — Stockage local  
🟥 Section 6 — Systèmes de fichiers  
🟨 Section 7 — Déploiement et gestion  
🟥 Section 8 — Réseau  
🟦 Section 9 — Utilisateurs et groupes  
🟥 Section 10 — Sécurité  

---

🟥 Non commencé 🟨 En cours 🟩 Maîtrisé  🟦 Sans Aide

## 1. 🛠️ Comprendre et utiliser les outils essentiels

🟦 **1.1** — Accéder à une invite shell et écrire des commandes — *Bash 5.x par défaut*  
🟦 **1.2** — Redirection des entrées/sorties — `>` `>>` `<` `2>` `|` `tee`  
🟩 **1.3** — `grep` et expressions régulières — `grep -E`, `grep -P`, `egrep`  
🟦 **1.4** — Accès distant via `ssh` — *OpenSSH 9.x, ED25519 privilégié*  
🟦 **1.5** — Changer d'utilisateur — `su`, `su -`, `sudo`  
🟩 **1.6** — Archiver et compresser — `tar`, `gzip`, `bzip2`, `xz`  
🟦 **1.7** — Créer et éditer des fichiers texte — `vim`, `nano` *(vim recommandé)*  
🟦 **1.8** — Gérer fichiers et répertoires — `mkdir -p`, `cp -r`, `rm -rf`, `mv`  
🟩 **1.9** — Liens physiques (`ln`) et symboliques (`ln -s`)  
🟩 **1.10** — Permissions `ugo/rwx` — `chmod`, `chown`, `chgrp`, `umask`  
🟦 **1.11** — Documentation système — `man`, `info`, `/usr/share/doc`, `man -k`  

---

## 2. 📦 Gérer les logiciels

🟩 **2.1** — Configurer l'accès aux dépôts RPM — `dnf config-manager`, `/etc/yum.repos.d/`  
🟩 **2.2** — Installer et supprimer des paquets RPM et DNF — `dnf install`, `dnf remove`, `rpm -ivh`  
🟥 **2.3** — Configurer l'accès aux dépôts Flatpak — `flatpak remote-add`, `flatpak remotes`  
🟥 **2.4** — Installer et supprimer des applications Flatpak — `flatpak install`, `flatpak uninstall`, `flatpak list`  

---

## 3. 📜 Créer des scripts shell simples

🟥 **3.1** — Exécution conditionnelle — `if`, `test`, `[ ]`, `[[ ]]`  
🟥 **3.2** — Boucles — `for`, `while`  
🟥 **3.3** — Entrées de script — `$1`, `$2`, `$@`, `$#`  
🟥 **3.4** — Codes de retour — `$?`, `exit`, `&&`, `||`  

---

## 4. ⚙️ Utiliser des systèmes en cours d'exécution

🟦 **4.1** — Démarrer, redémarrer, éteindre — `systemctl reboot`, `poweroff`, `shutdown`  
🟥 **4.2** — Démarrer dans différentes cibles — `systemctl isolate multi-user.target`  
🟥 **4.3** — Interrompre le démarrage pour accès root — GRUB → `rd.break` / `init=/bin/bash`  
🟦 **4.4** — Processus gourmands — `top`, `htop`, `ps aux`, `kill`, `killall`  
🟦 **4.5** — Priorité des processus — `nice`, `renice`  
🟩 **4.6** — Profils de tuning — `tuned-adm list`, `tuned-adm profile <nom>`  
🟦 **4.7** — Gestion des sessions actives — `loginctl`  
🟨 **4.8** — Journaux système et Persistance des journaux — `journald.conf` / `rsyslog` => `Storage=persistent`  
🟩 **4.9** — `systemd`  
🟥 **4.10** — Transfert sécurisé de fichiers — `scp`, `sftp`, `rsync`  
🟩 **4.11** — Gestion des fichier /tmp — `systemd-tmpfiles`  

---

## 5. 💾 Configurer le stockage local

🟥 **5.1** — Partitions GPT — `fdisk`, `gdisk`, `parted`  
🟥 **5.2** — Volumes physiques LVM — `pvcreate`, `pvremove`, `pvs`  
🟥 **5.3** — Groupes de volumes — `vgcreate`, `vgextend`, `vgs`  
🟥 **5.4** — Volumes logiques — `lvcreate`, `lvremove`, `lvs`  
🟥 **5.5** — Montage au démarrage par UUID/label — `/etc/fstab`, `blkid`, `lsblk -f`  
🟥 **5.6** — Ajout non destructif de partitions, LV et swap — `mkswap`, `swapon`, `swapoff`  

> 💡 RHEL 10 : GPT recommandé par défaut — privilégier `parted` sur `fdisk`

---

## 6. 📂 Créer et configurer des systèmes de fichiers

🟥 **6.1** — Créer/monter/démonter `vfat`, `ext4`, `xfs` — `mkfs.*`, `mount`, `umount`  
🟥 **6.2** — Systèmes de fichiers réseau NFS — `mount -t nfs`, `/etc/fstab`  
🟥 **6.3** — Configurer autofs — `/etc/auto.master`, `/etc/auto.*`  
🟥 **6.4** — Étendre des volumes logiques — `lvextend`, `resize2fs`, `xfs_growfs`  
🟥 **6.5** — Problèmes de permissions — `ls -lZ`, `stat`, contexte SELinux  

---

## 7. 🚀 Déployer, configurer et gérer des systèmes

🟩 **7.1** — Planification de tâches — `at`, `cron`, `crontab -e`, `systemd timers`  
🟦 **7.2** — Services au démarrage — `systemctl enable --now`, `systemctl disable`  
🟥 **7.3** — Cible de démarrage par défaut — `systemctl set-default`  
🟥 **7.4** — Services de temps — `chronyc`, `timedatectl`, `/etc/chrony.conf`  
🟦 **7.5** — Gestion des paquetages — `dnf install`, `dnf update`, `rpm -ivh`  
🟥 **7.6** — Chargeur de démarrage — `grubby`, `/etc/default/grub`, `grub2-mkconfig`  

> 💡 `systemd timers` = objectif explicite RHEL 10 — `OnCalendar=`, `systemctl list-timers`

---

## 8. 🌐 Gestion de base du réseau

🟥 **8.1** — Adresses IPv4 et IPv6 — `nmcli`, `nmtui`, `/etc/NetworkManager/`  
🟥 **8.2** — Résolution du nom d'hôte — `hostnamectl`, `/etc/hosts`, `/etc/resolv.conf`  
🟥 **8.3** — Services réseau au démarrage — `nmcli con mod ... connection.autoconnect yes`  
🟥 **8.4** — Pare-feu — `firewall-cmd --permanent`, `firewall-cmd --reload`  

> 💡 RHEL 10 : NetworkManager uniquement — `network-scripts` supprimé, `ip`/`ss` remplacent `ifconfig`/`netstat`

---

## 9. 👥 Gérer des groupes et utilisateurs système

🟦 **9.1** — Comptes utilisateur — `useradd`, `usermod`, `userdel -r`  
🟦 **9.2** — Mots de passe et validité — `passwd`, `chage`, `chage -l`  
🟦 **9.3** — Groupes — `groupadd`, `groupmod`, `groupdel`, `gpasswd -a`  
🟦 **9.4** — Accès super-utilisateur — `/etc/sudoers`, `visudo`, `/etc/sudoers.d/`  

---

## 10. 🔒 Gérer la sécurité

🟥 **10.1** — Pare-feu firewalld — `firewall-cmd --add-service`, `--add-port`, `--zone`  
🟥 **10.2** — Permissions par défaut des fichiers — `umask`, `chmod`  
🟥 **10.3** — Authentification SSH par clé — `ssh-keygen`, `ssh-copy-id`, `authorized_keys`  
🟥 **10.4** — Modes SELinux — `setenforce`, `/etc/selinux/config`  
🟥 **10.5** — Contextes SELinux — `ls -Z`, `ps -Z`, `id -Z`  
🟥 **10.6** — Restaurer les contextes — `restorecon -Rv`, `semanage fcontext`  
🟥 **10.7** — Labels de ports SELinux — `semanage port -l`, `semanage port -a`  
🟥 **10.8** — Booléens SELinux — `getsebool -a`, `setsebool -P`  

> 🔐 SELinux en mode **enforcing par défaut** sur RHEL 10 — ne jamais le désactiver !

---

## ✅ Checklist finale avant l'examen

🟥 Toutes les sections pratiquées en lab  
🟥 Chaque configuration testée après reboot  
🟥 SELinux maîtrisé — contextes, booléens, ports, violations  
🟥 LVM pratiqué sur disques vierges  
🟥 Flatpak — dépôts + install system-wide vs user  
🟥 systemd timers — créer, activer, vérifier  
🟥 `man` et `--help` utilisés sans filet  
🟥 Score > 210/300 sur examen blanc  

---

*RHCSA EX200 — RHEL 10 — 2026*
