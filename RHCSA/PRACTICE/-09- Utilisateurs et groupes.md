# **-9- Gérer des groupes et utilisateurs système**

---
---

- La liste complete des information utilisateur se trouve dans `/etc/passwd`

- les mot de passe dans `/etc/shadow`

- Le fichier de configuration de utilisateur `/etc/login.defs`

- Créer un un arborécence commune pour chaque user `/etc/skel`

## 9.1 — Comptes utilisateur — `useradd`, `usermod`, `userdel -r`

`useradd` : Ajouter un utilisateur
 
`usermod` : Modifier un utilisateur
 
 `userdel` : Supprimer un utilisateur
````
# Plus sur pour tout supprimer de l'utilisateur
userdel -rf 
````

---

## 9.2 — Mots de passe et validité — `passwd`, `chage`, `chage -l`

- `passwd` — définir ou modifier le mot de passe d'un utilisateur
- `chage` — gérer la politique d'expiration d'un mot de passe 
- `chage -l USER` — lister les informations d'expiration d'un compte


---

## 9.3 — Groupes — `groupadd`, `groupmod`, `groupdel`, `gpasswd -a`

- `groupadd` — créer un nouveau groupe
- `groupmod` — modifier un groupe existant (`-n` renommer, `-g` changer le GID)
- `groupdel` — supprimer un groupe
- `gpasswd -a` — ajouter un utilisateur à un groupe 


---


## 9.4 — Accès super-utilisateur — `/etc/sudoers`, `visudo`, `/etc/sudoers.d/`
















