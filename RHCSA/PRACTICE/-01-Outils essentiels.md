# **-1- Outils essentiels**

---

- Ici sera exposé dans l'odre du document [README.md](https://github.com/NALSED/CERTIF/blob/main/RHCSA/README.md), section -1-Outils essentiels.

---

# **1.2** — Redirection des entrées/sorties — `>` `>>` `<` `2>` `|` `tee`

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

# **1.3** — `grep` et expressions régulières — `grep -E`, `grep -F`
[Regex](https://regex101.com/) et [Exercice](https://github.com/NALSED/CERTIF/tree/main/RHCSA/PRACTICE/EXO/GREP)

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

- Fichier `/home/$USER/.ssh/config`

Permet de créer un alias de client ssh
````
vim /home/$USER/.ssh/config
````

- Renseigné (Si doute => `man ssh_config`)
````
Host NOM CLIENT
   HostName IP/NOM DE DOMAINE
   User NOM USER CLIENT
````

---
---

 # **1.5** — Changer d'utilisateur — `su`, `su -`, `sudo`  

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

# **1.6** — Archiver et compresser — `tar`, `gzip`, `bzip2`, `xz`  

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

# **1.9** — Liens physiques (`ln`) et symboliques (`ln -s`)  

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

# **1.10** — Permissions `ugo/rwx` — `chmod`, `chown`, `chgrp`, `umask`, `suid`, `sgid`, `sticky-bit` 

## 📝 **SOMMAIRE**

- 1️⃣ `chmod`/ `chown` / `chgrp`
- 2️⃣ `umask`
- 3️⃣ `suid` / `sgid` / `sticky-bit` 

---

### 1️⃣ **`chmod`/ `chown` / `chgrp`**

Utilisé pour changer le mode `chmod`, le propriétaire `chown` ou le groupe `chgrp`

### `-1.1.` Lister les permission :

- `ls` =>  liste le contenu d'un répertoire 
    **=== Options Principales ===**
````
-l Format long (permissions, taille, date…) 
-a Affiche les fichiers cachés (.)
-h Tailles lisibles par un humain (utimiser avec -l)
-r Ordre inverse
-t Tri par date de modification
-S Tri par taille
-R Récursif
-d Affiche le répertoire lui-même, pas son contenu
-i Affiche l'inode
````
    
- `stat` =>  affiche les métadonnées détaillées d'un fichier ou répertoire (permissions, tailles, horodatages)

- `getfacl` =>  affiche les ACL (Access Control Lists) d'un fichier ou répertoire

---

### `-1.2.` Définition :

**Permissions ou mode**

```
- --- --- ---
↑  ↑   ↑   ↑
│  │   │   └── others
│  │   └────── group
│  └────────── user (owner)
└───────────── type de fichier
```


— Type de fichier (1er caractère)

| Car. | Type | Exemple |
|:----:|------|---------|
| `-` | Fichier ordinaire | `/etc/passwd` |
| `d` | Répertoire | `/home/user/` |
| `l` | Lien symbolique | `/bin/sh -> dash` |
| `c` | Périphérique caractère | `/dev/tty` |
| `b` | Périphérique bloc | `/dev/sda` |
| `p` | Tube nommé (FIFO) | `/run/systemd/initctl/fifo` |
| `s` | Socket Unix | `/run/docker.sock` |

— Valeur des triplets `rwx` (par entité ugo)

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

---

### `-1.3.` Utilisation Commandes

Options courantes pour les `chmod`, `chown`, `chgrp` => -R (Récurssif) / -c (Verbeux sur les changements)
````
# Octale ici : user r + w / groups w / others w
chmod 644
````

````
# Lettres
chmod [cible][+|-][permission lettres] fichier
option u (users) g(groups) o(others)
=> chmod o-w supprime la lecture aux autres utilisateurs
````
 
---

- `chown`
Peux changer utilisateur et groupe
````
chown [user] [fichier]
chown [user]:[groupe] [fichier]
chown :[groupe] [fichier]
````

---

- `chgrp`
````
chgrp [groupe] [fichier]
````

---

### 2️⃣ **`umask`**

`-2.1.` Définition :
Permet d'appliquer des `droits par defaut`, lors de la `création de dossiers ou fichiers`.
Les droits par defauts (sans modification de `umask`) sur linux sont :
- Dossiers : `755`
- Fichiers : `644`

`-2.2.` Fonctionnement :

`umask` pour user mask, utilise le ET binaire sur les droits maximaux sur 777 (dossiers) et 666 (fichiers), avec les droits octals vu plus haut.

-2.2.1 Voir la valeur de umask
````
umask
# Par defaut Sortie
0022
````


```
0  0   2   2
↑  ↑   ↑   ↑
│  │   │   └── Permissions others
│  │   └────── Permissions group
│  └────────── Permissions user (owner)
└───────────── Permissions spéciales ignoré pour le calcule (voir : suid, sgid, sticky-bit  ) 
```

-2.2.2 Fonctionnement
umask utilise **AND NOT** : d'abord **NOT** inverse le masque, puis **AND** l'applique sur la base.

`[RAPPEL]`

`AND`
| A | B | A AND B |
|---|---|---------|
| 0 | 0 |    0    |
| 0 | 1 |    0    |
| 1 | 0 |    0    |
| 1 | 1 |    1    |

`NOT`
| A | NOT A |
|---|-------|
| 0 |   1   |
| 1 |   0   |

`Calcul réel — umask 022`
```
umask 022   = 000 010 010
NOT 022     = 111 101 101

0666        = 110 110 110
AND NOT 022 = 110 100 100  →  0644

0777        = 111 111 111
AND NOT 022 = 111 101 101  →  0755
```

Pour simplifier on peut utiliser l'analogie suivante :  
La sortie de umask indique ce qui est retiré aux utilisateurs/groupes/autres toujours en octal (en arrondissant au supérieur)
- Ici :

`Dossiers`  
777 - 022 = 755

`Fichiers`  
666 - 022 = 644

Donc par défaut Dossiers et Fichiers auront respectivement les permissions `755` et `644`.

`[NOTE]`
Changer umask pour root 
````
su -
vim /root/.bashrc
# Ajouter
umask VALEUR SOUHAITEE
````

Changer umask pour user
- La valeur est dans le fichier `/etc/login.defs`

<img width="613" height="70" alt="image" src="https://github.com/user-attachments/assets/df4a93b9-591e-4da9-a15c-f686f38fdeac" />


---

### 3️⃣ **`suid` / `sgid` / `sticky-bit`** 

Les bit suid/guid/sticky-bit

`-3.1.` Définition 

-3.1.1 `suid` 
Abréviation de `Set User ID`, est une autorisation spéciale sur les fichiers exécutables, qui permet à tous les utilisateurs de disposer temporairement des priviléges du propriétaire du fichier.
Autrement dit, même si l'utilisateur courant ne dispose pas des droits nécessaire sur le fichier il pourra quand même l'exécuter.

- Exemple : le binaire `/usr/bin/passwd`.

`passwd` est une `commande` permettant de `modifier le mot de passe` de l’utilisateur et possède un bit SUID.

Lorsque nous tapons la commande, nous `l’exécutons en tant qu’utilisateur root`, sans ça on ne pourrait pas `modifier le fichier /etc/shadow`, et par concéquent être dans l'incapacité de modifier son mot de passe sans passer par root.

pour voir si un fichier à le bit suid activé
````
ls -l /FICHIER CIBLE
# Sortie
-rwsr-xr-x
   ↑
   └── `s` remplace le `x` dans la partie user
````

-3.1.2`sgid` 
Abréviation de `Set Group ID`, si `sgid` est activé,  les fichiers et répertoires nouvellement créés dans ce répertoire héritent de la propriété de groupe du répertoire parent plutôt que de la propriété de groupe par défaut de l’utilisateur.

- Exemple : Avec Bareos dans le dossier `/etc/bareos/` le bit `sgid` est activé.

<img width="543" height="48" alt="image" src="https://github.com/user-attachments/assets/4097ee93-f89b-42f9-b083-05969b937bd8" />

pour voir si un fichier à le bit suid activé
````
ls -l /FICHIER CIBLE
# Sortie
-rwxr-sr-x
      ↑
      └── `s` remplace le `x` dans la partie group
````

-3.3.3`sticky-bit`
Il permet d’interdire la suppression ou déplacement de fichiers dans un répertoire créé par un autre utilisateur.

L’utilisateur ne pourra supprimer que ses propres fichiers.

pour voir si un fichier à le bit suid activé
````
ls -l /FICHIER CIBLE
# Sortie
-rwxr-xr-t
         ↑
         └── `t` remplace le `x` dans la partie group
````


`-3.2.` Fonctionnement

`suid`
````
chmod u+s <fichier>
chmod u-s <fichier>
````

`sgid`
````
chmod g+s <fichier>
````

`sticky-bit`
````
chmod +t <fichier>
chmod g+t <fichier>
````

**Trouver les fichier/dossier avec le bit suid/sgid/sticky-bit activé**
````
#suid
find / -perm 4000 -type f 2>/dev/null

#sgid
find / -perm 2000 -type f 2>/dev/null

#sticky-bit 
find / -perm 1000 -type f 2>/dev/null
````

