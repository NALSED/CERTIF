# 🔴 Examen Blanc RHCSA — N°04
**Durée : 2h30 | RHEL 10 | SELinux enforcing | Sans doc externe**

> ⚠️ Toute configuration doit survivre à un `reboot`.
> ⚠️ SELinux doit rester en mode `enforcing`.

---

## Tâche 01 — Utilisateurs : configuration avancée

Créez le groupe `auditors` (GID `7000`).
Créez :
- `audit1` : UID `5001`, bash, groupe principal `auditors`, répertoire home `/audit/audit1`, mot de passe `Aud!t2026`
- `audit2` : même configuration, home `/audit/audit2`
- `readonly` : shell `/sbin/nologin`, home `/dev/null`, pas de groupe supplémentaire

Configurez `/etc/skel` pour que tout nouvel utilisateur ait automatiquement :
- Un fichier `~/.bashrc` avec `alias ll='ls -alh'`
- Un répertoire `~/scripts/`

Vérifiez que ces éléments sont bien présents pour `audit1`.

---

## Tâche 02 — Sudo : restrictions et audit

1. Configurez `audit1` pour exécuter **uniquement** les commandes dans `/usr/sbin/` sans mot de passe
2. Configurez `audit2` pour exécuter `journalctl` et `ausearch` sans mot de passe
3. Interdisez à `audit2` d'utiliser `su` et `sudo` même s'il est dans un groupe autorisant sudo
4. Vérifiez avec `sudo -l -U audit1` et `sudo -l -U audit2`

---

## Tâche 03 — find : cas pièges

1. Trouvez tous les fichiers de `/etc/` dont la **permission d'exécution est activée pour others** (`-perm -o+x`)
2. Trouvez les fichiers de `/home/` dont la **date d'accès** est plus ancienne que **30 jours** (`-atime +30`)
3. Trouvez tous les fichiers `.log` de `/var/log/` de plus de **5M**, listez-les avec leur taille humaine (`-ls`)
4. Trouvez les fichiers dans `/tmp/` dont le nom contient un espace (hint : `-name "* *"`)
5. Trouvez tous les fichiers du système appartenant à `audit1` **ou** `audit2` en une seule commande `find`

---

## Tâche 04 — Traitement de texte combiné

1. Générez la liste des 10 processus consommant le plus de CPU avec `ps`, extrayez les colonnes PID et %CPU avec `awk`, redirigez vers `/tmp/top_cpu.txt`
2. Dans `/etc/passwd`, avec `sed`, supprimez toutes les lignes commençant par `#` et les lignes vides → `/tmp/passwd_clean.txt`
3. Comptez le nombre d'utilisateurs ayant un shell valide (différent de `/sbin/nologin` et `/bin/false`) avec un pipeline `grep | wc`
4. Utilisez `tr` pour transformer `/etc/hostname` en majuscules et afficher le résultat

---

## Tâche 05 — Stockage : LVM avancé + thin provisioning concept

Sur `/dev/sdb` :
1. Créez PV, VG `vg_thin`, puis un LV `lv_main` de **6 Gio** en xfs sur `/mnt/main`
2. Ajoutez un 2ème PV (`/dev/sdc`) au VG
3. Déplacez les Physical Extents de `/dev/sdb` vers `/dev/sdc` avec `pvmove` (sans démonter)
4. Retirez `/dev/sdb` du VG avec `vgreduce`
5. Vérifiez que `/mnt/main` est toujours accessible et que les données sont intactes

---

## Tâche 06 — Systèmes de fichiers : labels et UUID

1. Créez une partition ext4 sur `/dev/sdd`, attribuez-lui le label `DATAPART`
2. Montez-la via son **label** dans `/etc/fstab` (syntaxe `LABEL=`)
3. Créez une partition xfs sur un 2ème espace, attribuez-lui le label `XFSPART`
4. Vérifiez les labels avec `blkid` et `lsblk -f`
5. Montez les deux via `/etc/fstab` et vérifiez la persistance

---

## Tâche 07 — SELinux : port + booléen + contexte en même temps

Scenario complet :
1. Installez et configurez `vsftpd` pour servir les fichiers depuis `/srv/ftp/data/`
2. Le service doit écouter sur le port **2121** (non standard)
3. Appliquez le bon contexte SELinux sur `/srv/ftp/data/`
4. Activez le booléen SELinux permettant l'accès FTP aux home directories
5. Ouvrez le port dans firewalld et testez avec `curl ftp://localhost:2121`

---

## Tâche 08 — Systemd : unit paths et conditions

1. Créez un service `watchdog.service` qui vérifie toutes les 30s si `/var/run/app.pid` existe
2. Si le fichier n'existe pas, le service écrit une alerte dans `/var/log/watchdog.log`
3. Ajoutez une condition `ConditionPathExists=/etc/watchdog.conf` — le service ne démarre que si ce fichier existe
4. Créez `/etc/watchdog.conf` avec le contenu `enabled=yes`
5. Activez le service et vérifiez son comportement avec `systemctl status`

---

## Tâche 09 — Logs : rsyslog + logrotate

1. Configurez rsyslog pour envoyer **tous** les messages de niveau `crit` et supérieur vers `/var/log/critical.log`
2. Configurez logrotate pour ce fichier : rotation **quotidienne**, conservation **7 jours**, compression, pas d'erreur si le fichier est absent
3. Testez la rotation manuellement avec `logrotate -f`
4. Générez un message de test avec `logger -p kern.crit "TEST CRITIQUE"` et vérifiez qu'il apparaît dans `/var/log/critical.log`

---

## Tâche 10 — Script : génération de rapport système

