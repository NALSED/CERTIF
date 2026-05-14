# -10-  Gérer la sécurité

# **10.1** — Pare-feu firewalld 

`[INTRO]`

`firewalld` est l'outil de gestion, **nftables** est le backend sous-jacent.
 
nftables gère :

   - Le filtrage des paquets

   - La traduction d'adresses réseau (NAT)

   - La redirection de ports
 
- `firewalld` utilise différents composants pour administrer le parefeu; les principaux sont :

   - `Service` : ensemble prédéfini de ports/protocoles regroupés sous un nom logique, `man firewalld.service`

   - `Zone` :  définit le niveau de confiance accordé au trafic réseau. `man firewalld.zoneqq`
   
   - `Ports` : ouverture de port directement.

- Utiliser la commande `firewall-cmd --permanent`, comme commande de base

⚠️ Il sera principalment demandé l'application de services pour RHCSA ⚠️


---

**Commandes de bases**

````
# Affiche toutes les régles pour la zone active (dont Zone, Service et Ports)
firewall-cmd --list-all

# Affiche la liste tous les services prédéfinis disponibles dans firewalld.
firewall-cmd --get-services

# Ajout d'un service
firewall-cmd --add-service NAME + --permanent (si besoin)

# Recharger la configuration
firewall-cmd --reload
````

---
---

# **10.2** — Permissions par défaut des fichiers — `umask`, `chmod`  

ok

---
---

# **10.3** —  gestion SSH   

=> `Adminitration / Connection clées SSH`

- Générer la clé
````
ssh-keygen
````

- Copier la clé
````
ssh-copy-id IP ou NAME 
````

---

=> `SSH keyz en cache`

- Ici la passphrase de la clé SSH est mise en cache dans le shell et disponible pendant toute la session ou l'utilisateur est connecté.

⚠️ Hors scope mais plus proche du milieu professionel ⚠️

- Générer clées avec passphrase

- Alouer un espace dans le shell
````
ssh-agent /bin/bash
````

- Ajouter la passphrase
````
ssh-add PASSPHRASE
```` 

---

**CONFIGURATION**

=> `Client configuration`


- Fichier de configuration client
````
$HOME/.shh/config
````

-Fichier de configuration global
````
/etc/ssh/ssh_config
````

`[NOTE]`

- Pour lancer une application graphique sur un serveur distant :
   
   - `-X` -X11 forwarding non fiable (sandboxé)

   - `-Y` X11 forwarding de confiance (accés complet)

---

=> `Serveur Configuration`

- Fichier de configuration serveur
````
/etc/ssh/sshd_config
````

`[NOTE]`

**Principales Options**

- `Port` : Port d'écoute de SSH
- `PermitRootLogin` : Autoriser / Interdire connection via Root
- `PubkeyAuthentication` : Autoriser / Interdire connection via clé publique
- `PasswordAthentication` : Autoriser / Interdire connection via mot de passe
- `X11Forwarding` : Autoriser / Interdire la possiblilité de lancer un application graphique sur un client
- `AllowYsers` : Utilisateur autorisés à se connecter en SSH


⚠️ Si changement ⚠️ => `systemctl restart sshd`

---

`[RAPPEL]`

- `scp` copie de fichier en SSH => scp OPTION PATH USER@IP:PATH

- `rsync` copie/synchronise => rsync OPTION USER@IP:PATH 

**Principales Options**

- `-r` mode récursif
- `-l` synchronise les liens symboliques
- `-p` preserve les permissions
- `-n` test de synchronisation/copie
- `-a` archive mode (équivalent =>  -r -l -p -t -g -o -D)
- `-A` archive mode et ACL
- `-X` synchronisation SELinux

`[REMARQUE]`

Protocole `rsync` natif non chiffré, utilisation implicite de SSH avec syntaxe ci dessus. 
  
---
---

**SELinux**

`[INTRO]`

# SELinux — Security Enhanced Linux

# TESTP zzz

- `SELinux` est une couche de sécurité supplémentaire intégrée au kernel Linux, développée par la NSA.

- Les permissions Unix classiques (ugo/rwx) ne suffisent pas — SELinux ajoute un contrôle d'accès obligatoire (MAC).

- Chaque fichier, processus et port reçoit un **contexte** — SELinux autorise ou refuse les accès selon une politique.

- **Modes** — `enforcing` (actif et bloquant), `permissive` (actif mais log uniquement), `disabled` (désactivé).

````
+-----------------------------------------------------------+
|                        POLICY                             |
|         (ensemble de règles chargées au boot)             |
|                                                           |
|  +--------------+    RULES     +-----------------------+  |
|  |    SOURCE    |<------------>|       TARGET          |  |
|  |              |  autorise ?  |                       |  |
|  |   PROCESS    |              |  FILE / PORT / DIR    |  |
|  |              |              |                       |  |
|  | LABEL        |              | LABEL                 |  |
|  | user:role:   |              | user:role:            |  |
|  | type:level   |              | type:level            |  |
|  |              |              |                       |  |
|  | httpd_t      |              | httpd_sys_content_t   |  |
|  +--------------+              | http_port_t (80/443)  |  |
|                                +-----------------------+  |
|                                                           |
|  OK  : LABEL source + LABEL target + RULES = ACCES OK     |
|  NKO  : LABEL incorrect = ACCES REFUSE => /var/log/audit  |
+-----------------------------------------------------------+
````

- Chaque objets avec SELinux à un label de contexte de sécurité
````
user      :  role      :  type     :  level
system_u  :  system_r  :  httpd_t  :  s0
````

- **user** (`_u`) : identité SELinux de qui lance le processus — mappé depuis le user Linux (ex: `system_u`, `unconfined_u`)

- **role** (`_r`) :  filtre RBAC (Role-Based Access Control) — définit quels types/domaines sont accessibles (ex: `system_r`, `object_r`)

- **type** (`_t`) : le plus important — définit concrètement ce que le processus/fichier peut faire ou accéder (ex: `httpd_t`, `httpd_sys_content_t`)

- **level** (``) : niveau MLS/MCS (Multi-Level Security) — quasiment ignoré sur RHEL standard, toujours `s0`

`[NOTE]` Pour l'examen `RHCSA`, se concentrer sur le `type`

 ---


# **10.4.1** — Modes SELinux — `setenforce`, `/etc/selinux/config`  


- Pour voir le mode actuel  

````
# === commande ===
getenforce
````

- Changer entre `enforcing` et `permissive`
````
setenforce  enforcing / permissive
reboot

# === Par defaut ===
vim /etc/sysconfig/selinux
# Changer
SELINUX=enforcing

# === boot ===
# ajouter au boot avec e
enforcing=0 => permissive mode
enforcing=1 => enforcing mode
selinux=0 => arret de SELinux
selinux=1 => activer SELinux
````


---

# **10.4.2** — Contextes SELinux — `ls -Z`, `ps -Z`, `id -Z`  
























---

# **10.4.3** — Restaurer les contextes — `restorecon -Rv`, `semanage fcontext`  


---

# **10.4.4** — Labels de ports SELinux — `semanage port -l`, `semanage port -a`  


---

# **10.4.5** — Booléens SELinux — `getsebool -a`, `setsebool -P`  

