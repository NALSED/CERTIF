# 📚 RHCSA EX200 — Ressources Gratuites

---
## :one: `Ressources Anglophones`
## :two:  `Ressources Francophones`
## :three:  `Ressources par thémes`
## :four: `Examens Blancs`

---

## :one: **Ressources Anglophones**

### 🎬 YouTube — Chaînes recommandées

| Chaîne | Points forts | Lien |
|--------|-------------|--------|
| **Sander van Vugt** | Labs RHCSA RHEL 9/10, très proche de l'examen |  [Liens Youtube](https://www.youtube.com/playlist?list=PLC5eRS3MXpp8qgCiKYbZNhnTmfr57bYeU)|
| **beanologi** |  |  [Liens Youtube](https://www.youtube.com/watch?v=WDDkDw3LI3U&list=PLTY9BjMMGESFaq6TYB0E2RsmIxuQaZbFz) |
| **Eddie Jennings** | courbe d'apprentissage très bien pensée, tous les sujets traité :warning: RHEL 8 :warning:|  [Liens Youtube](https://www.youtube.com/watch?v=TB06LSPQySE&list=PLgYy5YCbiYbHh1ST5__ffj99eAjVfAwgy) |

---

## :two:  **Ressources Francophones**

| Chaîne | Points forts | Lien |
|--------|-------------|--------|
| **Xavki** | Sujet => LVM, Recherche, traité en profondeur |  [Liens Youtube](https://www.youtube.com/@xavki/search?query=rhcsa)|
| **Stéphane Robert** | Excellents conseils, et des execices bien construit|  [Blog](blog.stephane-robert.info/docs/admin-serveurs/linux) et [GitHub-RHCSA](github.com/stephrobert/linux-training) |
| **Goffinet** | Pour travailler, hors ligne :warning: RHEL 7et 8 traité :warning: |  [Liens Leanpub](https://leanpub.com/b/linux-administration-complet) |


`[NOTE]` Point de vigilance entre RHEL 8 et 10, il est tout à fait possible de travailler avec des support traitant de RHEL 8, voici les point de différences.
[Source Red Hat (11/03/2026)](https://www.redhat.com/en/services/training/ex200-red-hat-certified-system-administrator-rhcsa-exam?section=objectives)

Et le tableau à été construit avec les documentations officielles de redhat (11/03/2026)

# 🔄 RHEL 8 → RHEL 10 : Guide de transition RHCSA


## 📦 Gestion des paquets

| Sujet | RHEL 8 | RHEL 10 | Note |
|-------|--------|---------|------|
| Gestionnaire de paquets | `dnf` (DNF 4) | `dnf5` (DNF 5) | Les commandes `dnf` restent compatibles |
| Alias yum | `yum` → symlink vers `dnf` | `yum` → symlink vers `dnf5` | Même syntaxe, ça marche toujours |
| Modules AppStream | `dnf module enable/install` | Simplifié, moins utilisé | Les modules streams sont en retrait |
| Gestion logiciels alternatifs | — | `flatpak install/remove` | **Nouveau objectif RHCSA 10** |
| Dépôts Flatpak | — | `flatpak remote-add` | **Nouveau objectif RHCSA 10** |

---

## 🌐 Réseau

| Sujet | RHEL 8 | RHEL 10 | Note |
|-------|--------|---------|------|
| Config réseau | `/etc/sysconfig/network-scripts/ifcfg-*` (déprécié) | **NetworkManager uniquement** | Les fichiers ifcfg-* n'existent plus |
| Outil principal | `nmcli` / `nmtui` | `nmcli` / `nmtui` | Identique |
| Afficher les interfaces | `ifconfig` (net-tools, optionnel) | `ip addr` / `ip link` | `ifconfig` retiré — utiliser `ip` |
| Afficher les ports/sockets | `netstat` (net-tools) | `ss` | `ss -tlnp` remplace `netstat -tlnp` |
| Pare-feu bas niveau | `iptables` (fonctionnel) | **iptables retiré** — `nftables` uniquement | Pour l'exam : `firewall-cmd` suffit |
| Pare-feu haut niveau | `firewall-cmd` / `firewalld` | `firewall-cmd` / `firewalld` | Identique — backend nftables |
| Network teams | `teamd` / `nmcli team` | **Supprimé** — utiliser les bonds | Remplacer team par bond |
| Profils ifcfg | Format ifcfg encore supporté | **Format keyfile uniquement** | `/etc/NetworkManager/system-connections/` |

---

## 💾 Stockage

| Sujet | RHEL 8 | RHEL 10 | Note |
|-------|--------|---------|------|
| Table de partitions | MBR ou GPT | **GPT recommandé** par défaut | `parted` à privilégier sur `fdisk` |
| Outil de partitionnement | `fdisk`, `gdisk`, `parted` | `parted` (GPT), `fdisk` fonctionne encore | Même logique, syntaxe identique |
| LVM | `pvcreate`, `vgcreate`, `lvcreate` | Identique | Aucun changement |
| VDO | Package `vdo` séparé | **Intégré à LVM** (`lvcreate --type vdo`) | Syntaxe différente — **hors objectifs RHCSA 10** |
| Stratis | `stratisd` + `stratis-cli` | **Non dans les objectifs RHCSA 10** | Présent sur le système mais pas à l'examen |
| Swap | `mkswap`, `swapon` | Identique | Aucun changement |

---

## ⏱️ Planification de tâches

| Sujet | RHEL 8 | RHEL 10 | Note |
|-------|--------|---------|------|
| Cron | `crontab -e`, `/etc/cron.d/` | Toujours présent | Aucun changement |
| `at` | `at`, `atd` | Toujours présent | Aucun changement |
| systemd timers | Existant mais rarement demandé | **Objectif explicite RHCSA 10** | `OnCalendar=`, `systemctl list-timers` |
| Créer un timer | Rarement vu en exam RHEL 8 | `*.timer` + `*.service` requis | Savoir créer les deux unités |

---

## 🔒 Sécurité

| Sujet | RHEL 8 | RHEL 10 | Note |
|-------|--------|---------|------|
| SELinux | `semanage`, `restorecon`, `setsebool` | Identique + **ports SELinux** dans les objectifs | `semanage port -a -t -p tcp PORT` |
| iptables | Fonctionnel | **Supprimé** | N'apparaît plus, utiliser `firewall-cmd` |
| SSH | `ssh-keygen -t rsa` courant | `ssh-keygen -t ed25519` recommandé | RSA fonctionne encore |
| ACL | `setfacl`, `getfacl` | Identique | Aucun changement |
| `umask` / permissions par défaut | Objectif présent | **Objectif explicite** "manage default file permissions" | Même commandes |

---

## 📜 Scripts shell & outils

| Sujet | RHEL 8 | RHEL 10 | Note |
|-------|--------|---------|------|
| Bash | 5.0 | 5.2+ | Syntaxe identique |
| Python par défaut | `python3` (3.6) | `python3` (3.12) | Syntaxe compatible, vérifier les f-strings |
| `vim` / `nano` | Disponibles | Identiques | Aucun changement |
| `grep`, `sed`, `awk` | Identiques | Identiques | Aucun changement |

---

## ⚙️ Systemd & démarrage

| Sujet | RHEL 8 | RHEL 10 | Note |
|-------|--------|---------|------|
| `systemctl` | Identique | Identique | Aucun changement |
| GRUB | `grub2-mkconfig` | `grubby` **recommandé** + `grub2-mkconfig` | `grubby` plus simple pour les options kernel |
| Rescue mode | `rd.break` / `init=/bin/bash` | Identique | Aucun changement |
| Cibles systemd | `multi-user.target`, etc. | Identiques | Aucun changement |
| journald | `journalctl` | Identique | Aucun changement |

---

## 👥 Utilisateurs & groupes

| Sujet | RHEL 8 | RHEL 10 | Note |
|-------|--------|---------|------|
| `useradd`, `usermod`, `userdel` | Identiques | Identiques | Aucun changement |
| `passwd`, `chage` | Identiques | Identiques | Aucun changement |
| `sudoers` / `visudo` | Identique | Identique | Aucun changement |

---

## 📂 Systèmes de fichiers

| Sujet | RHEL 8 | RHEL 10 | Note |
|-------|--------|---------|------|
| xfs, ext4, vfat | `mkfs.xfs`, `mkfs.ext4` | Identiques | Aucun changement |
| NFS | `mount -t nfs` | Identique | Aucun changement |
| autofs | `/etc/auto.master` + `/etc/auto.*` | Identique | Aucun changement |
| CIFS/Samba | `mount -t cifs` (objectif RHCSA 8) | **Retiré des objectifs RHCSA 10** | Pas à l'examen |

---

## 📦 Conteneurs

| Sujet | RHEL 8 | RHEL 10 | Note |
|-------|--------|---------|------|
| Podman | **Objectif RHCSA 8** (depuis RHEL 8.4) | **Retiré des objectifs RHCSA 10** | Podman existe sur le système mais pas à l'exam |
| Skopeo / Buildah | Présents | Présents | Hors objectifs RHCSA |

---

## ✅ Résumé 

| Priorité | Action |
|----------|--------|
| 🔴 Critique | Oublier `ifconfig`/`netstat` → apprendre `ip addr` / `ss` |
| 🔴 Critique | Oublier `iptables` → utiliser uniquement `firewall-cmd` |
| 🔴 Critique | Oublier les fichiers `ifcfg-*` → tout passe par `nmcli` |
| 🟠 Important | Apprendre les **systemd timers** (pas juste cron) |
| 🟠 Important | Apprendre **Flatpak** (dépôts + install/remove) |
| 🟡 Mineur | `grubby` à la place de `grub2-mkconfig` (les deux fonctionnent) |
| 🟢 OK | LVM, SELinux, NFS, autofs, users, SSH → **identiques** |
| 🟢 OK | Podman vu dans des ressources RHEL 8 → **ignorer pour l'exam** |

---

*Référence : EX200 RHEL 10 — objectifs officiels Red Hat — 2026*

---


## :three:  **Ressources par thémes**


## 🟥 Section 1 — Outils essentiels

| Type | Ressource | Lien |
|------|-----------|------|
| 📄 Doc | Red Hat — Configuring basic system settings | https://docs.redhat.com/fr/documentation/red_hat_enterprise_linux/10/html/configuring_basic_system_settings |
| 📄 Doc | GNU Bash Manual (redirections, grep, pipes) | https://www.gnu.org/software/bash/manual/bash.html |

---

## 🟥 Section 2 — Gestion des logiciels

| Type | Ressource | Lien |
|------|-----------|------|
| 📄 Doc | Red Hat — DNF5 / gestion des paquets RPM | https://docs.redhat.com/fr/documentation/red_hat_enterprise_linux/10/html/managing_software_with_the_dnf_tool |
| 📄 Doc | Flatpak — Documentation officielle | https://docs.flatpak.org/en/latest/using-flatpak.html |
| 📄 Doc | Red Hat — Flatpak sur RHEL | https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/html/installing_and_using_dynamic_programming_languages/using-flatpak_installing-and-using-dynamic-programming-languages |

---

## 🟥 Section 3 — Scripts shell

| Type | Ressource | Lien |
|------|-----------|------|
| 🎬 Vidéo | Sander van Vugt — Bash Scripting in 4 Hours | https://www.youtube.com/@rhatcert |
| 📄 Doc | GNU Bash Reference — if, for, while, $? | https://www.gnu.org/software/bash/manual/bash.html#Shell-Scripts |

---

## 🟥 Section 4 — Systèmes en cours d'exécution

| Type | Ressource | Lien |
|------|-----------|------|
| 📄 Doc | Red Hat — systemd & journald | https://docs.redhat.com/fr/documentation/red_hat_enterprise_linux/10/html/monitoring_and_managing_system_status_and_performance |
| 📄 Doc | Red Hat — tuned profiles | https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/html/monitoring_and_managing_system_status_and_performance/getting-started-with-tuned_monitoring-and-managing-system-status-and-performance |

---

## 🟥 Section 5 — Stockage local

| Type | Ressource | Lien |
|------|-----------|------|
| 📄 Doc | Red Hat — LVM (pvcreate, vgcreate, lvcreate) | https://docs.redhat.com/fr/documentation/red_hat_enterprise_linux/10/html/configuring_and_managing_logical_volumes |
| 📄 Doc | Red Hat — Partitions fdisk/parted/GPT | https://docs.redhat.com/fr/documentation/red_hat_enterprise_linux/10/html/managing_storage_devices |

---

## 🟥 Section 6 — Systèmes de fichiers

| Type | Ressource | Lien |
|------|-----------|------|
| 📄 Doc | Red Hat — ext4 / xfs / NFS / autofs | https://docs.redhat.com/fr/documentation/red_hat_enterprise_linux/10/html/managing_file_systems |

---

## 🟥 Section 7 — Déploiement et gestion

| Type | Ressource | Lien |
|------|-----------|------|
| 📄 Doc | Red Hat — cron & systemd timers | https://docs.redhat.com/fr/documentation/red_hat_enterprise_linux/10/html/configuring_basic_system_settings |
| 📄 Doc | Red Hat — DNF5 / gestion des paquets | https://docs.redhat.com/fr/documentation/red_hat_enterprise_linux/10/html/managing_software_with_the_dnf_tool |

---

## 🟥 Section 8 — Réseau

| Type | Ressource | Lien |
|------|-----------|------|
| 📄 Doc | Red Hat — NetworkManager / nmcli / firewalld | https://docs.redhat.com/fr/documentation/red_hat_enterprise_linux/10/html/configuring_and_managing_networking |

---

## 🟥 Section 9 — Utilisateurs et groupes

| Type | Ressource | Lien |
|------|-----------|------|
| 📄 Doc | Red Hat — useradd, sudoers, chage | https://docs.redhat.com/fr/documentation/red_hat_enterprise_linux/10/html/configuring_basic_system_settings/managing-users-and-groups_configuring-basic-system-settings |

---

## 🟥 Section 10 — Sécurité

| Type | Ressource | Lien |
|------|-----------|------|
| 📄 Doc | Red Hat — SELinux ⚠️ *priorité absolue* | https://docs.redhat.com/fr/documentation/red_hat_enterprise_linux/10/html/using_selinux |
| 📄 Doc | Red Hat — ACL & firewalld | https://docs.redhat.com/fr/documentation/red_hat_enterprise_linux/10/html/securing_networks |
| 📄 Doc | Notes RHCSA SELinux (communautaire) | https://doc-rhel-rhcsa-prep.readthedocs.io/en/latest/security/selinux.html |

---

## 🎯 Bonus — Labs pratiques gratuits

| Ressource | Description | Lien |
|-----------|-------------|------|
| 🔴 Red Hat Developer | Compte gratuit = RHEL légal pour ton lab | https://developers.redhat.com/register |
| 🎓 Red Hat Learning Community | Forums + notes officielles | https://learn.redhat.com |
| 💻 GitHub — jrandj RHCSA | Commandes résumées par objectif EX200 | https://github.com/jrandj/redhat |


---

## :four: **Examens Blancs**
