# Déployer, configurer et gérer des systèmes

---
---


## 7.1 — Planification de tâches — at, cron, crontab -e, systemd timers

`[INTRO]`

| Outil | Persistance | Syntaxe | Usage typique | Logs | Rattrapage manqué |
|-------|-------------|---------|---------------|------|-------------------|
| **cron** / **anacron** | Permanente | `* * * * * cmd` / `/etc/anacrontab` | Tâches récurrentes (anacron : min. quotidien) | `/var/log/cron` / mail | ❌ cron / ✅ anacron |
| **systemd timer** | Permanente | Unit `.timer` + `.service` | Tâches système | `journalctl` | ✅ (`Persistent=true`) |
| **at** | One-shot | `at HH:MM` | Exécution différée unique | Mail | ❌ |

`[REMARQUE]`

- **cron** exécute des tâches à la minute près en supposant que la machine tourne en permanence 

- **anacron** garantit qu'une tâche s'exécute *au moins une fois par jour/semaine/mois*, même si la machine a été éteinte entre-temps.

**=== Systemd Timer ===**

- Permet d'effectuer des tâches planifiées 

- Requiert obligatoirement un fichier `.service` associé (même nom) — le `.timer` est le déclencheur, le `.service` contient la commande à exécuter.


- Pour voir les différentes options : `man systemd.timer`

- `Les plus courrantes`

| Option | Déclenchement |
|--------|---------------|
| `OnCalendar=` | Date/heure précise ou récurrente (`daily`, `*-*-* 02:00:00`) |
| `OnUnitActiveSec=` | X secondes après la dernière activation du service |
| `OnBootSec=` | X secondes après le démarrage du noyau |
| `OnStartupSec=` | X secondes après le démarrage de systemd |


`Syntaxe OnCalendar` => `man 7 systemd.time


**=== cron et anacron ===**


=> `cron`

`Syntaxe Cron` => `man 5 crontab

ou cat /etc/crontab 
```
SHELL=/bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin
MAILTO=root

# For details see man 4 crontabs

# Example of job definition:
# .---------------- minute (0 - 59)
# |  .------------- hour (0 - 23)
# |  |  .---------- day of month (1 - 31)
# |  |  |  .------- month (1 - 12) OR jan,feb,mar,apr ...
# |  |  |  |  .---- day of week (0 - 6) (Sunday=0 or 7) OR sun,mon,tue,wed,thu,fri,sat
# |  |  |  |  |
# *  *  *  *  * user-name  command to be executed

```

- La configuration de `cron` peux être géré via `/etc/crontab`, `/etc/cron.d/`, `/etc/cron.{hourly,daily,weekly,monthly}/`

=> `anacron`

`Syntaxe Anacron` => `man anacrontab

## anacron

- Édition : `vi /etc/anacrontab`
- Granularité : **jour minimum** (pas de minutes/heures)

- Syntaxe : `période  délai(min)  identifiant  commande`

   - période : en jours (1=quotidien, 7=hebdo, 30=mensuel) ou `@daily` / `@weekly` / `@monthly`
   - délai : minutes d'attente après le boot avant exécution
   - identifiant : nom unique de la tâche (pour les logs)
   - commande : script/commande à lancer

- Rôle par défaut : exécute `/etc/cron.{daily,weekly,monthly}` sur machines non 24/7
- `nice` : exécution basse priorité au boot


**=== at ===**

- Usage : exécution **one-shot** différée
- Prérequis : daemon `atd` actif (`systemctl enable --now atd`)
- Syntaxe : `at HH:MM`, `at now +1hour`, `at midnight`
- Saisie interactive de la commande, terminer avec `Ctrl+D`
- `atq` : lister les tâches en attente
- `atrm <id>` : supprimer une tâche
- Logs : mail à l'utilisateur
- Pas de rattrapage si machine éteinte


---

## 7.2 — Services au démarrage — systemctl enable --now, systemctl disable
OK

---

## 7.3 — Cible de démarrage par défaut — systemctl set-default

---

## 7.4 — Services de temps — chronyc, timedatectl, /etc/chrony.conf

---

## 7.5 — Gestion des paquetages — dnf install, dnf update, rpm -ivh
OK

---

## 7.6 — Chargeur de démarrage — grubby, /etc/default/grub, grub2-mkconfig

`[INTRO]`
```
┌─────────────────────────────────────────────────────────────┐
│                    SÉQUENCE DE DÉMARRAGE LINUX               │
└─────────────────────────────────────────────────────────────┘

┌──────────────────────┐
│       FIRMWARE       │  BIOS / UEFI
│   (POST + détection) │  => détecte le matériel, cherche un boot device
└──────────┬───────────┘
           │
           v
┌──────────────────────┐
│     BOOT DEVICE      │  Disque, USB, réseau...
│   (MBR / GPT + ESP)  │  => contient le bootloader
└──────────┬───────────┘
           │
           v
┌──────────────────────┐
│        GRUB          │  GRand Unified Bootloader
│  (bootloader stage2) │  => charge le kernel + initramfs en mémoire
└──────────┬───────────┘
           │
           v
┌──────────────────────┐
│  INITRAMFS + KERNEL  │  Système de fichiers temporaire en RAM
│  (early userspace)   │  => monte le vrai /, charge les modules
└──────────┬───────────┘
           │
           v
┌──────────────────────┐
│       SYSTEMD        │  PID 1 — init system
│    (target switch)   │  => prend le contrôle, lance les targets
└──────────┬───────────┘
           │
           v
┌──────────────────────┐
│    EARLY SERVICES    │  sysinit.target / basic.target
│  (base du système)   │  => udev, réseau bas niveau, montages
└──────────┬───────────┘
           │
           v
┌──────────────────────┐
│      SERVICES        │  multi-user.target / graphical.target
│   (stack complète)   │  => SSH, réseau, logging, cron, etc.
└──────────┬───────────┘
           │
           v
┌──────────────────────┐
│        SHELL         │  login prompt / getty / display manager
│   (session user)     │  => bash, zsh, ou GUI
└──────────────────────┘
```


- Poue éditer le `runtime-boot` de linux choisir `regular kernel`, appyer sur `e`



































---

## 7.7 — Interrompre le démarrage pour accès root — GRUB → rd.break / init=/bin/bash
