# Utiliser des systèmes en cours d'exécution

---

 
Tout programme en cours d'exécution est un **processus**. Le kernel lui attribue un PID, de la mémoire, et des tranches de temps CPU via l'ordonnanceur (CFS).
 
Un processus naît par `fork()` depuis un parent, optionnellement suivi d'un `exec()` pour charger un nouveau programme. Il alterne entre espace user (son code) et espace kernel (ses appels système).
 
À tout moment il est dans un état : actif (`R`), en attente (`S`/`D`), stoppé (`T`), ou zombie (`Z`) s'il est terminé mais non récupéré par son parent.
 
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






