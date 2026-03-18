# 🖥️ RHCSA EX200 — Montage du Lab RHEL 10 (Création => 11/03/26) 

---

Télécharger [RHEL](https://developers.redhat.com/products/rhel/download#getredhatenterpriselinux7163)
---

## 🏗️ Architecture du lab
```
┌──────────────────────────────────────────────┐
│                Machine hôte                  │
│                                              │
│  ┌──────────────────┐   ┌─────────────────┐  │
│  │   VM1 — server   │   │   VM2 — client  │  │
│  │  (node1)         │   │  (node2)        │  │
│  │                  │   │                 │  │
│  │  RAM  : 10 Go    │   │  RAM  : 5 Go    │  │
│  │  CPU  : 4 vCPU   │   │  CPU  : 1 vCPU  │  │
│  │  HDD1 : 20 Go    │   │  HDD  : 10 Go   │  │
│  │  HDD2 : 10 Go    │   │                 │  │
│  │  HDD3 : 10 Go    │   │                 │  │
│  └──────────────────┘   └─────────────────┘  │
│                                              │
│  Réseau :  bridge                            │
│   - VM1 : 192.168.0.5                        │ 
│   - VM2 :                                    │
└──────────────────────────────────────────────┘
- Entrée dans pfsense des VM

<img width="1139" height="93" alt="image" src="https://github.com/user-attachments/assets/3587e07c-79e1-4709-9612-cd4bd7afbe3f" />


```
---

---

## 📦 Configuratin VMs

`[NOTE]`Il est préférable de passer en CLI pur. Si ce n’est pas le cas lors de l’installation, tapez :
````
systemctl set-default multi-user.target
````

````
sudo systemctl reboot

````
:warning: A suivre dans cet ordre jusqu'au point `-3.`

### `-1.` Enregistrer la vm

`-1.1.` Status
````
sudo subscription-manager status
````

`-1.2.` Si non enregistrer, impossible d'accéder a `dnf` source.
````
sudo subscription-manager register --username [USER NAME] --password [PASSWORD]
````

`-1.3.` Update
````
sudo dnf update -y
````
---

### `-2.` Paquet à Installer

`2.1.` VIM
````
sudo dnf install vim
````

### `-3.` Clone + Snap

`-3.1.` Après installation et enregistrement clonage, en cas du crash total de la Vm pas besoin de reinstaller RHEL 10

`-3.1.` Lancer le clone, et faire un Snap à chaque étape cruicial.

-Si probléme Rollback avec le Snap et si crash total, Clone.

`[NOTE]` Probléme possible avec l'enregistrement, si c'est le cas
````
subscription-manager unregister
````

-Puis se réenregistrer

---

### `-4.` Monter les repo dans /etc/fstab

⚠️ Cet partie n'interviens pas avant la section 2.2 de la liste de compétence ⚠️

````
# Copie l'iso
dd if=/dev/sr0 of=/rhel10.iso bs=1M

# Point de montage
sudo mkdir /repo

# Backup fstab 
sudo cp /etc/fstab /etc/fstab.bak

# Rendre le point de montage persistant
echo "/rhel10.iso /repo iso9660 defaults 0 0" >> /etc/fstab

# Vérifier
cat /etc/fstab

# Monter
mount -a
````

 
---

## 🎯 Rappels examen

- Les configurations doivent **survivre au reboot** — toujours tester avec `reboot`
- SELinux doit rester en mode **enforcing** — ne jamais le désactiver
- Utiliser `man`, `--help` et `/usr/share/doc` — aucune ressource externe autorisée
- Score minimum pour la certification : **210/300**
- Durée : **3 heures** sur 2 VMs fournies

---

*RHCSA EX200 — RHEL 10 — Lab Setup 2026*
