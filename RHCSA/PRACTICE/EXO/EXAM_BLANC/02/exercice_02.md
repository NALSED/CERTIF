# 🔴 Examen Blanc RHCSA — N°02
**Durée : 2h30 | RHEL 10 | SELinux enforcing | Sans doc externe**

> ⚠️ Toute configuration doit survivre à un `reboot`.
> ⚠️ SELinux doit rester en mode `enforcing`.

---

## Tâche 01 — Utilisateurs, groupes et politiques de mots de passe

Créez le groupe `devteam` avec GID `5000`.
Créez :
- `dev1` : UID `3001`, bash, groupe principal `devteam`, mot de passe `Dev@2026`
- `dev2` : UID `3002`, bash, groupe principal `devteam`, mot de passe `Dev@2026`
- `svc_app` : UID `3003`, shell `/sbin/nologin`, pas de home directory, compte système

Politiques :
- `dev1` : mot de passe change obligatoirement tous les **60 jours**, minimum **5 jours** entre deux changements, avertissement **10 jours** avant
- `dev2` : compte expirant le **2026-12-31**

---

## Tâche 02 — Accès SSH par clé

Générez une paire de clés `ed25519` pour `dev1` (sans passphrase, commentaire `dev1@lab`).
Copiez la clé publique dans `~dev1/.ssh/authorized_keys` avec les bonnes permissions.
Vérifiez que la connexion `ssh dev1@localhost` fonctionne sans mot de passe.

---

## Tâche 03 — Permissions et ACL

Créez `/projects/devteam/` :
- Propriétaire `root`, groupe `devteam`
- Permissions : `rwxrws---` avec sgid
- `dev1` peut lire, écrire et exécuter
- `dev2` peut lire et exécuter mais pas écrire
- `svc_app` n'a aucun accès

Utilisez les ACL (`setfacl`) pour le contrôle fin. Vérifiez avec `getfacl`.

---

## Tâche 04 — Commande find avancée

1. Trouvez tous les fichiers appartenant au groupe `devteam` sous `/` → `/tmp/devteam_files.txt` (stderr supprimé)
2. Trouvez tous les liens symboliques dans `/etc/` et affichez leur cible avec `-printf "%p -> %l\n"`
3. Trouvez les fichiers de `/var/log/` **non modifiés depuis plus de 30 jours** et plus grands que **1M**
4. Trouvez tous les fichiers avec permissions exactes `644` dans `/home/`
5. Exécutez `chmod 600` sur tous les fichiers trouvés en tâche 4 avec `-exec`

---

## Tâche 05 — Redirections et traitement texte

