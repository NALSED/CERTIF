 # -10-  Gérer la sécurité

# **10.1** — Pare-feu firewalld 

`[INTRO]`

`firewalld` est l'outil de gestion, **nftables** est le backend.
 
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

`[NOTE]`

- `man` utile => `semanage-fcontext`

- Pour changer le label du context `SELinux`
````
# Nouveau
semanage fcontext -a

# Modification 
semanage fcontext -m

# === Appliquer les Mofifs ===
# Immédiatement
restorecon PATH

# Au bout (créer le fichier, au boot relabel et effacé automatiquement.)
touch /.autorelabel
````

### **⚠️ Pour conaitre le context pour un service ⚠️**

**-1-**
- Rechercher dans le document root du service (dossier de base depuis lequel le service sert ses fichiers.)

**-2-**

- Documentation 
````
# Rechercher le manuel selinux pour les installer
dnf search "selinux"

# Installer ce paquet
selinux-policy-doc.noarch : SELinux policy documentation
dnf install -y selinux-policy-doc.noarch : SELinux policy documentation

# rechercher dans man pour un service
man -k | grep httpd

# Trouver le page SERVICE_selinux
# ICI
httpd_selinux (8)

# On trouvera des exemple et syntaxe
````

**-3-**

- sealert

---

**Diagnostic Erreurs**

- Afin de tester une erreur voir =>  [Mise_en_Place_du_Probleme_`SELinux`](https://github.com/NALSED/CERTIF/blob/main/RHCSA/PRACTICE/EXO/SELINUX/CONTEXT/Probleme_Context.md)


**Diagnostique**
- Deux commandes sont utiles

   - `ausearch`

   - `sealert`

````
# Output brut, technique, peu lisible — mais immédiat et sans dépendance.
ausearch -m avc -ts recent

# Analyse tout le fichier audit, regroupe les alertes et les interprète.
sealert -a /var/log/audit/audit.log
````

- **Flux**
````
=== Identifier ===
ausearch -m avc -ts recent   => voir si un refus existe
sealert -a /var/log/audit/audit.log  => comprendre et obtenir la correction

=== Corriger ===
semanage -m ou -a
restorecon PATH
````

- Correction du [Probleme_`SELinux`](https://github.com/NALSED/CERTIF/blob/main/RHCSA/PRACTICE/EXO/SELINUX/CONTEXT/Fixer_Probleme.md)



---

# **10.4.3** — Labels de ports SELinux — `semanage port -l`, `semanage port -a`  

- Lister le port
````
semanage port -l
````

- Changer le port d'écoute dans `SELinux`
````
# Exemple avec ssh (Exemple présent dans fichier de configuration ssh)
semanage port -a -t ssh_port_t -p tcp 22
````

---

# **10.4.4** — Booléens SELinux — `getsebool -a`, `setsebool -P`  

=> Les booléens permettent d'`activer` ou `désactiver` des règles de politique sans avoir à réécrire ou recompiler la politique SELinux.


- Lister et voir `on / off`
````
# nom + deux états (actuel, persistant) + description
semanage boolean -l 

# juste le nom + état actuel.
getsebool -a
````

- Changer l'état
````
setsebool -P NOM BOOLEAN on / off
````

---

# **10.4.5** — Logs SELinux

`[NOTE]`

- SELinux utilise `auditd` pour écrir les message de log

- Les `logs` peuvent être utilisés de plusieurs maniéres

1) Avec journalctl + grep + UUID
````
#EXEMPLE
journalctl | grep sealert
# Sortie
May 18 10:00:54 rhcsaserver.example.com setroubleshoot[2871]: SELinux is preventing /usr/sbin/sshd from name_bind access on the tcp_socket port 2022. For complete SELinux messages run: sealert -l 4126e82e-d178-4d7b-bc23-6bdf5aa8b0fa

# Ici on peux utiliser
sealert -l 4126e82e-d178-4d7b-bc23-6bdf5aa8b0fa
# Sortie
SELinux is preventing /usr/sbin/sshd from name_bind access on the tcp_socket port 2022.

*****  Plugin bind_ports (92.2 confidence) suggests   ************************

If you want to allow /usr/sbin/sshd to bind to network port 2022
Then you need to modify the port type.
Do
# semanage port -a -t PORT_TYPE -p tcp 2022
    where PORT_TYPE is one of the following: ssh_port_t, vnc_port_t, xserver_port_t.

*****  Plugin catchall_boolean (7.83 confidence) suggests   ******************

If you want to allow nis to enabled
Then you must tell SELinux about this by enabling the 'nis_enabled' boolean.
You can read 'sshd_selinux' man page for more details.
Do
setsebool -P nis_enabled 1

*****  Plugin catchall (1.41 confidence) suggests   **************************

If you believe that sshd should be allowed name_bind access on the port 2022 tcp_socket by default.
Then you should report this as a bug.
You can generate a local policy module to allow this access.
Do
allow this access for now by executing:
# ausearch -c 'sshd' --raw | audit2allow -M my-sshd
# semodule -X 300 -i my-sshd.pp


Additional Information:
Source Context                system_u:system_r:sshd_t:s0-s0:c0.c1023
Target Context                system_u:object_r:unreserved_port_t:s0
Target Objects                port 2022 [ tcp_socket ]
Source                        sshd
Source Path                   /usr/sbin/sshd
Port                          2022
Host                          rhcsaserver.example.com
Source RPM Packages           openssh-server-9.9p1-11.el10.x86_64
Target RPM Packages
SELinux Policy RPM            selinux-policy-targeted-42.1.7-1.el10.noarch
Local Policy RPM              selinux-policy-targeted-42.1.7-1.el10.noarch
Selinux Enabled               True
Policy Type                   targeted
Enforcing Mode                Enforcing
Host Name                     rhcsaserver.example.com
Platform                      Linux rhcsaserver.example.com
                              6.12.0-124.8.1.el10_1.x86_64 #1 SMP
                              PREEMPT_DYNAMIC Fri Oct 17 13:03:58 EDT 2025
                              x86_64
Alert Count                   11
First Seen                    2026-05-18 09:57:23 +04
Last Seen                     2026-05-18 10:00:50 +04
Local ID                      4126e82e-d178-4d7b-bc23-6bdf5aa8b0fa

Raw Audit Messages
type=AVC msg=audit(1779084050.506:218): avc:  denied  { name_bind } for  pid=2869 comm="sshd" src=2022 scontext=system_u:system_r:sshd_t:s0-s0:c0.c1023 tcontext=system_u:object_r:unreserved_port_t:s0 tclass=tcp_socket permissive=0


type=SYSCALL msg=audit(1779084050.506:218): arch=x86_64 syscall=bind success=no exit=EACCES a0=7 a1=561cc5b4c0d0 a2=1c a3=561cbbb300ed items=0 ppid=1 pid=2869 auid=4294967295 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=(none) ses=4294967295 comm=sshd exe=/usr/sbin/sshd subj=system_u:system_r:sshd_t:s0-s0:c0.c1023 key=(null)

Hash: sshd,sshd_t,unreserved_port_t,tcp_socket,name_bind
````

2) sealert
````
# Listera sur toutes les erreurs relative à SELinux, avec la même syntaxe que ci-dessus.
sealert -a /var/log/audit/audit.log


````

**TROUBLESHOOTING**

