# 🔴 Examen Blanc RHCSA — N°01
**Durée : 2h30 | RHEL 10 | SELinux enforcing | Sans doc externe**

> ⚠️ Toute configuration doit survivre à un `reboot`.
> ⚠️ SELinux doit rester en mode `enforcing` tout au long de l'examen.

---

## Tâche 01 — Utilisateurs et groupes

Créez le groupe `ops` avec le GID `3100`.
Créez les utilisateurs suivants :
- `anna` : UID `1900`, shell `/bin/bash`, groupe secondaire `ops`, mot de passe `R3dHat!`
- `leo` : UID `1901`, shell `/bin/bash`, groupe secondaire `ops`, mot de passe `R3dHat!`
- `ghost` : shell `/sbin/nologin`, compte verrouillé

Le mot de passe d'`anna` doit expirer dans **45 jours**, avertissement **5 jours** avant. Le compte doit être désactivé **7 jours** après expiration.

---

## Tâche 02 — Sudo granulaire

Configurez `leo` pour qu'il puisse exécuter `useradd`, `usermod`, `userdel` et `passwd` en tant que root **sans mot de passe**, mais qu'il ne puisse **jamais** changer le mot de passe de `root`.
Utilisez un fichier dédié dans `/etc/sudoers.d/`. Validez la syntaxe avant de sauvegarder.

---

## Tâche 03 — Permissions avancées

Créez `/data/ops/` :
- Propriétaire : `root`, groupe : `ops`
- Permissions : `rwx` pour owner et groupe, aucun droit pour others
- **sgid** actif : tout fichier créé dans ce dossier hérite du groupe `ops`
- **sticky bit** actif : seul le propriétaire d'un fichier peut le supprimer

Modifiez le `umask` par défaut de `anna` à `0027` de façon persistante.

---

## Tâche 04 — Commande find

1. Trouvez tous les fichiers appartenant à `anna` sur tout le système → `/tmp/find_anna.txt` (erreurs supprimées)
2. Trouvez tous les fichiers avec le bit **SUID** dans `/usr/bin/` → `/tmp/find_suid.txt`
3. Trouvez tous les fichiers de `/etc/` modifiés dans les **72 dernières heures**, affichez uniquement le nom sans chemin
4. Trouvez tous les fichiers de taille supérieure à **10M** dans `/var/log/` et affichez leur taille + chemin
5. Trouvez tous les répertoires vides sous `/tmp/` et supprimez-les en une seule commande

---

## Tâche 05 — Archivage

Créez `/backup/` s'il n'existe pas.
Archivez `/etc/ssh/` et `/etc/chrony.conf` dans `/backup/conf_backup.tar.gz` en préservant les permissions et contextes SELinux.
Vérifiez le contenu sans extraire. Extrayez uniquement le fichier `sshd_config` dans `/tmp/restore/`.

---

## Tâche 06 — LVM complet

Sur `/dev/sdb` :
1. Créez une table GPT et une partition de **8 Gio**
2. Créez un PV, un VG `vg_prod`, un LV `lv_data` de **4 Gio**
3. Formatez en `xfs`, montez sur `/mnt/data` via UUID dans `/etc/fstab`
4. Vérifiez que le montage survit au reboot

---

## Tâche 07 — Extension LVM à chaud

Sans démonter `/mnt/data` :
1. Ajoutez `/dev/sdc` comme nouveau PV et étendez `vg_prod`
2. Étendez `lv_data` de **+2 Gio**
3. Redimensionnez le système de fichiers immédiatement
4. Vérifiez avec `df -hT`

---

## Tâche 08 — Swap

Créez une partition swap de **512 MiB** sur `/dev/sdb` (2ème partition).
Activez-la et rendez-la persistante dans `/etc/fstab`.
Vérifiez avec `swapon --show` et `free -h`.

---

## Tâche 09 — SELinux : contexte fichier

Installez `httpd`. Créez `/webroot/` avec un fichier `index.html` contenant `RHCSA OK`.
Modifiez `DocumentRoot` dans la config Apache pour pointer vers `/webroot/`.
Appliquez le bon contexte SELinux sur `/webroot/` de façon **persistante**.
Ouvrez le port `http` dans firewalld zone `public` (permanent).
Activez et démarrez `httpd`. Testez avec `curl http://localhost`.

---

## Tâche 10 — SELinux : port non standard

