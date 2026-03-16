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
---

## **1.4** — Accès distant via `ssh` 

- Install
````
sudo dnf install openssh-clients openssh-server
````

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

- Fichier de configuration
````
sudo vim /etc/ssh/sshd_config
````

---
---

 ## **1.5** — Changer d'utilisateur — `su`, `su -`, `sudo`  

## `su`
 
**Switch User** — change d'utilisateur sans changer l'environnement.
 
```bash
sednal@rhel:~$ su
Password:
rootl@rhel:~#
```
 
- Le shell démarre en tant que `root`, mais le répertoire courant (`~`) et les variables d'environnement (`PATH`, `HOME`…) restent ceux de l'utilisateur d'origine.
 
---
 
## `su -`
 
**Switch User with login shell** — change d'utilisateur ET charge son environnement complet.
 
```bash
sednal@rhel:~$ su -
```
 
- Le `-` (ou `--login`) lance un shell de connexion complet : `HOME`, `PATH`, `MAIL`, etc. sont rechargés depuis le profil de `root`. Le répertoire courant devient `/root`.
 
---
 
## `su - <user>`
 
Changer vers un utilisateur spécifique avec son environnement.
 
```bash
sednal@rhel:~$ su - USER
```
 
- Même comportement que `su -` mais vers un utilisateur non-root. Demande le **mot de passe de la cible**.


---

## `sudo`

**Superuser Do**



---
---

## **1.6** — Archiver et compresser — `tar`, `gzip`, `bzip2`, `xz`  

`[NOTE]`
- Vitesse : gzip > bzip2 > xz  |  Compression : xz > bzip2 > gzip
- `tar` seul ne compresse pas — il délègue la compression à l'outil externe via le flag :


- `tar`

### **Flags essentiels**
 
| Flag | Rôle |
|---|---|
| `-c` | créer une archive |
| `-x` | extraire |
| `-t` | lister le contenu |
| `-f` | nom du fichier *(toujours en dernier)* |
| `-v` | verbose |
| `-C` | répertoire de destination |
| `-z` | compression gzip (`.tar.gz`) |
| `-j` | compression bzip2 (`.tar.bz2`) |
| `-J` | compression xz (`.tar.xz`) |
| `-p` | préserver les permissions |
| `--selinux` | inclure les contextes SELinux |


### Créer
 
```bash
tar -czf archive.tar.gz  dossier/        # .tar.gz
tar -cjf archive.tar.bz2 dossier/        # .tar.bz2
tar -cJf archive.tar.xz  dossier/        # .tar.xz
tar -cf  archive.tar      dossier/        # sans compression
tar -cf  archive.tar f1 f2 rep/           # sources multiples
tar -cf  archive.tar rep/ --exclude=rep/tmp
```
 
### Extraire
 
```bash
tar -xf archive.tar.gz                   # répertoire courant
tar -xf archive.tar.gz -C /dest/         # dans /dest/
tar -xf archive.tar.gz rep/fichier.txt   # un fichier précis
```
 
### Inspecter
 
```bash
tar -tf  archive.tar.gz    # lister
tar -tvf archive.tar.gz    # lister détaillé
```
 
### Modifier
 
```bash
tar -rf archive.tar nouveau.txt    # ajouter
tar -uf archive.tar fichier.txt    # mettre à jour
```

---
---

## **1.9** — Liens physiques (`ln`) et symboliques (`ln -s`)  

=>  `ln` ou alias

- Inode identique
- Métadonnées identiques (même date, mêmes permissions, même propriétaire)
- Aucune duplication des données sur le disque
- Modifier l'un affecte l'autre 

- exemple
````
ln [FICHIER SOURCE] [FICHIER CIBLE]
# Ici :
ln testlink testlink2
````

````
ls -li
````

-Sortie 
````
2153122 -rw-r--r--. 2 sednal sednal      10 Mar 16 14:29 testlink
2153122 -rw-r--r--. 2 sednal sednal      10 Mar 16 14:29 testlink2
````

=> `ln -s`

- C'est un fichier à part entière qui pointe vers un chemin
- Inode différent de la cible
- Si le fichier source est supprimé → le lien symbolique est cassé (dangling symlink)
- Peut pointer vers un autre système de fichiers ou une partition différente
- Peut pointer vers un répertoire (impossible avec un lien physique)

````
ln -s [FICHIER SOURCE] [FICHIER CIBLE]
# Ici :
ln test_2.txt link_to_test
````

````
ls -li
````

-Sortie 
````
2153954 lrwxrwxrwx. 1 sednal sednal      10 Mar 16 14:23 link_to_test -> test_2.txt2
````

---
---

## **1.10** — Permissions `ugo/rwx` — `chmod`, `chown`, `chgrp`, `umask`  

- Lister les permission :
   - `ls` =>  liste le contenu d'un répertoire 
   - `stat` =>  affiche les métadonnées détaillées d'un fichier ou répertoire (permissions, tailles, horodatages)
   - `getfacl` =>  affiche les ACL (Access Control Lists) d'un fichier ou répertoire

**- Permissions ou mode**

```
- --- --- ---
↑  ↑   ↑   ↑
│  │   │   └── others
│  │   └────── group
│  └────────── owner
└───────────── type de fichier
```

---

## I — Type de fichier (1er caractère)

| Car. | Type | Exemple |
|:----:|------|---------|
| `-` | Fichier ordinaire | `/etc/passwd` |
| `d` | Répertoire | `/home/user/` |
| `l` | Lien symbolique | `/bin/sh -> dash` |
| `c` | Périphérique caractère | `/dev/tty` |
| `b` | Périphérique bloc | `/dev/sda` |
| `p` | Tube nommé (FIFO) | `/run/systemd/initctl/fifo` |
| `s` | Socket Unix | `/run/docker.sock` |

---

## II — Valeur des triplets `rwx` (par entité)

| Octal | Binaire | Symbole | r | w | x | Description |
|:-----:|:-------:|:-------:|:-:|:-:|:-:|-------------|
| `0` | `000` | `---` | ✗ | ✗ | ✗ | Aucun droit |
| `1` | `001` | `--x` | ✗ | ✗ | ✔ | Exécution seule |
| `2` | `010` | `-w-` | ✗ | ✔ | ✗ | Écriture seule |
| `3` | `011` | `-wx` | ✗ | ✔ | ✔ | Écriture + exécution |
| `4` | `100` | `r--` | ✔ | ✗ | ✗ | Lecture seule |
| `5` | `101` | `r-x` | ✔ | ✗ | ✔ | Lecture + exécution |
| `6` | `110` | `rw-` | ✔ | ✔ | ✗ | Lecture + écriture |
| `7` | `111` | `rwx` | ✔ | ✔ | ✔ | Tous les droits |

`[NOTE]`

- 4 = Read
- 2 = Write
- 1 = Execute


**Commandes**

- `chmod`
Options courantes : -R (Récurssif) / -c (Verbeux sur les changements)

- Exemple
````
# Octale , ici user r + w / groups w / others w
chmod 644
````

````
# Lettres
chmod [cible][+|-][permission] fichier
option u (users) g(groups) o(others)
=> chmod o-w supprime la lecture aux autres utilisateurs
````
 
---

- `chown`


















