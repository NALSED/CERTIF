# Exercices Bash — Préparation RHCSA

---

## Exercice 1 — Vérifier un argument

Écris un script qui vérifie si l'utilisateur a passé un argument.

- Si oui : afficher `"Bonjour [argument]"`
- Si non : afficher `"Usage : ./script.sh <nom>"`

---

## Exercice 2 — Pair ou Impair

Écris un script qui prend un nombre en argument et affiche si ce nombre est **pair** ou **impair**.

---

## Exercice 3 — Compter jusqu'à N

Écris un script qui prend un nombre `N` en argument et affiche tous les nombres de `1` jusqu'à `N` avec une boucle `while`.

---

## Exercice 4 — Afficher les fichiers d'un répertoire

Écris un script qui parcourt tous les fichiers du répertoire courant avec une boucle `for` et affiche leur nom.

---

## Exercice 5 — Créer des utilisateurs depuis un fichier

Tu as un fichier `users.txt` contenant une liste de noms (un par ligne). Écris un script qui lit ce fichier ligne par ligne et affiche `"Création de l'utilisateur : [nom]"` pour chaque ligne.

Exemple de `users.txt` :
```
alice
bob
charlie
```

---

## Exercice 6 — Vérifier si un service est actif

Écris un script qui prend le nom d'un service en argument et vérifie s'il est actif avec `systemctl is-active`.

- Si actif : afficher `"[service] est actif"`
- Si inactif : afficher `"[service] est inactif"` et quitter avec `exit 1`

---

## Exercice 7 — Sauvegarde de fichiers

Écris un script qui :

1. Prend un répertoire en argument
2. Vérifie que le répertoire existe
3. Copie tous les fichiers `.txt` du répertoire vers `/tmp/backup/`
4. Affiche le nom de chaque fichier copié

---

## Exercice 8 — Menu interactif

Écris un script qui affiche un menu avec 3 choix via une boucle `while` :

```
1) Afficher la date
2) Afficher l'utilisateur courant
3) Quitter
```

Le menu doit se répéter jusqu'à ce que l'utilisateur choisisse `3`.

---

## Exercice 9 — Vérification d'espace disque

Écris un script qui vérifie l'espace disque utilisé sur `/` (avec `df`).

- Si l'utilisation dépasse **80%** : afficher `"ALERTE : espace disque critique"` et quitter avec `exit 1`
- Sinon : afficher `"Espace disque OK : [valeur]%"`

> Astuce : utilise `df` et `awk` pour extraire le pourcentage.

---

## Exercice 10 — Rapport système

Écris un script complet qui génère un rapport système dans un fichier `rapport.txt` contenant :

1. La date et l'heure
2. Le nom de la machine (`hostname`)
3. L'utilisateur courant
4. La liste des utilisateurs connectés (`who`)
5. L'espace disque sur `/`
6. Les 5 processus qui consomment le plus de CPU (`ps`)

Le script doit afficher `"Rapport généré : rapport.txt"` à la fin.
