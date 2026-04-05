# Utiliser des systèmes en cours d'exécution

---

`[INTRO]`
 
Tout programme en cours d'exécution est un **processus**. Le kernel lui attribue un PID, de la mémoire, et des tranches de temps CPU via l'ordonnanceur (CFS).
 
Un processus naît par `fork()` depuis un parent, optionnellement suivi d'un `exec()` pour charger un nouveau programme. Il alterne entre espace user (son code) et espace kernel (ses appels système).
 
À tout moment il est dans un état : actif `R`, en attente `S` (en attente d'une requéte hardware, réceptif au sigaux)/`D` (ne peux être interompu), stoppé `T`, ou zombie `Z` s'il est terminé mais non récupéré par son parent, `K` en attente d'être arrété
 
---

=== Commande Générique ===
```
# Exécuter un processus en arrière plans
COMMAND &

# Dépplacer un processus en arrière plans
Ctrl Z + bg

#Lister les processus
jobs

# Placer un processus en premier plans
fg NUMERO LISTER AVEC JOBS
```


---
---

## 4.1 — Démarrer, redémarrer, éteindre systemctl reboot, poweroff, shutdown

---


## 4.2 — Démarrer dans différentes cibles — systemctl isolate multi-user.target

---

## 4.3 — Interrompre le démarrage pour accès root — GRUB → rd.break / init=/bin/bash

---

## 4.4 — Processus gourmands RAM et CPU — ps, free, top, uptime, kill, killall

`[NOTE]`
- Linux placera le plus possible de fichier en mémoire cache, par sécurité un `swap`, au cas ou l'on manquerai de mémoire, le swap est créer à partir d'espace disque.


**=>** **ps** permet de lister les procéssus en cours d'éxecution sur la machine
Les options sont très nombreuse, en voici quelque une :

- `ps fax` => Donne une hiérarchie des processus parent - enfants

- `ps -u` => Permet de lister les processus pour un utilisateur précis

- `ps -f --forest -C NOM DU PREOCESSUS` => Permet de d'affiche les infos sur un processus.

- `ps L` => affiche les option / collones que ps peux afficher

- `ps -o` => permet de chosir les option parmis celle listé par `ps L`, mais `ps -o` liste pour l'utilisateur, si on veux tout lister `ps -oe OPTION`


**=>** **free** permet de voir la mémoire / swap utilisé et disponible

- `free -m` pour avoir une sortie de la mémoire en mégaoctet 

- Pour plus de détails sur la mémoire voir le fichier `/proc/meminfo`

`[NOTE]`
Si un fichier est créé, il est d'abord stocké dans le **buffer d'écriture en RAM**.
Pour s'assurer qu'il soit écrit immédiatement sur le disque, utiliser la commande `sync`.
Car si le serveur plante avant que le fichier soit écrit sur le disque, il sera perdu.
 
```bash
sync
```

Linux tamponne l'écriture en RAM pour ne pas ralentir le programme *(writeback asynchrone)*.
Régulation de flux RAM → disque, car le disque à une vitesse d'écriture inférieur à celle de la RAM.


**=>** **top**

`top` est un moniteur de processus en temps réel dans le terminal.

=== Commandes ===

- `q` — Quitter

- `k` — Tuer un processus (demande le PID)

- `M` — Trier par utilisation mémoire

- `P` — Trier par utilisation CPU

- `u` — Filtrer par utilisateur

- `1` — Afficher chaque CPU séparément

- `h` — Aide

- `f` contenu aditionel 

**=>** **uptime**

- Donne des information sur la durée depuis le démarrage, le nombre de session et de charge `CPU` depuis 1, 5 et 15 minutes 

`[NOTE]` 
La commande`lscpu` donne les informations complétes sur lou les `CPU`

 **=>** **kill** et **SIGNAL**

- `kill` — envoie un signal à un processus par son **PID**

- `killall` — envoie un signal à tous les processus par leur **nom**

- `pkill -u USERNAME` envoie un siganl aux processus de l'utilisateur choisi.

```
kill 1234        # tue le PID 1234
killall nginx    # tue tous les processus nommés nginx
```


**=>** **SIGNAL**
```
#Lister les signal
kill -l
```

- Il sont généralement au nombre de 64, mais l'on utilise principalement les 1, 2, 9, 15.

- Pour avoir une définition précise de chaque signal
```
man 7 signal
```

Pour voir comment tuer un zombie => [Exercice Zombie](https://github.com/NALSED/CERTIF/blob/main/RHCSA/PRACTICE/EXO/PROCESSUS/Zombie.md)

---
## 4.5 — Priorité des processus — nice, renice

`[NOTE]`

- Linux attribu via cgroups des "tanches" de `ressources`, entre :

   - System : Tous les process Systemd
   - User : Tous les process User
   - Machine : Virtual Machine, Container

(cgroups est la brique fondamentale sur laquelle repose l'isolation et la gestion des ressources sous Linux.)

`nice` (au lancement d'un processus) et `renice` (sur un processus en cours) on une plage de priorité allant de -20 => +19 (- 19 étant le plus prioritaire)
```
nice ou renice -n NOMBRE PRIORITE COMMANDE

#Exemple
nice -n 10 dd if=/dev/sda of=/test &
```


---

## 4.6 — Profils de tuning — tuned-adm list, tuned-adm profile


- `tuned` est un daemon Linux qui optimise automatiquement les performances du système en appliquant des profils prédéfinis selon l'usage de la machine.
Les modification appliqués par `tuned`, sont visible dans l'outil bas niveau `sysctl`.

- **/proc/sys** => Pseudo filesystem monté par le kernel, qui liste les options

- **sysctl** commande sui agit sur /proc/sys

- **sysctl.d** dossier de persitance de la configuration

- **tuned-adm** Outil d'administration de `tuned`

- Fichier de **configuration** de `tuned`  **cat /etc/tuned/tuned-main.conf**

`[NOTE]`

- Pour voir la valeurs des profils de `sysctl`
```
sysctl -a 
```

- Pour modifier les valeurs de sysctl (ici le swappiness de vm)=> dans `/etc/sysctl.d`
```
cat >> /etc/sysctl.d/swappiness.conf << EOF
vm.swappiness = 40
EOF
```

- Recharger
```
# Rechargement ciblé
sysctl -p /etc/sysctl.d/vm.swappiness.conf

# recharge tout
sysctl --system
```

- Les profiles de `tuned` se trouvent dans `/usr/lib/tuned`

- Lister les profiles
```
tuned-adm list
```

- Changer de profile
```
tuned-adm profile PROFILE 
``` 

=== Personalisation de profile tuned ===

1) créer un répertoire dans /etc/tuned
```
mkdir /etc/tuned/my_profile
```

2) Créer un fichier de configuration
```
vim /etc/tuned/my_profile/tuned.conf

# Editer
[sysctl]
vm.swapinness = 40
```    

3) Utiliser le profile créé
```
tuned-adm profile my_profile
```

----
## 4.7 — Journaux système — journalctl, journalctl -u, /var/log/


---

## 4.8 — Gestion des sessions actives - loginctl

- `loginctl` dépend de `systemd`, qui gére les sessions et utilisateurs.

**Lister**

- User
```
loginctl list-users
```

- Sessions
```
loginctl list-sessions
```

- Processus (liste en arborécence les processus de l'utilisateur choisi)
```
loginctl user-status UID
```

- Terminer session ou user
```
loginctl terminate-session
loginctl terminate-user
```

---
## 4.9 — Persistance des journaux — journald.conf → Storage=persistent


---

## 4.10 — SYSTEMD 

`systemd` gère les ressources système via des **unités**, chacune d'un type spécifique :

- **Service** — processus daemon géré par systemd

- **Socket** — point de communication IPC ou réseau, active un service à la demande

- **Timer** — déclenchement planifié (alternative à cron)

- **Path** — surveille un fichier/dossier et active un service sur événement

- **Mount** — gère les points de montage filesystem, équivalent systemd de `/etc/fstab`

`[NOTE]` Liste disponible des unit systemd, via `systemctl`, la commande pour gérer systemd (A par celle mentionnées ci dessus, hors scope pour RHCSA.)
```
systemctl -t help
```

**=== Lister ===**

- `Units chargés sur la machine`
```
systemctl list-units
```

- `Catégories de units` (Disponible via `systemctl -t help`)
```
systemctl list-units -t UNIT
```

- `Etats units`
```
systemctl list-unit-files
``` 

**=== Management systemctl ===**
```
# status
systemctl status SERVICE
# Sortie
- Active => Status actuel
- Loaded => Configuration chargée

# Arréte / Démarrer 
# Normal
systemctl start
systemctl stop

# Au boot
systemctl enable
systemctl disable

# réinitialisation complète (Nouveau PID) 
systemctl restart

#  changements de config à chaud,
systemctl reload
```

**=== Configuartion fichier units ===**

- Les fichier de configuration `system` de `systemd` sont dans le dossier `/usr/lib/systemd/system`

- Pour créer des fichier unit personalisés : `/etc/systemd/system`

- Pour voir les options possible sur un service
```
systemctl show SERVICE
```

`[NOTE]` 

 **Bonne Pratique** Pour modifier un `unit

 - Utiliser la commande `systemctl edit`, cela crééra un fichier directement dans `/etc/systemctl/system` sans toucher au fichier dans `/usr/lib/sytemd/system`.


<details>
<summary>
<h2>
=== Exemple ===
</h2>
</summary>

1) voir la configuration actuelle
```
systemctl cat httpd.service

# ==> Sortie
# /usr/lib/systemd/system/httpd.service
# See httpd.service(8) for more information on using the httpd service.

# Modifying this file in-place is not recommended, because changes
# will be overwritten during package upgrades.  To customize the
# behaviour, run "systemctl edit httpd" to create an override unit.

# For example, to pass additional options (such as -D definitions) to
# the httpd binary at startup, create an override unit (as is done by
# systemctl edit) and enter the following:

#       [Service]
#       Environment=OPTIONS=-DMY_DEFINE

[Unit]
Description=The Apache HTTP Server
Wants=httpd-init.service
After=network.target remote-fs.target nss-lookup.target httpd-init.service
Documentation=man:httpd.service(8)

[Service]
Type=notify
Environment=LANG=C

ExecStart=/usr/sbin/httpd $OPTIONS -DFOREGROUND
ExecReload=/usr/sbin/httpd $OPTIONS -k graceful
# Send SIGWINCH for graceful stop
KillSignal=SIGWINCH
KillMode=mixed
PrivateTmp=true
OOMPolicy=continue

[Install]
WantedBy=multi-user.target

```


2) Editer les modification du fichier
```
systemctl edit httpd.service

# ==> Sortie + Edition 
### Editing /etc/systemd/system/httpd.service.d/override.conf
### Anything between here and the comment below will become the new contents of the file

[Service]       <=== Changement ===
Restart=always  <=== Changement ===
RestartSec=5s   <=== Changement ===

### Lines below this comment will be discarded

### /usr/lib/systemd/system/httpd.service
# # See httpd.service(8) for more information on using the httpd service.
# 
# # Modifying this file in-place is not recommended, because changes
# # will be overwritten during package upgrades.  To customize the
# # behaviour, run "systemctl edit httpd" to create an override unit.
# 
# # For example, to pass additional options (such as -D definitions) to
# # the httpd binary at startup, create an override unit (as is done by
# # systemctl edit) and enter the following:
# 
# #     [Service]
# #     Environment=OPTIONS=-DMY_DEFINE
# 
# [Unit]
# Description=The Apache HTTP Server
# Wants=httpd-init.service
# After=network.target remote-fs.target nss-lookup.target httpd-init.service
# Documentation=man:httpd.service(8)
# 
# [Service]
# Type=notify
# Environment=LANG=C
# 
# ExecStart=/usr/sbin/httpd $OPTIONS -DFOREGROUND
# ExecReload=/usr/sbin/httpd $OPTIONS -k graceful
# # Send SIGWINCH for graceful stop
# KillSignal=SIGWINCH
# KillMode=mixed
# PrivateTmp=true
# OOMPolicy=continue
# 
# [Install]
# WantedBy=multi-user.target


```




3) Vérifier que le changement est pris en compte
```
systemctl cat httpd.service

# ==> Sortie
# /usr/lib/systemd/system/httpd.service
# See httpd.service(8) for more information on using the httpd service.

# Modifying this file in-place is not recommended, because changes
# will be overwritten during package upgrades.  To customize the
# behaviour, run "systemctl edit httpd" to create an override unit.

# For example, to pass additional options (such as -D definitions) to
# the httpd binary at startup, create an override unit (as is done by
# systemctl edit) and enter the following:

#       [Service]
#       Environment=OPTIONS=-DMY_DEFINE

[Unit]
Description=The Apache HTTP Server
Wants=httpd-init.service
After=network.target remote-fs.target nss-lookup.target httpd-init.service
Documentation=man:httpd.service(8)

[Service]
Type=notify
Environment=LANG=C

ExecStart=/usr/sbin/httpd $OPTIONS -DFOREGROUND
ExecReload=/usr/sbin/httpd $OPTIONS -k graceful
# Send SIGWINCH for graceful stop
KillSignal=SIGWINCH
KillMode=mixed
PrivateTmp=true
OOMPolicy=continue

[Install]
WantedBy=multi-user.target

# /etc/systemd/system/httpd.service.d/override.conf <=== La nouvelle configuration à bien été prise en compte ===
[Service]
Restart=always
RestartSec=5s

3) Redémarer le service
```
systemctl restart httpd
```


```
- Le fichier dans `/usr/lib/systemd/system` et `/etc/systemd/system` sont concaténé et lu en une seul fois pas systemd

`[REMARQUE]` 

- Avec cette méthode, le fichier `/etc/systemd/system` est prioritaire sur `/usr/lib/systemd/system` en cas de confit.

</details>

**=== Dépendences ===**

- lister les dépendence
```
systemctl list-dependencies
```

`systemctl list-dependencies` affiche l'arbre complet des dépendances d'une unit, en résolvant récursivement les dépendances de chaque dépendance.


















---

## 4.11 — Transfert sécurisé de fichiers — scp, sftp, rsync






