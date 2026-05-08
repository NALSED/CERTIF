# Réponses — Exercices Bash RHCSA

---

## Exercice 1 — Vérifier un argument

```bash
#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage : ./script.sh <nom>"
    exit 1
fi

echo "Bonjour $1"
```

---

## Exercice 2 — Pair ou Impair

```bash
#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage : ./script.sh <nombre>"
    exit 1
fi

if (( $1 % 2 == 0 )); then
    echo "$1 est pair"
else
    echo "$1 est impair"
fi
```

---

## Exercice 3 — Compter jusqu'à N

```bash
#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage : ./script.sh <nombre>"
    exit 1
fi

COMPTEUR=1

while [ $COMPTEUR -le $1 ]
do
    echo $COMPTEUR
    (( COMPTEUR++ ))
done
```

---

## Exercice 4 — Afficher les fichiers d'un répertoire

```bash
#!/bin/bash

for FICHIER in ./*
do
    echo $FICHIER
done
```

---

## Exercice 5 — Créer des utilisateurs depuis un fichier

```bash
#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage : ./script.sh <fichier>"
    exit 1
fi

if [ ! -f "$1" ]; then
    echo "Fichier introuvable : $1"
    exit 1
fi

while read NOM
do
    echo "Création de l'utilisateur : $NOM"
done < "$1"
```

---

## Exercice 6 — Vérifier si un service est actif

```bash
#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage : ./script.sh <service>"
    exit 1
fi

if systemctl is-active --quiet "$1"; then
    echo "$1 est actif"
else
    echo "$1 est inactif"
    exit 1
fi
```

---

## Exercice 7 — Sauvegarde de fichiers

```bash
#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage : ./script.sh <repertoire>"
    exit 1
fi

if [ ! -d "$1" ]; then
    echo "Répertoire introuvable : $1"
    exit 1
fi

mkdir -p /tmp/backup

for FICHIER in "$1"/*.txt
do
    cp "$FICHIER" /tmp/backup/
    echo "Copié : $FICHIER"
done
```

---

## Exercice 8 — Menu interactif

```bash
#!/bin/bash

CHOIX=0

while [ "$CHOIX" != "3" ]
do
    echo "1) Afficher la date"
    echo "2) Afficher l'utilisateur courant"
    echo "3) Quitter"
    read CHOIX

    if [ "$CHOIX" = "1" ]; then
        date
    elif [ "$CHOIX" = "2" ]; then
        whoami
    elif [ "$CHOIX" = "3" ]; then
        echo "Au revoir"
    else
        echo "Choix invalide"
    fi
done
```

---

## Exercice 9 — Vérification d'espace disque

```bash
#!/bin/bash

USAGE=$(df / | awk 'NR==2 {print $5}' | tr -d '%')

if [ $USAGE -gt 80 ]; then
    echo "ALERTE : espace disque critique"
    exit 1
else
    echo "Espace disque OK : $USAGE%"
fi
```

---

## Exercice 10 — Rapport système

```bash
#!/bin/bash

RAPPORT="rapport.txt"

echo "===== RAPPORT SYSTÈME =====" > $RAPPORT
echo "" >> $RAPPORT

echo "Date : $(date)" >> $RAPPORT
echo "Hostname : $(hostname)" >> $RAPPORT
echo "Utilisateur : $(whoami)" >> $RAPPORT

echo "" >> $RAPPORT
echo "--- Utilisateurs connectés ---" >> $RAPPORT
who >> $RAPPORT

echo "" >> $RAPPORT
echo "--- Espace disque ---" >> $RAPPORT
df -h / >> $RAPPORT

echo "" >> $RAPPORT
echo "--- Top 5 processus CPU ---" >> $RAPPORT
ps aux --sort=-%cpu | head -6 >> $RAPPORT

echo "Rapport généré : $RAPPORT"
```
