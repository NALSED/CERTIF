# 🔴 Examen Blanc RHCSA — N°03
**Durée : 2h30 | RHEL 10 | SELinux enforcing | Sans doc externe**

> ⚠️ Toute configuration doit survivre à un `reboot`.
> ⚠️ SELinux doit rester en mode `enforcing`.

---

## Tâche 01 — Utilisateurs système et environnement

Créez le groupe `webadmin` (GID `6000`) et le groupe `dba` (GID `6001`).
Créez :
- `tom` : UID `4001`, bash, groupes secondaires `webadmin` et `dba`, mot de passe `T0mPwd#`
- `sara` : UID `4002`, bash, groupe secondaire `webadmin`, mot de passe `T0mPwd#`
- `batch` : système, shell `/sbin/nologin`, home `/var/lib/batch`

Assurez-vous que tout nouveau fichier créé par `tom` appartient au groupe `dba` par défaut (via `newgrp` n'est pas une solution persistante — trouvez la bonne méthode).

---

## Tâche 02 — Configuration SSH sécurisée

Sur le serveur SSH :
1. Interdisez la connexion directe en `root` via SSH
2. Autorisez uniquement les utilisateurs `tom` et `sara` à se connecter
3. Changez le port SSH sur **2200** (pensez à SELinux et firewalld)
4. Désactivez l'authentification par mot de passe (clé uniquement)

Vérifiez que `sshd` redémarre sans erreur. Générez une clé pour `sara` et testez la connexion.

---

## Tâche 03 — find : recherche et traitement

1. Trouvez tous les fichiers du système appartenant à un utilisateur **inexistant** (sans propriétaire) → `/tmp/orphans.txt`
2. Trouvez tous les fichiers `.conf` dans `/etc/` modifiés dans les **48 dernières heures**
3. Trouvez les 5 **plus gros fichiers** de `/var/` (hint : combinez `find` et `sort`)
4. Trouvez tous les fichiers exécutables dans `/usr/local/bin/` et copiez-les dans `/tmp/local_bins/` avec `-exec`
5. Trouvez les fichiers avec le bit **SGID** actif sur tout le système → `/tmp/sgid_files.txt`

---

## Tâche 04 — Archivage différentiel et restauration

1. Créez une archive complète de `/etc/` dans `/backup/etc_full.tar.xz`
2. Ajoutez le répertoire `/etc/httpd/` à l'archive existante (option `--append`, mais attention : `.tar.xz` ne supporte pas l'ajout — expliquez pourquoi et faites une nouvelle archive)
3. Testez l'intégrité de l'archive
4. Extrayez uniquement `/etc/httpd/conf/httpd.conf` dans `/tmp/restore/`
5. Comparez le fichier restauré à l'original avec `diff`

---

## Tâche 05 — LVM : réduction et gestion

Sur `/dev/sdb` :
1. Créez un PV, un VG `vg_test`, deux LV : `lv_a` (2G, ext4) et `lv_b` (2G, ext4)
2. Montez `lv_a` sur `/mnt/lva` et `lv_b` sur `/mnt/lvb` (persistant via fstab)
3. Remplissez `lv_a` avec un fichier de 100M : `dd if=/dev/urandom of=/mnt/lva/bigfile bs=1M count=100`
4. **Tentez** de réduire `lv_a` à 1G (attention : XFS ne supporte pas la réduction — donc utilisez ext4 et suivez la procédure correcte : `e2fsck`, `resize2fs`, `lvreduce`)
5. Vérifiez que les données sont intactes après réduction

---

## Tâche 06 — Système de fichiers réseau NFS

1. Configurez la machine comme serveur ET client NFS (loopback)
2. Exportez `/srv/share/ro` en **lecture seule** et `/srv/share/rw` en **lecture-écriture**
3. Montez `/srv/share/ro` sur `/mnt/nfs_ro` avec l'option `ro` dans `/etc/fstab`
4. Montez `/srv/share/rw` sur `/mnt/nfs_rw` avec l'option `rw` dans `/etc/fstab`
5. Vérifiez qu'écrire dans `/mnt/nfs_ro` est impossible et dans `/mnt/nfs_rw` fonctionne

