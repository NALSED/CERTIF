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

Les options pour `ps` sont très nombreuse, en voici quelque une :

`ps fax` => Donne une hiérarchie des processus parent - enfants
`ps -fU` => Permet de lister les processus pour un utilisateur précis
`ps -f --forest -C NOM DU PREOCESSUS` => Permet de d'affiche les infos sur un processus.
`ps L` => affiche les option / collones que ps peux afficher
`ps -o` => permet de chosir les option parmis celle listé par `ps L`, mais `ps -o` liste pour l'utilisateur, si on veux tout lister `ps -oe OPTION`



---
---

## 4.1 — Démarrer, redémarrer, éteindre systemctl reboot, poweroff, shutdown

---


## 4.2 — Démarrer dans différentes cibles — systemctl isolate multi-user.target

---

## 4.3 — Interrompre le démarrage pour accès root — GRUB → rd.break / init=/bin/bash

---

## 4.4 — Processus gourmands — top, htop, ps aux, kill, killall


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






