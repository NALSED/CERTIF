# Exercices `grep` — RHCSA

---

## Fichier de travail

```bash
cat > /tmp/serveurs.log << 'EOF'
2024-01-10 08:01:12 INFO  nginx démarré sur 192.168.0.1
2024-01-10 08:02:45 ERROR sshd échec authentification user root
2024-01-10 08:03:01 INFO  cron job exécuté avec succès
2024-01-10 08:04:33 WARNING disque /dev/sda1 à 85% de capacité
2024-01-10 08:05:17 ERROR mysql connexion refusée sur port 3306
2024-01-10 08:06:02 INFO  backup terminé 192.168.0.254
2024-01-10 08:07:44 ERROR nginx timeout sur 192.168.0.42
2024-01-10 08:08:59 INFO  sshd connexion acceptée user deploy
2024-01-10 08:09:11 WARNING mémoire disponible < 10%
2024-01-10 08:10:30 ERROR kernel OOM killer activé pid 4821
EOF
```

---

## Niveau 1 — Fichiers système (incontournables RHCSA)

1. Afficher toutes les lignes non commentées de `/etc/ssh/sshd_config`
2. Afficher les lignes non vides et non commentées de `/etc/fstab`
3. Chercher le shell assigné à l'utilisateur `root` dans `/etc/passwd`
4. Afficher tous les utilisateurs qui ont `/bin/bash` comme shell
5. Chercher les groupes dont `wheel` fait partie dans `/etc/group`
6. Afficher les lignes de `/etc/sudoers` autorisant des commandes sans mot de passe (`NOPASSWD`)

---

## Niveau 2 — Gestion des services & logs

7. Chercher les erreurs dans `/var/log/messages` (insensible à la casse)
8. Afficher les lignes contenant `Failed` dans `/var/log/secure`
9. Chercher les tentatives de connexion SSH échouées pour `root`
10. Afficher les 2 lignes suivant chaque `ERROR` dans `/tmp/serveurs.log`
11. Compter le nombre d'échecs d'authentification dans `/var/log/secure`
12. Chercher récursivement `Listen` dans `/etc/httpd/` pour trouver le port Apache

---

## Niveau 3 — Réseau & SELinux

13. Afficher les interfaces réseau actives depuis `/etc/sysconfig/network-scripts/`
14. Chercher `BOOTPROTO` dans tous les fichiers `ifcfg-*`
15. Chercher les règles `firewalld` actives contenant `ssh` dans les fichiers de zone
16. Afficher les lignes contenant `enforcing` dans `/etc/selinux/config`
17. Chercher récursivement `denied` dans `/var/log/audit/audit.log`

---

## Niveau 4 — Expressions régulières appliquées

18. Extraire toutes les adresses IP de `/tmp/serveurs.log`
19. Afficher les lignes de `/etc/passwd` dont l'UID est compris entre 1000 et 9999
20. Chercher les lignes de `/etc/fstab` montant une partition `xfs`
21. Afficher les lignes contenant `ERROR` ou `WARNING` dans `/tmp/serveurs.log`
22. Chercher les lignes de `/etc/hosts` qui ne sont ni vides ni commentées

---

## Niveau 5 — Redirections & pipelines (style examen)

23. Sauvegarder toutes les lignes `ERROR` de `/tmp/serveurs.log` dans `/tmp/erreurs.txt`
24. Chercher `root` dans `/etc/passwd` et rediriger stderr vers `/dev/null`
25. Afficher et sauvegarder simultanément les erreurs avec `tee`
26. Compter le nombre d'utilisateurs avec un shell valide dans `/etc/passwd`
27. Lister les paquets installés contenant `selinux` (pipeline avec `rpm` ou `dnf`)

---

## Rappel options clés RHCSA

| option | usage typique |
|--------|--------------|
| `-i`   | recherche insensible à la casse |
| `-v`   | exclure les commentaires / lignes vides |
| `-E`   | regex étendue (UID, IP, patterns complexes) |
| `-r`   | parcourir `/etc/` récursivement |
| `-l`   | trouver quel fichier de conf contient un paramètre |
| `-n`   | repérer le numéro de ligne avant d'éditer avec `vim` |
| `-c`   | compter des occurrences dans les logs |
| `-A`   | contexte après (analyser une entrée de log) |