Écrivez `/usr/local/bin/sysreport.sh` qui génère un rapport dans `/tmp/sysreport_$(date +%Y%m%d).txt` contenant :
- Hostname et date
- Utilisation disque (tous les FS)
- Les 5 processus consommant le plus de mémoire
- Nombre d'utilisateurs connectés
- Statut des services : `sshd`, `firewalld`, `chronyd`
- Code retour `0` si tous les services sont actifs, `1` sinon

---

## Tâche 11 — Processus : cgroups et loginctl

1. Listez les sessions actives avec `loginctl`
2. Identifiez le processus consommant le plus de mémoire avec `ps -eo pid,pmem,comm --sort=-pmem | head -5`
3. Changez la priorité d'un processus `sshd` à `nice -5` avec `renice`
4. Terminez la session de `audit2` avec `loginctl terminate-user audit2`
5. Vérifiez avec `loginctl list-users`

---

## Tâche 12 — Chrony et temps

1. Vérifiez le statut de synchronisation NTP avec `chronyc tracking`
2. Ajoutez le serveur NTP `0.fr.pool.ntp.org` dans `/etc/chrony.conf`
3. Forcez une synchronisation immédiate avec `chronyc makestep`
4. Configurez le fuseau horaire `Europe/Paris` avec `timedatectl`
5. Vérifiez avec `timedatectl status` et `chronyc sources`

---

## Tâche 13 — Flatpak : override et configuration

1. Installez flatpak si absent
2. Ajoutez le remote Flathub system
3. Listez les applications disponibles dans Flathub pour le mot-clé `text editor`
4. Pour une application Flatpak installée (ou simulez avec une existante), affichez ses permissions avec `flatpak info --show-permissions`
5. Documentez dans `/tmp/flatpak_perms.txt` : comment restreindre les permissions réseau d'une app Flatpak (`--no-share=network`)

---

## Tâche 14 — Réseau : firewalld zones et interfaces

1. Assignez l'interface réseau principale à la zone `trusted`
2. Assignez une 2ème interface (ou créez une connexion fictive) à la zone `public`
3. Dans la zone `public` : autorisez uniquement SSH et HTTPS
4. Dans la zone `trusted` : autorisez tout le trafic
5. Rendez persistant et vérifiez avec `firewall-cmd --get-active-zones`

---

## Tâche 15 — RPM : interrogation avancée

1. Listez tous les paquets installés dont le nom commence par `python` avec `rpm -qa`
2. Pour chaque paquet python trouvé, affichez son nom et sa version avec `rpm --qf`
3. Trouvez quel paquet fournit `/usr/bin/python3` avec `rpm -qf`
4. Vérifiez si un paquet contient des scripts post-installation avec `rpm -q --scripts`
5. Exportez un inventaire complet des paquets installés (nom + version + architecture) vers `/tmp/pkg_inventory.txt`

---

## Tâche 16 — Liens et permissions SUID

1. Trouvez tous les binaires avec SUID dans `/usr/bin/` et `/usr/sbin/`
2. Expliquez dans `/tmp/suid_risk.txt` le risque de sécurité associé au SUID sur un binaire personnalisé
3. Créez un lien symbolique `/usr/local/bin/ll` pointant vers `/usr/bin/ls`
4. Créez un lien physique depuis `/etc/hosts` vers `/tmp/hosts_backup`
5. Vérifiez avec `ls -li` que l'inode est identique

---

## Tâche 17 — Planification : at + cron + timer combinés

1. Planifiez avec `at` : dans **10 minutes**, exécutez `rpm -Va > /tmp/rpm_verify.txt`
2. Créez un cron système dans `/etc/cron.d/` (pas dans crontab) pour exécuter `sync` toutes les **5 minutes** en tant que `root`
3. Créez un timer `rpm_check.timer` qui vérifie l'intégrité RPM **chaque dimanche à 01h00** et écrit le résultat dans `/var/log/rpm_check.log`
4. Vérifiez tous les jobs planifiés avec `atq`, `crontab -l` et `systemctl list-timers`

---

## Tâche 18 — NFS : options de montage

1. Exportez `/srv/nfs/soft` et `/srv/nfs/hard`
2. Montez `/srv/nfs/soft` avec l'option `soft,timeo=30` (montage souple : échec rapide)
3. Montez `/srv/nfs/hard` avec l'option `hard,intr` (montage dur : réessai ininterrompu)
4. Expliquez dans `/tmp/nfs_options.txt` la différence entre `soft` et `hard` et quand utiliser chaque option

---

## Tâche 19 — autofs : carte directe et délai

1. Configurez autofs pour monter `/srv/nfs/hard` sur `/mnt/direct_hard` via direct map
2. Définissez un timeout de démontage de **120 secondes** pour ce montage
3. Vérifiez que le montage apparaît à l'accès et disparaît après le timeout
4. Consultez les logs autofs avec `journalctl -u autofs`

---

## Tâche 20 — Scénario de panne complète

Sim ulation : le mot de passe root est perdu ET SELinux empêche le bon fonctionnement d'un service après un déplacement de fichiers.

1. Décrivez la procédure complète `rd.break` avec `enforcing=0` dans `/tmp/full_recovery.txt`
2. Après reset du mot de passe, expliquez pourquoi `touch /.autorelabel` est obligatoire
3. Utilisez `grubby` pour ajouter `enforcing=0` temporairement, redémarrez, puis remettez `enforcing=1`
4. Vérifiez le mode SELinux après reboot avec `getenforce` et `sestatus`

---

*Examen blanc RHCSA EX200 — RHEL 10 — 2026*
