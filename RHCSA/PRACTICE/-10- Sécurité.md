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

=> `Client configuration`


- Fichier de configuration client
````
$HOME/.shh/config
````

-Fichier de configuration global
````
/etc/ssh/ssh_config
````



---
---

# **10.4** — Modes SELinux — `setenforce`, `/etc/selinux/config`  

---
---

# **10.5** — Contextes SELinux — `ls -Z`, `ps -Z`, `id -Z`  

---
---

# **10.6** — Restaurer les contextes — `restorecon -Rv`, `semanage fcontext`  

---
---

# **10.7** — Labels de ports SELinux — `semanage port -l`, `semanage port -a`  

---
---

# **10.8** — Booléens SELinux — `getsebool -a`, `setsebool -P`  

