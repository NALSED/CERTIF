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
| **Eddie Jennings** | courbe d'apprentissage très bien pensée, sujets traité dans l'odre de la doc RH :warning: RHEL 8 :warning:|  [Liens Youtube](https://www.youtube.com/watch?v=TB06LSPQySE&list=PLgYy5YCbiYbHh1ST5__ffj99eAjVfAwgy) |

---

## :two:  **Ressources Francophones**

| Chaîne | Points forts | Lien |
|--------|-------------|--------|
| **Xavki** | Sujet => LVM, Recherche, traité en profondeur |  [Liens Youtube](https://www.youtube.com/@xavki/search?query=rhcsa)|
| **Stéphane Robert** | Excellents conseils, et des execices bien construit|  [Blog](blog.stephane-robert.info/docs/admin-serveurs/linux) et [GitHub-RHCSA](github.com/stephrobert/linux-training) |
| **Goffinet** | Pour travailler, hors ligne :warning: RHEL 7et 8 traité :warning: |  [Liens Leanpub](https://leanpub.com/b/linux-administration-complet) |


`[NOTE]` Point de vigilance entre RHEL 8 et 10, il est tout à fait possible de travailler avec des support traitant de RHEL 8, voici les point de différences.
[Source Red Hat (11/03/2026)](https://www.redhat.com/en/services/training/ex200-red-hat-certified-system-administrator-rhcsa-exam?section=objectives)

Les tableau sont construit avec les documentations officielles de redhat (11/03/2026)

<details>
<summary>
<h2>
🔄 RHEL 8 → RHEL 10 : Guide de transition RHCSA
</h2>
</summary>


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

## ⚙️ Systemd & démarrage

| Sujet | RHEL 8 | RHEL 10 | Note |
|-------|--------|---------|------|
| GRUB | `grub2-mkconfig` | `grubby` **recommandé** + `grub2-mkconfig` | `grubby` plus simple pour les options kernel |
| journald | `journalctl` | Identique | Aucun changement |


---

## 📂 Systèmes de fichiers

| Sujet | RHEL 8 | RHEL 10 | Note |
|-------|--------|---------|------|
| CIFS/Samba | `mount -t cifs` (objectif RHCSA 8) | **Retiré des objectifs RHCSA 10** | Pas à l'examen |

---

## 📦 Conteneurs

| Sujet | RHEL 8 | RHEL 10 | Note |
|-------|--------|---------|------|
| Podman | **Objectif RHCSA 8** (depuis RHEL 8.4) | **Retiré des objectifs RHCSA 10** | Podman existe sur le système mais pas à l'exam |
| Skopeo / Buildah | Présents | Présents | Hors objectifs RHCSA |


*Référence : EX200 RHEL 10 — objectifs officiels Red Hat — 2026*

</details>




---


## :three:  **Ressources par thémes**


# RHCSA — Tableaux de ressources

---
:warning: Si abscence de liens et `OK`, sujet déjà maitrisé avant `RHCSA` :warning:

`[NOTE]` Les tableaux suivants listent les ressources utilisées en fonction des thèmes, pour être sûr de ne pas me perdre ou trop m'éloigner de ce qui est attendu lors de l'examen, j'ai comme fil rouge :
Vidéo complète de préparation à l'examen de [Sander van Vugt](https://www.oreilly.com/videos/rhcsa-rhel-9/9780135397237/), ainsi que le [Documentation Officielle](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/)

## 1. Outils essentiels
🎬
📄
| Section | Type | Lien |
|---------|------|------|
| 1.2 — Redirections I/O | 🎬 | [Eddie Jennings](https://www.youtube.com/watch?v=Vnv8cELgIQ8&list=PLgYy5YCbiYbHh1ST5__ffj99eAjVfAwgy&index=3) |
| 1.3 — grep & regex | 🎬 et 📄 | [Eddie Jennings](https://www.youtube.com/watch?v=h7HWWugPPpY&list=PLgYy5YCbiYbHh1ST5__ffj99eAjVfAwgy&index=4) et [Exercices](https://github.com/NALSEDCERTIF/tree/main/RHCSA/PRACTICE/EXO/GREP) |
| 1.4 — Accès SSH | 🎬 et 🎬 | [Eddie Jennings](https://www.youtube.com/watch?v=YinR8zIK_3g&list=PLgYy5YCbiYbHh1ST5__ffj99eAjVfAwgy&index=5) et [_Techcurator](https://www.youtube.com/watch?v=305AJx2aTm0)|
| 1.5 — Changement utilisateur | 🎬 et 🎬 | [Eddie Jennings](https://www.youtube.com/watch?v=f1liwlGvw5s&list=PLgYy5YCbiYbHh1ST5__ffj99eAjVfAwgy&index=6) et [Xavki](https://www.youtube.com/watch?v=1XqBbDQ0C1g) |
| 1.6 — Archivage | 🎬 et 🎬 |  [Eddie Jennings](https://www.youtube.com/watch?v=_q9ww3pF0U4&list=PLgYy5YCbiYbHh1ST5__ffj99eAjVfAwgy&index=7) et [xavki](https://www.youtube.com/watch?v=uVksM-i4HT8) |
| 1.7 — Édition fichiers texte | | `OK` |
| 1.8 — Gestion fichiers/répertoires | | `OK` |
| 1.9 — Liens physiques/symboliques | 🎬 | [It_Connect](https://www.youtube.com/watch?v=MCQI0lLGbUw) |
| 1.10 — Permissions ugo/rwx | 🎬 et 🎬 et 📄 et 📄 | [Eddie Jennings - permissions](https://www.youtube.com/watch?v=talHSb28aIg&list=PLgYy5YCbiYbHh1ST5__ffj99eAjVfAwgy&index=11) et [xavki - permissions](https://www.youtube.com/watch?v=A2aaJVc5PD8) et [malekal - umask](https://www.malekal.com/quest-ce-que-umask-et-comment-utiliser-la-commande-umask/) et [malekal - suid/guid/sticky-bit](https://www.malekal.com/suid-sgid-sticky-bit-linux/)|
| 1.11 — Documentation système | | `OK` |

---

## 2. Gestion des logiciels

| Section | Type | Lien |
|---------|------|------|
| 2.1 — Dépôts RPM | 🎬 et 📄  et 🎬| [Alphorm](https://www.youtube.com/watch?v=0hIpRAPPSMI) et [lea-linux](https://lea-linux.org/documentations/RPM) et [beanologi RPM-1-](https://www.youtube.com/watch?v=dk0fwOQzZ2s&list=PLTY9BjMMGESFaq6TYB0E2RsmIxuQaZbFz&index=27) |
| 2.2 — Paquets RPM | 🎬 et 🎬 | [beanologi RPM-1-](https://www.youtube.com/watch?v=dk0fwOQzZ2s&list=PLTY9BjMMGESFaq6TYB0E2RsmIxuQaZbFz&index=27)|
| 2.3 — Dépôts Flatpak | 🎬 et 🎬 et 📄 | [Tech Ressolve](https://www.youtube.com/watch?v=C8q9XqR7Jgg) et [_Techcurator](https://www.youtube.com/watch?v=6SZM5YDR07E) et[Red Hat Doc](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/8/html/using_the_desktop_environment_in_rhel_8/assembly_installing-applications-using-flatpak_using-the-desktop-environment-in-rhel-8#proc_enabling-the-red-hat-flatpak-remote_assembly_installing-applications-using-flatpak) |
| 2.4 — Apps Flatpak | 🎬 et 🎬 et 📄 | [TatOG Tech](https://www.youtube.com/watch?v=VQgfT2qQlwo) et [_Techcurator](https://www.youtube.com/watch?v=6SZM5YDR07E) et [Red Hat Doc](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/8/html/using_the_desktop_environment_in_rhel_8/assembly_installing-applications-using-flatpak_using-the-desktop-environment-in-rhel-8#proc_enabling-the-red-hat-flatpak-remote_assembly_installing-applications-using-flatpak)|

---

## 3. Scripts shell

| Section | Type | Lien |
|---------|------|------|
| 3.1 — Exécution conditionnelle | | []() |
| 3.2 — Boucles | | []() |
| 3.3 — Entrées de script | | []() |
| 3.4 — Codes de retour | | []() |

---

## 4. Systèmes en cours d'exécution

| Section | Type | Lien |
|---------|------|------|
| 4.1 — Démarrer/éteindre | | []() |
| 4.2 — Cibles système | | []() |
| 4.3 — Accès root GRUB | | []() |
| 4.4 — Processus gourmands | | []() |
| 4.5 — Priorité processus | | []() |
| 4.6 — Profils tuning | | []() |
| 4.7 — Journaux système | | []() |
| 4.8 — Persistance journaux | | []() |
| 4.9 — Services réseau | | []() |
| 4.10 — Transfert fichiers | | []() |

---

## 5. Stockage local

| Section | Type | Lien |
|---------|------|------|
| 5.1 — Partitions GPT | | []() |
| 5.2 — Volumes physiques LVM | | []() |
| 5.3 — Groupes de volumes | | []() |
| 5.4 — Volumes logiques | | []() |
| 5.5 — Montage fstab | | []() |
| 5.6 — Partitions & swap | | []() |

---

## 6. Systèmes de fichiers

| Section | Type | Lien |
|---------|------|------|
| 6.1 — Créer/monter fs | | []() |
| 6.2 — NFS | | []() |
| 6.3 — autofs | | []() |
| 6.4 — Étendre LV | | []() |
| 6.5 — Permissions & contextes | | []() |

---

## 7. Déploiement et gestion

| Section | Type | Lien |
|---------|------|------|
| 7.1 — Planification tâches | | []() |
| 7.2 — Services au démarrage | | []() |
| 7.3 — Cible par défaut | | []() |
| 7.4 — Services de temps | | []() |
| 7.5 — Gestion paquetages | | []() |
| 7.6 — Chargeur de démarrage | | []() |

---

## 8. Réseau

| Section | Type | Lien |
|---------|------|------|
| 8.1 — IPv4/IPv6 | | []() |
| 8.2 — Nom d'hôte & DNS | | []() |
| 8.3 — Services réseau auto | | []() |
| 8.4 — Pare-feu | | []() |

---

## 9. Utilisateurs et groupes

⚠️ Pour accéder à ces vidéo il faut un compte (gratuit)

| Section | Type | Lien |
|---------|------|------|
| 9.1 — Comptes utilisateur | 🎬 | [Sander van Vugt](https://learning.oreilly.com/videos/rhcsa-rhel-9/9780135397237/9780135397237-RHL9_03_09_02/) |
| 9.2 — Mots de passe | 🎬 | [Sander van Vugt](https://learning.oreilly.com/videos/rhcsa-rhel-9/9780135397237/9780135397237-RHL9_03_09_02/) |
| 9.3 — Groupes | 🎬 | [Sander van Vugt](https://learning.oreilly.com/videos/rhcsa-rhel-9/9780135397237/9780135397237-RHL9_03_09_02/) |
| 9.4 — Accès sudo | 🎬 | [Sander van Vugt](https://learning.oreilly.com/videos/rhcsa-rhel-9/9780135397237/9780135397237-RHL9_03_09_02/) |

---

## 10. Sécurité

| Section | Type | Lien |
|---------|------|------|
| 10.1 — Pare-feu firewalld | | []() |
| 10.2 — Permissions fichiers | | []() |
| 10.3 — Auth SSH par clé | | []() |
| 10.4 — Modes SELinux | | []() |
| 10.5 — Contextes SELinux | | []() |
| 10.6 — Restaurer contextes | | []() |
| 10.7 — Ports SELinux | | []() |
| 10.8 — Booléens SELinux | | []() |

---

## 🎯 Bonus — Labs pratiques gratuits

| Ressource | Description | Lien |
|-----------|-------------|------|
| 🔴 Red Hat Developer | Compte gratuit = RHEL légal pour ton lab | https://developers.redhat.com/register |
| 🎓 Red Hat Learning Community | Forums + notes officielles | https://learn.redhat.com |
| 💻 GitHub — jrandj RHCSA | Commandes résumées par objectif EX200 | https://github.com/jrandj/redhat |


---

## :four: **Examens Blancs**

[Udemy Ghada Atef](https://www.udemy.com/user/ghada-atef-7/?utm_campaign=Search_DSA_GammaCatchall_NonP_la.EN_cc.ROW-English&utm_source=google&utm_medium=paid-search&portfolio=ROW-English&utm_audience=mx&utm_tactic=nb&utm_term=&utm_content=g&funnel=&test=&gad_source=1&gad_campaignid=21341313808&gbraid=0AAAAADROdO0G-2ydg5Ka66ZK9GSssZezI&gclid=Cj0KCQjwgr_NBhDFARIsAHiUWr76bgiye9URGbJhOCcnzSXzL4FUKauSFs0Buwx_pS5N0qWRPkTXviYaAtflEALw_wcB)

https://killer.sh/
