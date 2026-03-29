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

 - Definition des colones de la commande `ps aux`

| Colonne | Signification |
|---------|---------------|
| USER | propriétaire du processus |
| PID | identifiant unique |
| %CPU | usage CPU |
| %MEM | usage mémoire |
| VSZ | mémoire virtuelle (Ko) |
| RSS | mémoire physique réelle (Ko) |
| TTY | terminal de contrôle (`?` = daemon) |
| STAT | état du processus |
| START | heure de démarrage |
| TIME | temps CPU cumulé |
| COMMAND | commande lancée |



---
---

## 4.1 — Démarrer, redémarrer, éteindre systemctl reboot, poweroff, shutdown

---


## 4.2 — Démarrer dans différentes cibles — systemctl isolate multi-user.target

---

## 4.3 — Interrompre le démarrage pour accès root — GRUB → rd.break / init=/bin/bash

---

## 4.4 — Processus gourmands RAM et CPU — ps, free, top, kill, killall

`[NOTE]`
Linux placera le plus possible de fichier en mémoire cache, par sécurité un `swap`, au cas ou l'on manquerai de mémoire, le swap est créer à partir d'espace disque.

**=>** **ps** permet de lister les procéssus en cours d'éxecution sur la machine
Les options sont très nombreuse, en voici quelque une :

- `ps fax` => Donne une hiérarchie des processus parent - enfants

- `ps -fU` => Permet de lister les processus pour un utilisateur précis

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
 

 **=>** **kill** et **killall**

- `kill` — envoie un signal à un processus par son **PID**
- `killall` — envoie un signal à tous les processus par leur **nom**

```
kill 1234        # tue le PID 1234
killall nginx    # tue tous les processus nommés nginx
```

---
## 4.5 — Priorité des processus — nice, renice

---

## 4.6 — Profils de tuning — tuned-adm list, tuned-adm profile <nom>


----
## 4.7 — Journaux système — journalctl, journalctl -u, /var/log/


---
## 4.8 — Persistance des journaux — journald.conf → Storage=persistent


---

## 4.9 — Services réseau — systemctl start/stop/status/enable


---

## 4.10 — Transfert sécurisé de fichiers — scp, sftp, rsync






