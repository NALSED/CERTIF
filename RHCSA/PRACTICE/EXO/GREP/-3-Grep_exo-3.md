# GREP — Exercices Round 2

## Création du fichier

```bash
cat << 'EOF' > grep_exo2.txt
# ============================================================
# FICHIER D'ENTRAÎNEMENT GREP — ROUND 2
# ============================================================

# --- Logs Apache ---
192.168.1.10 - alice [15/Jan/2024:09:01:12 +0000] "GET /index.html HTTP/1.1" 200 1024
192.168.1.11 - bob [15/Jan/2024:09:02:45 +0000] "POST /api/login HTTP/1.1" 401 256
10.0.0.5     - - [15/Jan/2024:09:03:11 +0000] "GET /admin HTTP/1.1" 403 512
192.168.1.10 - alice [15/Jan/2024:09:04:00 +0000] "GET /dashboard HTTP/1.1" 200 4096
10.0.0.99    - - [15/Jan/2024:09:05:33 +0000] "GET /etc/passwd HTTP/1.1" 404 128
192.168.1.12 - charlie [15/Jan/2024:09:06:21 +0000] "DELETE /api/users/42 HTTP/1.1" 200 64
192.168.1.11 - bob [15/Jan/2024:09:07:55 +0000] "POST /api/login HTTP/1.1" 401 256
10.0.0.99    - - [15/Jan/2024:09:08:00 +0000] "GET /wp-admin HTTP/1.1" 404 128
192.168.1.13 - dave [15/Jan/2024:09:09:14 +0000] "PUT /api/config HTTP/1.1" 500 64
192.168.1.10 - alice [15/Jan/2024:09:10:02 +0000] "GET /logout HTTP/1.1" 302 0

# --- Inventaire serveurs ---
hostname=web01        ip=192.168.10.1    os=rhel9     statut=actif
hostname=web02        ip=192.168.10.2    os=rhel9     statut=actif
hostname=db01         ip=192.168.10.10   os=rhel8     statut=actif
hostname=db02         ip=192.168.10.11   os=rhel8     statut=inactif
hostname=backup01     ip=192.168.10.20   os=rhel7     statut=actif
hostname=monitoring   ip=192.168.10.30   os=ubuntu22  statut=actif
hostname=oldserver    ip=192.168.10.99   os=rhel6     statut=inactif
hostname=vpn01        ip=10.8.0.1        os=rhel9     statut=actif

# --- Processus (ps aux style) ---
USER       PID  %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1   0.0  0.1  19356  1544 ?        Ss   09:00   0:01 /sbin/init
root       412   0.0  0.2  55680  4096 ?        Ss   09:00   0:00 /usr/sbin/sshd
alice     1001   2.3  1.5 256000 30720 pts/0    Ss   09:01   0:05 /bin/bash
bob       1002   0.0  0.8 128000 16384 pts/1    Ss   09:02   0:00 /bin/bash
root      1050  99.9  5.0 512000 102400 ?       R    09:03   1:30 /usr/bin/python3 runaway.py
charlie   1101   0.5  0.3  64000  6144 pts/2    Ss   09:06   0:01 /bin/zsh
mysql     2001   1.2  8.0 1024000 163840 ?      Sl   09:00   0:10 /usr/sbin/mysqld
nobody    3001   0.0  0.1  32000  2048 ?        S    09:00   0:00 /usr/sbin/httpd

# --- Fichier de configuration (style .conf) ---
[global]
debug=false
log_level=INFO
max_connections=100
timeout=30
secret_key=aB3$xZ9!qL2#mN7

[database]
host=192.168.10.10
port=3306
name=production
user=dbadmin
password=Sup3rS3cr3t!

[cache]
host=192.168.10.15
port=6379
ttl=3600

[mail]
smtp_host=mail.example.com
smtp_port=587
from=noreply@example.com
admin=admin@example.com

# --- Données mixtes ---
Telephone: +33 6 12 34 56 78
Telephone: +374 91 234 567
Telephone: 04 72 00 00 00
Code postal: 69001
Code postal: 13008
Code postal: 75019
IBAN: FR76 3000 6000 0112 3456 7890 189
IBAN: AM12 2220 0000 0600 0132 4523

IPv6: 2001:0db8:85a3:0000:0000:8a2e:0370:7334
IPv6: fe80::1ff:fe23:4567:890a

numero de version: v1.0.0
numero de version: v2.3.1
numero de version: v10.0.0-beta
numero de version: v1.0.0-rc1

Taille fichier: 1024 B
Taille fichier: 512 KB
Taille fichier: 3.5 GB
Taille fichier: 128 MB

# --- Erreurs applicatives ---
[2024-01-15 10:00:01] CRITICAL : segmentation fault dans module auth.c ligne 142
[2024-01-15 10:01:22] ERROR    : connexion refusée par 192.168.10.10:3306
[2024-01-15 10:02:05] WARNING  : utilisation CPU > 90% sur web01
[2024-01-15 10:03:44] ERROR    : fichier introuvable /var/data/export.csv
[2024-01-15 10:04:00] INFO     : backup terminé avec succès
[2024-01-15 10:05:11] WARNING  : certificat SSL expire dans 7 jours
[2024-01-15 10:06:33] ERROR    : timeout après 30s sur 10.0.0.99
[2024-01-15 10:07:00] INFO     : 1500 requêtes traitées en 60s
[2024-01-15 10:08:22] CRITICAL : disque plein sur /dev/sda1 (100%)
[2024-01-15 10:09:01] INFO     : redémarrage du service httpd
EOF
```

---

## Exercices

### Niveau 1 — Rappels

1. Affiche toutes les lignes contenant `ERROR` ou `CRITICAL`.
2. Affiche les lignes qui **ne sont pas** des commentaires (`#`) et **non vides**.
3. Compte le nombre de requêtes HTTP avec le code `200`.
4. Affiche le numéro de ligne de chaque occurrence de `alice`.
5. Affiche les lignes contenant `inactif`.

### Niveau 2 — Regex

6. Extrais uniquement les adresses IP des logs Apache (première colonne).
7. Affiche les lignes contenant un code HTTP 4xx (400 à 499).
8. Affiche les lignes contenant un code HTTP 5xx.
9. Affiche uniquement les serveurs tournant sous `rhel9`.
10. Extrais tous les numéros de version (format `vX.Y.Z`).
11. Affiche les lignes contenant un port réseau (`:` suivi de chiffres).
12. Extrais uniquement les adresses email.

### Niveau 3 — Contexte et combinaisons

13. Affiche les 2 lignes après chaque `CRITICAL`.
14. Affiche les lignes contenant `ERROR` mais **pas** `timeout`.
15. Affiche les processus dont le `%CPU` dépasse 1 (colonne %CPU).
16. Cherche récursivement dans `/etc/` les fichiers contenant `PermitRootLogin`.
17. Affiche les lignes contenant `password` ou `secret` (insensible à la casse).
18. Affiche uniquement les `hostname` des serveurs inactifs.

### Niveau 4 — Fichiers système

19. Dans `/etc/passwd`, affiche les comptes système (UID < 100).
20. Dans `/etc/passwd`, affiche les comptes sans shell valide (`/bin/false` ou `/sbin/nologin`).
21. Dans `/etc/fstab`, affiche uniquement les lignes de montage NFS.
22. Dans `/etc/hosts`, affiche les lignes qui ne sont pas des commentaires.
23. Dans `/proc/mounts`, affiche les systèmes de fichiers de type `ext4`.


