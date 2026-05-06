# -10-  Gérer la sécurité

# **10.1** — Pare-feu firewalld 

`[INTRO]`

`firewalld` est l'outil de gestion, **nftables** est le backend sous-jacent.
 
nftables gère :

- Le filtrage des paquets

- La traduction d'adresses réseau (NAT)

- La redirection de ports
 








---
---

# **10.2** — Permissions par défaut des fichiers — `umask`, `chmod`  

---
---

# **10.3** — Authentification SSH par clé — `ssh-keygen`, `ssh-copy-id`, `authorized_keys`  

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