Configurez `sshd` pour écouter sur le port **2222** en plus du port 22.
Autorisez ce port dans SELinux **et** dans firewalld.
Vérifiez que `sshd` démarre sans erreur et que le port est bien ouvert avec `ss -tlnp`.

---

## Tâche 11 — SELinux : booléen

Le service `httpd` doit pouvoir envoyer des requêtes réseau vers un backend (proxy).
Identifiez le booléen SELinux correspondant, activez-le de façon **persistante**.
Documentez la commande utilisée dans `/tmp/selinux_bool.txt`.

---

## Tâche 12 — Systemd : service custom

Créez un service systemd `hello.service` qui :
- Exécute `/usr/local/bin/hello.sh` (script qui écrit la date dans `/var/log/hello.log`)
- Démarre après `network.target`
- Se relance automatiquement en cas d'échec (délai 10s)
- Est activé au démarrage

Créez le script, rendez-le exécutable, activez et démarrez le service.

---

## Tâche 13 — Systemd timer

Créez un timer systemd `clean_tmp.timer` qui déclenche `clean_tmp.service` toutes les **30 minutes**.
Le service exécute : suppression des fichiers de `/tmp/` plus vieux que 5 jours.
Activez le timer au démarrage. Vérifiez avec `systemctl list-timers`.

---

## Tâche 14 — Systemd tmpfiles

Créez une configuration `tmpfiles.d` qui au boot :
- Crée le répertoire `/run/myapp/` appartenant à `anna` avec les permissions `0750`
- Crée le fichier `/run/myapp/pid` appartenant à `anna`
- Nettoie les fichiers de `/run/myapp/` non utilisés depuis plus de **10 jours**

Appliquez immédiatement sans reboot.

---

## Tâche 15 — Planification cron + at

1. Planifiez via `cron` pour l'utilisateur `anna` : exécution de `df -h >> /home/anna/disk.log` tous les jours à **23h45**
2. Planifiez avec `at` une exécution **dans 2 heures** de la commande `sync && echo done >> /tmp/at_done.txt`
3. Listez les tâches `at` en attente

---

## Tâche 16 — Script shell

Écrivez `/usr/local/bin/user_report.sh` :
- Prend un groupe en `$1`
- Si pas d'argument → affiche l'usage et quitte code `2`
- Si groupe inexistant → affiche `ERREUR: groupe non trouvé` et quitte code `1`
- Si groupe existe → pour chaque membre affiche : `USERNAME | UID | HOME | SHELL`
- Quitte code `0`

Testez avec `ops` et avec un groupe inexistant.

---

## Tâche 17 — Réseau statique

Configurez une IP statique sur l'interface principale :
- IP : `192.168.0.100/24`
- Gateway : `192.168.0.1`
- DNS : `1.1.1.1,8.8.8.8`
- Hostname : `rhcsa-node1.lab.local`
- Connexion active au démarrage

Vérifiez avec `ip a`, `hostnamectl`, `ping 192.168.0.1`.

---

## Tâche 18 — NFS + autofs

Sur la machine (mode loopback pour l'exercice) :
1. Installez `nfs-utils` et `autofs`
2. Exportez `/srv/nfs/share` via NFS (lecture/écriture, pour tout le monde)
3. Activez `nfs-server` et ouvrez les services dans firewalld
4. Configurez `autofs` pour monter automatiquement ce partage dans `/mnt/auto/share` à l'accès

---

## Tâche 19 — Flatpak

1. Vérifiez si `flatpak` est installé, installez-le si nécessaire
2. Ajoutez le remote Flathub (`https://dl.flathub.org/repo/flathub.flatpakrepo`) en mode **system** avec le nom `flathub`
3. Listez les remotes disponibles
4. Recherchez l'application `org.gnome.Calculator` sans l'installer
5. Documentez les commandes dans `/tmp/flatpak_setup.txt`

---

## Tâche 20 — Troubleshooting GRUB / rd.break

Simulez une perte du mot de passe root :
1. Décrivez la procédure complète pour réinitialiser le mot de passe root via `rd.break` (écrire les étapes dans `/tmp/rdbreak_procedure.txt`)
2. Ajoutez l'argument noyau `quiet` de façon persistante avec `grubby`
3. Vérifiez que l'argument est bien pris en compte avec `grubby --info=DEFAULT`

---

*Examen blanc RHCSA EX200 — RHEL 10 — 2026*
