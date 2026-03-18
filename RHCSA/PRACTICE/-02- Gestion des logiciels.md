# -02- Gestion des logiciels

---

- Ici sera exposé dans l'odre du document [README.md](https://github.com/NALSED/CERTIF/blob/main/RHCSA/README.md), section -02- Gestion des logiciels.

---

### **=== Définitions ===**

1️⃣ `RPM` :

- RPM Package Manager (RPM) est un `système`, bas niveau, qui exécute sur Red Hat Enterprise Linux, et permet `d'installer des binaires`, via une `archive compressé`.
- Il contient les métadata (stoquées dans `/var/lib/rpm`) du paquet, ainsi que les dépendences et est identifié avec `.rpm` 
- RPM est utilisé pour :
   - Inspecter un .rpm sans l'installer
   - Vérifier l'intégrité d'un paquet installé (Taille, checksum MD5, timestamp changés)
   - Interroger la base RPM (paquets installés)
   - Installer un .rpm local isolé (sans dépôt)
   - Forcer une opération (usage avancé/debug)


2️⃣ `Flatpak`

---

## **2.1** — Configurer l'accès aux dépôts RPM 

`2.1.1.` **===  Commandes ===**
# Commandes RPM — RHCSA

## Interroger un paquet installé

```bash
rpm -qa                        # lister tous les paquets installés
rpm -qi bash                   # infos détaillées (version, date, description)
rpm -ql bash                   # fichiers installés par le paquet
rpm -qc bash                   # fichiers de configuration uniquement
rpm -qd bash                   # fichiers de documentation uniquement
rpm -q --scripts bash          # scripts pre/post install
rpm -q --requires bash         # dépendances requises
rpm -q --provides bash         # ce que le paquet fournit
```

## Interroger un fichier

```bash
rpm -qf /usr/bin/bash          # quel paquet a installé ce fichier
```

## Interroger un `.rpm` local (pas encore installé)

```bash
rpm -qip monpaquet.rpm         # infos du paquet local
rpm -qlp monpaquet.rpm         # fichiers qu'il va installer
```

> Le `p` = "package file" (fichier local, pas installé)

## Installer / Mettre à jour / Supprimer

```bash
rpm -ivh monpaquet.rpm         # installer (i=install, v=verbose, h=progress)
rpm -Uvh monpaquet.rpm         # upgrade (installe si absent, met à jour si présent)
rpm -Fvh monpaquet.rpm         # freshen (met à jour seulement si déjà installé)
rpm -e monpaquet               # désinstaller
rpm -e --nodeps monpaquet      # désinstaller sans vérifier les dépendances
```

## Vérifier l'intégrité

```bash
rpm -V bash                    # vérifier les fichiers d'un paquet installé
rpm -Va                        # vérifier tous les paquets
rpm --checksig monpaquet.rpm   # vérifier la signature GPG
```

Codes de sortie de `-V` :

```
S = taille    5 = checksum    T = timestamp
M = permissions   U = user    G = groupe
```

## Filtrer / chercher

```bash
rpm -qa | grep http                        # chercher un paquet par nom
rpm -qa --qf "%{NAME} %{VERSION}\n"        # format personnalisé
```

## Mémo des options principales

| Option | Signification |
|--------|---------------|
| `-q`   | query         |
| `-i`   | info (avec `-q`) ou install |
| `-l`   | list files    |
| `-f`   | file (quel paquet) |
| `-p`   | package local |
| `-v`   | verbose       |
| `-h`   | hash (barre de progression) |
| `-V`   | verify        |
| `-e`   | erase         |

---

> **Priorité RHCSA** : maîtriser `-qa`, `-qf`, `-qi`, `-ql`, `-ivh`, `-e`, et `-V`.

`2.1.2.` Exemples 
Pour pouvoir travailler sur un exemple concret liste de dépot [RPM](https://dl.fedoraproject.org/pub/fedora/linux/development/44/Everything/source/tree/Packages/)

Utiliser wget pour télécharger un .rpm 

<img width="1096" height="306" alt="image" src="https://github.com/user-attachments/assets/776a6a27-3ce7-4ac6-8a2d-10aa6fd6523d" />




















---

## **2.2** — Installer et supprimer des paquets RPM 

---

## **2.3** — Configurer l'accès aux dépôts Flatpak 


---

## **2.4** — Installer et supprimer des applications Flatpak 
