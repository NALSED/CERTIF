# -1- Outils essentiels

---

- Ici sera exposé dans l'odre du document {README.md](https://github.com/NALSED/CERTIF/blob/main/RHCSA/README.md), la section -1-Outils essentiels.

---

**1.2** — Redirection des entrées/sorties — `>` `>>` `<` `2>` `|` `tee`

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

- `>` et `>>

Si l'on réutilise `>`, le contenu de `var.txt` sera écrasé.  
En revanche, si l'on utilise `>>`, le contenu sera ajouté à la suite de l'existant.

:warning: `>` `>>` ne redirige que stdout pas stderr 

Ici, redirection du contenu de `/var` dans un fichier `.txt`, puis affichage du contenu de ce fichier dans le shell.
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

- Ici wc compte le nombre de ligne de var.txt
````
sednal@rhel:~$ wc -l < var.txt
21
````


### - `2>`

-Ici le message d'erreur est redirigé vers le fichier texte
````
sednal@rhel:~$ ls aaaa 2> ls_error.txt
sednal@rhel:~$ cat ls_error.txt
ls: cannot access 'aaaa': No such file or directory
````

`[NOTE]` Il est possible de combiner `>` `2>` et d'utiliser `devnul` pour ne pas avoir de  sortie.

- Ici le contenue de /var se retrouve dans le dossier sortie.txt, et il n'y à pas de sortie avec /dossier_inexistant
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

- Ici, `ls` liste le contenu de `/etc` → `grep` isole les dossiers commençant par "s" → `wc` compte le nombre de lignes, et ce nombre est enregistré dans le fichier `etc.txt`.
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





