1. Listez le contenu de `/etc/passwd` trié par UID (champ 3) en ordre décroissant → `/tmp/passwd_sorted.txt`
2. Extrayez uniquement les noms d'utilisateurs dont le shell est `/bin/bash` depuis `/etc/passwd` avec `awk`
3. Remplacez toutes les occurrences de `bash` par `sh` dans une copie `/tmp/passwd_copy.txt` avec `sed` (sans modifier l'original)
4. Comptez le nombre de lignes, mots et caractères de `/etc/passwd` en une seule commande, redirigez vers `/tmp/passwd_stats.txt`

---

## Tâche 06 — Stockage : partitions et swap

Sur `/dev/sdb` :
1. Créez une table GPT
2. Partition 1 : **3 Gio** (type `xfs`)
3. Partition 2 : **1 Gio** (type `swap`)
4. Formatez chaque partition selon son type
5. Montez la partition 1 sur `/mnt/part1` via UUID dans `/etc/fstab`
6. Activez le swap via UUID dans `/etc/fstab`

---

## Tâche 07 — LVM + snapshot logique

Sur `/dev/sdc` :
1. Créez un PV, un VG `vg_dev`, un LV `lv_code` de **3 Gio** en ext4 monté sur `/mnt/code`
2. Créez un fichier test `/mnt/code/testfile.txt` avec le contenu `VERSION 1`
3. Créez un snapshot `lv_code_snap` de **500 MiB**
4. Modifiez `/mnt/code/testfile.txt` avec `VERSION 2`
5. Démontez `lv_code`, faites un `lvconvert --merge` pour restaurer le snapshot, remontez et vérifiez que le fichier contient `VERSION 1`

---

## Tâche 08 — SELinux : diagnostic complet

Créez le répertoire `/opt/webapp/` et placez-y `index.html` avec le contenu `APP OK`.
Sans modifier la config Apache, changez uniquement `DocumentRoot` vers `/opt/webapp/`.
Démarrez Apache. Il échouera à cause de SELinux.
Diagnostiquez avec `ausearch` et/ou `sealert`, corrigez le contexte, vérifiez avec `curl http://localhost`.

---

## Tâche 09 — SELinux : booléen + port

1. Activez de façon persistante le booléen permettant à `httpd` de lire les fichiers dans les home directory des utilisateurs
2. Configurez `httpd` pour écouter sur le port **8080**
3. Ajoutez ce port dans SELinux (`http_port_t`) et dans firewalld
4. Vérifiez avec `curl http://localhost:8080`

---

## Tâche 10 — Systemd : override d'un service existant

Sans modifier le fichier unit d'origine de `sshd.service` :
1. Créez un override qui force un redémarrage automatique en cas d'échec avec un délai de **15 secondes**
2. Limitez le nombre de redémarrages à **3** en **60 secondes** (`StartLimitIntervalSec`, `StartLimitBurst`)
3. Vérifiez avec `systemctl cat sshd.service`

---

## Tâche 11 — Journald : persistance et filtrage

1. Configurez `journald` pour que les logs soient **persistants** après reboot
2. Affichez uniquement les logs du **boot actuel** depuis le service `sshd`
3. Affichez les logs de **priorité err et supérieure** des 2 dernières heures
4. Configurez `rsyslog` pour envoyer tous les messages de facilité `authpriv` niveau `warning` et supérieur vers `/var/log/auth_warn.log`

---

## Tâche 12 — Processus et priorité

1. Lancez `dd if=/dev/zero of=/dev/null` en arrière-plan avec une valeur `nice` de **10**
2. Trouvez son PID avec `ps` et affichez sa valeur nice
3. Modifiez sa priorité à **-5** avec `renice` (nécessite root)
4. Tuez le processus proprement avec `SIGTERM`, puis vérifiez qu'il est mort
5. Appliquez le profil tuned `throughput-performance` de façon persistante

---

## Tâche 13 — Planification : systemd timer + anacron

1. Créez un timer `backup_home.timer` qui déclenche `backup_home.service` tous les jours à **02h00**
2. Le service archive `/home/` vers `/backup/home_$(date +%Y%m%d).tar.gz`
3. Activez `Persistent=true` pour rattraper les exécutions manquées
4. Ajoutez une entrée `anacron` pour exécuter `/usr/local/bin/weekly_report.sh` chaque **semaine** (créez le script avec `echo "weekly report"` dedans)

---

## Tâche 14 — Script shell avancé

Écrivez `/usr/local/bin/disk_alert.sh` :
- Parcourt tous les points de montage avec `df`
- Si un système de fichiers dépasse **80% d'utilisation** → écrit dans `/var/log/disk_alert.log` : `ALERTE: /point/montage est à XX%`
- Si aucun dépassement → écrit `OK - $(date)` dans le log
- Quitte avec code `0` si OK, code `1` si au moins une alerte

Planifiez ce script via cron toutes les heures pour `root`.

---

## Tâche 15 — Réseau : double interface et routage

Configurez une deuxième connexion réseau avec `nmcli` :
- Interface `enp0s8` (ou 2ème interface disponible)
- IP statique : `10.0.0.10/24`
- Pas de gateway sur cette interface
- DNS : `10.0.0.1`
- Ajoutez une entrée statique dans `/etc/hosts` : `10.0.0.1 internal.lab.local`

Vérifiez avec `ip a` et `ping internal.lab.local`.

---

## Tâche 16 — NFS client

Sur le serveur (localhost en loopback) :
1. Exportez `/srv/exports/data` et `/srv/exports/homes`
2. Sur le client (même machine), montez `/srv/exports/data` sur `/mnt/nfs_data` de façon **persistante** dans `/etc/fstab` avec options `nfs4,_netdev`
3. Configurez autofs pour monter `/srv/exports/homes` automatiquement sous `/mnt/homes/` avec le wildcard `*`

---

## Tâche 17 — RPM et DNF

1. Identifiez quel paquet a installé le fichier `/usr/bin/find`
2. Listez tous les fichiers de configuration installés par ce paquet
3. Vérifiez l'intégrité de ce paquet avec `rpm -V`
4. Recherchez avec `dnf` quel paquet fournit la commande `seinfo`
5. Installez ce paquet et listez les modules SELinux chargés avec `seinfo -t | head -20`

---

## Tâche 18 — Flatpak avancé

1. Ajoutez le remote Flathub en mode **user** pour `dev1` avec le nom `flathub-user`
2. Listez tous les remotes disponibles (system + user)
3. Recherchez `org.inkscape.Inkscape` et affichez ses informations sans l'installer
4. Supprimez le remote `flathub-user` ajouté pour `dev1`
5. Documentez la différence entre un remote `--system` et `--user` dans `/tmp/flatpak_diff.txt`

---

## Tâche 19 — Liens physiques et symboliques

1. Créez `/data/original.txt` contenant `CONTENU ORIGINAL`
2. Créez un lien physique `/data/hardlink.txt` vers ce fichier
3. Créez un lien symbolique `/data/symlink.txt` vers `/data/original.txt`
4. Supprimez `/data/original.txt` et observez le comportement de chaque lien
5. Trouvez avec `find` tous les fichiers ayant le même inode que `/data/hardlink.txt`
6. Écrivez vos observations dans `/tmp/liens_obs.txt`

---

## Tâche 20 — Troubleshooting système

1. Configurez le système pour démarrer par défaut en cible `multi-user.target`
2. Utilisez `grubby` pour retirer l'argument `quiet` du kernel par défaut
3. Ajoutez l'argument `systemd.log_level=debug` temporairement (une seule valeur du noyau, pas persistant)
4. Affichez les 20 dernières lignes du journal de boot avec `journalctl -b`
5. Identifiez et désactivez (mask) un service inutile de votre choix en justifiant dans `/tmp/mask_justif.txt`

---

*Examen blanc RHCSA EX200 — RHEL 10 — 2026*
