# -1- Outils essentiels

---

- Ici sera exposé dans l'odre du document [README.md](https://github.com/NALSED/CERTIF/blob/main/RHCSA/README.md), section -1-Outils essentiels.

---

## **1.2** — Redirection des entrées/sorties — `>` `>>` `<` `2>` `|` `tee`

Concept :
- entrée standard : `stdin` fd 0
- sortie standard : `stdout` fd 1
- sortie erreur : `stderr` fd 2
- redirection sortie : `>` écrase, `>>` ajoute
- redirection entrée : `<`
- redirection erreur : `2>`
- pipe : `|` stdout → stdin suivant (permet d'enchainer le traitement d'une commande)
- tee : `tee` stdout + fichier simultanément

---

### -`>`, `>> et `<`

- `>` et `>>`

:warning: `>` `>>` ne redirige que stdout pas stderr 


=> Ici, redirection du contenu de `/var` dans un fichier `.txt`, puis affichage du contenu de ce fichier dans le shell.
Si l'on réutilise `>`, le contenu de `var.txt` sera écrasé.  
En revanche, si l'on utilise `>>`, le contenu sera ajouté à la suite de l'existant.
````
sednal@rhel:~$ ls /var > /home/sednal/var.txt && cat /home/sednal/var.txt
account
adm
cache
crash
db
empty
ftp
games
kerberos
lib
local
lock
log
mail
nis
opt
preserve
run
spool
tmp
yp
````

- `<`

Redirige l’entrée standard (stdin) d’une commande depuis un fichier.

=> Ici wc compte le nombre de ligne de var.txt
````
sednal@rhel:~$ wc -l < var.txt
21
````

`[NOTE]` 
- Il est possible de récupérer un stderr et de la "changer" stdout, `2>&1`, par exemple pour `grep` les stderr (grep ne prend que les stdout).

### - `2>`

=> Ici le message d'erreur est redirigé vers le fichier texte
````
sednal@rhel:~$ ls aaaa 2> ls_error.txt
sednal@rhel:~$ cat ls_error.txt
ls: cannot access 'aaaa': No such file or directory
````

`[NOTE]` Il est possible de combiner `>` `2>` et d'utiliser `devnul` pour ne pas avoir de  sortie.

=> Ici le contenue de /var se retrouve dans le dossier sortie.txt, et il n'y à pas de sortie avec /dossier_inexistant
````
sednal@rhel:~$ ls /var /dossier_inexistant > sortie.txt 2> /dev/null
sednal@rhel:~$ cat sortie.txt
/var:
account
adm
cache
crash
db
empty
ftp
games
kerberos
lib
local
lock
log
mail
nis
opt
preserve
run
spool
tmp
yp
```` 

### - `|`
Permet d'envoyer la sortie d'une commande vers l'entrée d'une autre commande.

=> Ici, `ls` liste le contenu de `/etc` → `grep` isole les dossiers commençant par "s" → `wc` compte le nombre de lignes, et ce nombre est enregistré dans le fichier `etc.txt`.
````
sednal@rhel:~$ ls /etc | grep ^"s" | wc -l > etc.txt
sednal@rhel:~$ cat etc.txt
35
````


### `tee`

La commande `tee` permet de rediriger la sortie d'une commande vers un fichier tout en l'affichant à l'écran.
````
sednal@rhel:~$ ls /var | tee var_tee.txt
account
adm
cache
crash
db
empty
ftp
games
kerberos
lib
local
lock
log
mail
nis
opt
preserve
run
spool
tmp
yp
sednal@rhel:~$ cat var_tee.txt
account
adm
cache
crash
db
empty
ftp
games
kerberos
lib
local
lock
log
mail
nis
opt
preserve
run
spool
tmp
yp
````


---
---

## **1.3** — `grep` et expressions régulières — `grep -E`, `grep -F`
[Regex](https://regex101.com/)

- Syntaxe : `grep [OPTIONS] MOTIF [FICHIER...]`

– Options `grep`
- **-E** à la place de egrep : permet d’utiliser une syntaxe de regex plus riche.
- **-F** à la place de fgrep : désactive totalement les regex et traite le motif comme une chaîne brute.
- **-i** : Ignore la casse (majuscule/minuscule) dans le motif et les fichiers.  
- **-f fichier** : Lit le motif depuis un fichier.
- **-n** : Affiche `num` lignes avant et après chaque correspondance (une ligne n’est jamais répétée).  
- **-A n** : Affiche `num` lignes après la correspondance.  
- **-B n** : Affiche `num` lignes avant la correspondance.  
- **-C n** : Affiche `num` lignes avant et après la correspondance (équivalent à `-num`).  
- **-V** : Affiche le numéro de version de `grep` sur stderr (utile pour rapports de bogues).  
- **-b** : Affiche le décalage en octets avant chaque ligne correspondante.  
- **-c** : Affiche uniquement le nombre de lignes correspondant au motif (`-v` inverse la sélection).  
- **-e motif** : Utilise le motif indiqué, pratique pour motifs commençant par `-`.  
- **-h** : Ne pas afficher le nom des fichiers lors de la recherche sur plusieurs fichiers.  
- **-L** : Affiche les fichiers **sans** correspondance.  
- **-l** : Affiche les fichiers **avec** correspondance.  
- **-n** : Préfixe chaque ligne avec son numéro dans le fichier.  
- **-q** : Silence complet, aucune sortie normale.  
- **-s** : Supprime les messages d’erreur pour fichiers inexistants ou illisibles.  
- **-v** : Inverse la correspondance (sélectionne les lignes **ne correspondant pas** au motif).  
- **-w** : Sélectionne uniquement les correspondances formant un mot complet.  
- **-x** : Sélectionne uniquement les lignes correspondant **exactement** au motif.


Principaux métacaractères utilisés :

| Métacaractère | Signification | Exemples |
|---|---|---|
| . | N'importe quel caractère | |
| * | 0 ou plusieurs répétitions | ab*c => ac abc abbc etc.. |
| + | 1 ou plusieurs répétitions | ab+c => abc abbc abbbc (pas ac) |
| ? | 0 ou 1 répétition | colou?r => color/colour |
| [...] | Classe de caractère | [a-Z] [0-9] |
| ^ | Début de ligne | |
| $ | Fin de ligne | |
| | | Alternative | Avec -E | 
| \| | Alternative | Sans -E (échappement \)|

:warning: `*` `+` `?` s'appliquent sur le caractère ou le groupe précédent. (dans les exemple ci dessus `b` ou `u`).


---

## **1.4** — Accès distant via `ssh` 

-Accés ssh 
````
ssh USERNAME @ IP / DOMAIN NAME
````

- Accés sans mots de passe
Générer les clés (ed25519 conseillé =>  plus court, plus rapide, plus sûr par conception, moins fragile aux mauvaises implémentations.)
````
ssh-keygen -t ed25519 -C "COMMENTAIRE"
````

- Copier la clé
````
ssh-copy-id -i /home/$USER/.ssh/id_ed25519.pub client@ip
````

- Sortie





