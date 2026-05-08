
# -3- Créer des scripts shell simples

`[RAPPEL]`

- `#!/bin/bash`
- `.sh` conseillé
- chmod +x

- Commande de dé bugage => exécuter le script avec **bash -x ./script.sh**

---
  
# **3.1** — Exécution conditionnelle — `if`, `test`, `[ ]`, `[[ ]]`  

**=== if ===**

`syntaxe`
````
if CONDITION
then
    commandes

elif AUTRE_CONDITION
then
    commandes

else
    commandes

fi
````

- pour les test avec `if` ou autre `man test`

---

# **3.2** — Boucles — `for`, `while`  

**=== for ===**

`syntaxe de base`
````
for ELEMENT(création d'une variable) in LISTE DES ELEMENTS (liste à parcourir)
do
   bloc de commandes
done
````

`syntaxe avec itération`
````
for ((ETAT INITIAL; CONDITION DE REPETITION ; INCREMENTATION A CHAQUE REPETITION))
do
   bloc de commandes
done
````

---

**=== while ===**

- `while` exécute la condition tant que la condition écrite est `vrai`
````
while [ condition ]
do
    # commandes
done
````

---

# **3.3** — Entrées de script — `$1`, `$2`, `$@`, `$#`, `$?`  et Codes de retour —  `exit`, `&&`, `||`  

**- Variables :**

Une variable est défini => `key=value` , puis appelée avec $
````
color=red
echo $red
````

=> `$NOMBRE` : Variable positionelle, 1 args1, 2 args2, etc...

=> `$@` : Tous les arguments

=> `$#` : Nombre d'arguments 

=> `$?` : Code retour de la dernière commande (0=ok / autre=nok)

=> `!$` : Dernier argument de la commande précédente

---

**- Code Retour :**

`exit` => Quitter avec un code (0 succés, autre erreur)

`&&` => ET logique (si succès, alors...)

`||` => OU logique (si échec, alors...)

---
---

# **EXO** => [liens Exercices](https://github.com/NALSED/CERTIF/tree/main/RHCSA/PRACTICE/EXO/SCRIPT)

