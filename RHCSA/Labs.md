# 🖥️ RHCSA EX200 — Montage du Lab RHEL 10

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

## 📦 Paquets à installer sur les VMs

Après installation minimale, ajouter les outils nécessaires aux exercices :

```bash
# Outils généraux
dnf install -y vim bash-completion man-pages wget curl

# Outils réseau
dnf install -y bind-utils net-tools nmap-ncat

# Outils stockage
dnf install -y lvm2 parted gdisk xfsprogs e2fsprogs stratisd stratis-cli

# Outils sécurité
dnf install -y policycoreutils-python-utils setroubleshoot-server firewalld

# Conteneurs
dnf install -y podman skopeo

# Outils système
dnf install -y tuned chrony
```

---

## ✅ Checklist de validation du lab

Avant de commencer les exercices, vérifier que l'environnement est opérationnel :

```bash
# SSH entre les deux VMs
ssh user@192.168.56.12

# Accès DNF (internet)
dnf list installed | head

# Disques supplémentaires visibles
lsblk

# SELinux actif
getenforce   # doit retourner "Enforcing"

# Firewalld actif
systemctl status firewalld

# Podman disponible
podman --version
```

---

## 🎯 Rappels examen

- Les configurations doivent **survivre au reboot** — toujours tester avec `reboot`
- SELinux doit rester en mode **enforcing** — ne jamais le désactiver
- Utiliser `man`, `--help` et `/usr/share/doc` — aucune ressource externe autorisée
- Score minimum pour la certification : **210/300**
- Durée : **3 heures** sur 2 VMs fournies

---

*RHCSA EX200 — RHEL 10 — Lab Setup 2026*
