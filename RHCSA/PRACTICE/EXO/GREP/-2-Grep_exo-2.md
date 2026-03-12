# GREP — Exercices Round 1

## Création du fichier

```bash
cat << 'EOF' > grep_exo.txt
# ============================================================
# FICHIER D'ENTRAÎNEMENT GREP
# ============================================================

# --- Logs système ---
2024-01-15 08:23:11 [INFO]    Démarrage du serveur web sur le port 8080
2024-01-15 08:23:12 [INFO]    Connexion à la base de données réussie
2024-01-15 08:24:05 [WARNING] Tentative de connexion échouée pour l'utilisateur admin
2024-01-15 08:24:06 [WARNING] Tentative de connexion échouée pour l'utilisateur root
2024-01-15 08:25:33 [ERROR]   Impossible de lire le fichier /etc/config.conf
2024-01-15 08:26:01 [INFO]    Requête GET /index.html - 200 OK
2024-01-15 08:26:45 [INFO]    Requête POST /api/login - 401 Unauthorized
2024-01-15 08:27:10 [ERROR]   Timeout lors de la connexion à 192.168.1.254
2024-01-15 08:28:00 [FATAL]   Mémoire insuffisante - arrêt du processus 4821
2024-01-15 08:30:00 [INFO]    Redémarrage automatique enclenché

# --- Adresses IP et réseau ---
Serveur principal  : 192.168.0.1
Serveur secondaire : 192.168.0.2
DNS primaire       : 8.8.8.8
DNS secondaire     : 8.8.4.4
Passerelle         : 192.168.0.254
IP inconnue        : 10.0.0.1
Adresse invalide   : 999.999.999.999
Loopback           : 127.0.0.1

# --- Utilisateurs ---
alice:x:1001:1001:Alice Martin:/home/alice:/bin/bash
bob:x:1002:1002:Bob Dupont:/home/bob:/bin/bash
charlie:x:1003:1003:Charlie Dev:/home/charlie:/bin/zsh
dave:x:0:0:Dave Admin:/root:/bin/bash
eve:x:1004:1004:Eve Test:/home/eve:/bin/sh
frank:x:1005:1005:Frank:/home/frank:/bin/false

# --- Mots de passe (exemples fictifs) ---
mot de passe: P@ssw0rd123
mot de passe: azerty
mot de passe: 123456
mot de passe: Tr0ub4dor&3
clé API     : sk-abc123XYZ789

# --- Fichiers et chemins ---
/etc/passwd
/etc/shadow
/var/log/syslog
/var/log/auth.log
/home/alice/.bashrc
/home/bob/.zshrc
/tmp/tmpfile_4821.tmp
/usr/local/bin/monscript.sh

# --- Emails ---
alice.martin@example.com
bob.dupont@example.fr
charlie@dev.io
admin@192.168.0.1
invalid-email@
contact@sednal.lan

# --- URLs ---
http://example.com/index.html
https://secure.example.com/api/v2/users
ftp://files.example.com/backup.tar.gz
https://192.168.0.1:8443/admin
http://localhost:3000/debug

# --- Code et variables ---
int main() {
    int x = 42;
    int y = 0;
    float pi = 3.14159;
    char *nom = "Alice";
    if (x > 0) {
        printf("x est positif\n");
    } else {
        printf("x est nul ou négatif\n");
    }
    return 0;
}

# --- Texte libre ---
Le serveur répond correctement.
Le SERVEUR est en maintenance.
le serveur sera redémarré demain.
Erreur critique détectée sur le serveur.
Aucune erreur trouvée.
Ce fichier contient des ERREURS et des erreurs et des Erreurs.
La ligne suivante est intentionnellement vide.

La ligne précédente était vide.
Fin du fichier.
EOF
```

---

## Exercices

### Niveau 1 — Basique

1. Affiche toutes les lignes contenant le mot `erreur`, peu importe la casse.
2. Affiche uniquement les lignes contenant `[ERROR]` ou `[FATAL]`.
3. Compte le nombre de lignes contenant `INFO`.
4. Affiche les lignes qui **ne contiennent pas** de `#`.
5. Affiche le numéro de ligne de chaque occurrence de `alice`.
6. Affiche uniquement les lignes commençant par un chemin `/xxx` (section chemins).

### Niveau 2 — Regex et options

7. Extrais toutes les adresses IP du fichier (n'affiche que l'IP, pas toute la ligne).
8. Affiche les lignes commençant par une date au format `YYYY-MM-DD`.
9. Affiche les lignes se terminant par `bash`.
10. Trouve toutes les lignes contenant un mot de **4 lettres exactement**.
11. Affiche les URLs commençant par `https`.
12. Trouve les lignes contenant un nombre entre 400 et 499 (codes HTTP).

### Niveau 3 — Contexte et combinaisons

13. Affiche les 2 lignes **après** chaque `[ERROR]`.
14. Affiche les 1 ligne **avant** et **après** chaque `[FATAL]`.
15. Cherche `WARNING` de manière récursive dans `/var/log/`.
16. Affiche les lignes contenant `serveur` mais **pas** `redémarr`.
17. Extrais uniquement les adresses email du fichier.
18. Affiche les lignes contenant exactement le mot `erreur` (pas `erreurs`, pas `Erreur`).

### Niveau 4 — Fichiers système

19. Dans `/etc/passwd`, affiche les utilisateurs qui ont `/bin/bash` comme shell.
20. Dans `/etc/passwd`, affiche les utilisateurs dont l'UID est supérieur à 1000.
21. Dans `/etc/passwd`, trouve les comptes **sans** répertoire home dans `/home`.
22. Dans `/etc/passwd`, affiche uniquement les noms d'utilisateurs (premier champ).
23. Dans `/var/log/secure` ou `/var/log/auth.log`, trouve les tentatives de connexion SSH échouées.
24. Cherche récursivement dans `/etc/` les fichiers contenant `192.168`.
25. Dans `/etc/fstab`, affiche les lignes qui ne sont pas des commentaires et non vides.

### Niveau 5 — Pièges et cas tordus

26. Cherche le texte littéral `3.14159` sans que le `.` soit interprété comme regex.
27. Cherche les lignes contenant `(test)` avec les parenthèses littérales.
28. Utilise `-e` pour chercher `ERROR` **et** `WARNING` en une seule commande.
29. Affiche uniquement les lignes contenant **deux occurrences** ou plus du mot `le`.
30. Cherche `root` dans `/etc/passwd` et affiche uniquement le fichier et le numéro de ligne, sans le contenu.