---

## Tâche 07 — SELinux : troubleshooting complet

Créez un service `nginx` qui sert depuis `/data/nginx/html/`.
Volontairement, ne corrigez **pas** le contexte SELinux au départ.
Démarrez nginx, constatez l'échec d'accès.
Suivez la procédure complète :
1. `setenforce 0` — vérifiez que nginx fonctionne en permissive
2. `setenforce 1` — reproduisez l'échec
3. `ausearch` puis `sealert` pour identifier le problème
4. Corrigez avec `semanage fcontext` + `restorecon`
5. Vérifiez que nginx fonctionne en enforcing

---

## Tâche 08 — Systemd : units complexes

1. Créez un service `monitor.service` de type `forking` qui lance `/usr/local/bin/monitor.sh` en arrière-plan (le script fait `while true; do date >> /var/log/monitor.log; sleep 5; done`)
2. Créez un service `cleanup.service` qui dépend de `monitor.service` (`After=` et `Requires=`)
3. Créez `cleanup.timer` qui déclenche `cleanup.service` chaque heure
4. Vérifiez les dépendances avec `systemctl list-dependencies cleanup.service`

---

## Tâche 09 — Systemd tmpfiles + journald

1. Créez via `tmpfiles.d` : répertoire `/run/webapp` (permissions `0755`, propriétaire `tom`), fichier `/run/webapp/status` (contenu vide, permissions `0644`), nettoyage automatique après **7 jours**
2. Configurez `journald` pour limiter la taille des logs à **200M** (`SystemMaxUse`)
3. Configurez la rétention à **4 semaines** (`MaxRetentionSec`)
4. Vérifiez la configuration avec `journalctl --disk-usage`

---

## Tâche 10 — Script shell : boucles et conditions

Écrivez `/usr/local/bin/batch_users.sh` :
- Lit un fichier passé en `$1` (format : `username:password:group` par ligne)
- Pour chaque ligne :
  - Crée le groupe s'il n'existe pas
  - Crée l'utilisateur avec le mot de passe donné
  - Si l'utilisateur existe déjà, affiche `SKIP: <user> existe déjà`
- Affiche un résumé final : `X utilisateurs créés, Y ignorés`
- Code retour `0` si tous créés, `1` si au moins un ignoré

Testez avec un fichier contenant 3 entrées dont un doublon.

---

## Tâche 11 — Grep et regex avancés

1. Dans `/etc/passwd`, trouvez toutes les lignes où l'UID est compris entre 1000 et 9999 (regex)
2. Dans `/var/log/secure`, trouvez toutes les tentatives de connexion échouées avec `grep -E`
3. Comptez le nombre de tentatives échouées par utilisateur (combinez `grep`, `awk`, `sort`, `uniq -c`)
4. Dans `/etc/services`, trouvez tous les services utilisant le protocole `tcp` sur les ports 1 à 1024
5. Créez un rapport dans `/tmp/security_report.txt` avec les résultats des points 2 et 3

---

## Tâche 12 — Processus : zombies et gestion

1. Identifiez tous les processus zombies actuels avec `ps`
2. Expliquez dans `/tmp/zombie_explain.txt` pourquoi un processus devient zombie et comment le tuer
3. Lancez 3 instances de `sleep 3600` en arrière-plan
4. Tuez-les tous en une seule commande avec `killall`
5. Vérifiez avec `ps` et `jobs` qu'aucun ne subsiste

---

## Tâche 13 — Tuning et performances

1. Identifiez le profil tuned actif
2. Créez un profil personnalisé `rhcsa-custom` dans `/etc/tuned/rhcsa-custom/` :
   - Hérite du profil `throughput-performance`
   - Définit `vm.swappiness = 10` via `[sysctl]`
3. Appliquez ce profil
4. Vérifiez avec `sysctl vm.swappiness`
5. Rendez persistant le paramètre `vm.swappiness = 10` via `/etc/sysctl.d/` indépendamment de tuned

---

## Tâche 14 — Firewalld : zones et règles avancées

1. Affichez la zone par défaut et toutes les zones disponibles
2. Créez une règle **rich rule** pour accepter le trafic SSH uniquement depuis `192.168.0.0/24`
3. Bloquez complètement l'adresse `10.0.0.99` avec une rich rule
4. Ouvrez le port `3306/tcp` (MySQL) dans la zone `internal`
5. Rendez toutes ces règles persistantes et vérifiez avec `firewall-cmd --list-all`

---

## Tâche 15 — Gestion des paquets RPM + DNF

1. Installez `httpd` si absent, puis listez tous les fichiers installés par ce paquet
2. Téléchargez le RPM de `httpd` **sans l'installer** dans `/tmp/rpms/`
3. Inspectez le RPM téléchargé : version, dépendances, scripts pre/post-install
4. Désinstallez `httpd` et réinstallez-le depuis le RPM local avec `rpm`
5. Vérifiez l'intégrité de l'installation avec `rpm -V httpd`

---

## Tâche 16 — Flatpak : gestion complète

1. Vérifiez la version de flatpak installée
2. Ajoutez le remote Flathub system
3. Listez les applications Flatpak installées (system + user)
4. Recherchez `org.libreoffice.LibreOffice` et affichez ses détails (taille, version, description)
5. Documentez la commande d'installation (sans installer) et la commande de suppression dans `/tmp/flatpak_commands.txt`

---

## Tâche 17 — Planification avancée

1. Créez un job `at` qui s'exécutera demain à **08h00** et enverra le résultat de `uptime` dans `/tmp/uptime_report.txt`
2. Configurez un cron pour `sara` : exécute `find /home/sara -name "*.tmp" -delete` tous les **lundis à 04h30**
3. Créez un timer systemd `log_rotate.timer` qui déclenche `log_rotate.service` le **1er de chaque mois à 03h00**
4. Le service doit exécuter `logrotate -f /etc/logrotate.conf`

---

## Tâche 18 — Réseau : DNS et résolution de noms

1. Configurez le hostname `rhcsa-srv3.prod.local`
2. Ajoutez dans `/etc/hosts` : `192.168.0.10 db.prod.local` et `192.168.0.11 app.prod.local`
3. Configurez `nmcli` pour utiliser les DNS `192.168.0.1` et `8.8.8.8` sur l'interface principale
4. Vérifiez la résolution avec `nslookup db.prod.local` et `dig app.prod.local`
5. Identifiez le fichier qui définit l'ordre de résolution (DNS vs /etc/hosts) et expliquez-le dans `/tmp/dns_order.txt`

---

## Tâche 19 — autofs : montage à la demande

1. Configurez autofs avec un **indirect map** pour monter les exports NFS de la tâche 06
2. Le montage doit être sous `/mnt/nfs/` avec accès par nom (`ro`, `rw`)
3. Configurez un **direct map** pour monter `/srv/share/rw` directement sur `/direct/data`
4. Vérifiez que les montages apparaissent dans `mount` après accès et disparaissent après le timeout

---

## Tâche 20 — Accès root GRUB et récupération

1. Configurez GRUB pour attendre **5 secondes** au menu de boot (`GRUB_TIMEOUT`)
2. Appliquez la modification avec `grub2-mkconfig`
3. Ajoutez l'argument `mem=2G` au kernel par défaut avec `grubby` (simulation restriction mémoire)
4. Vérifiez puis **supprimez** immédiatement cet argument pour ne pas affecter le système
5. Décrivez dans `/tmp/grub_recovery.txt` la différence entre `rd.break`, `init=/bin/bash` et `systemd.unit=rescue.target`

---

*Examen blanc RHCSA EX200 — RHEL 10 — 2026*
