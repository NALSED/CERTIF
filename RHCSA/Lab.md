# 🖥️ RHCSA EX200 — Montage du Lab RHEL 10
> Guide de configuration de l'environnement de pratique  
> Compatible : AlmaLinux 10 / Rocky Linux 10 / RHEL 10

---

## 💿 Choix de la distribution

| Distribution | Compatibilité RHEL 10 | Licence | Téléchargement |
|-------------|----------------------|---------|----------------|
| **AlmaLinux 10** | 1:1 — clone binary | Open Source | `almalinux.org/get-almalinux` |
| **Rocky Linux 10** | 1:1 — clone binary | Open Source | `rockylinux.org/download` |
| **RHEL 10 Developer** | Officiel Red Hat | Gratuit (compte requis) | `developers.redhat.com` |

> ✅ **Recommandation** : AlmaLinux 10 ou Rocky Linux 10 pour le lab — comportement
> identique à RHEL 10, sans nécessiter de compte Red Hat ni de souscription.

---

## 🏗️ Architecture du lab recommandée

```
┌─────────────────────────────────────────────────┐
│                Machine hôte                     │
│                                                 │
│  ┌──────────────────┐   ┌──────────────────┐   │
│  │   VM1 — server   │   │   VM2 — client   │   │
│  │  (node1)         │   │  (node2)         │   │
│  │                  │   │                  │   │
│  │  RAM  : 2 Go     │   │  RAM  : 1 Go     │   │
│  │  CPU  : 2 vCPU   │   │  CPU  : 1 vCPU   │   │
│  │  HDD1 : 20 Go    │   │  HDD  : 10 Go    │   │
│  │  HDD2 : 10 Go    │   │                  │   │
│  │  HDD3 : 10 Go    │   │                  │   │
│  └──────────────────┘   └──────────────────┘   │
│                                                 │
│  Réseau : NAT + Host-Only (192.168.56.0/24)    │
└─────────────────────────────────────────────────┘
```

**Pourquoi 3 disques sur VM1 ?**  
Les exercices LVM, partitionnement GPT/MBR, Stratis et VDO nécessitent des disques
supplémentaires non partitionnés. Ajouter HDD2 et HDD3 vides après l'installation de l'OS.

---

## 🌐 Configuration réseau des VMs

Chaque VM doit disposer de **deux interfaces réseau** :

- **Interface 1 — NAT** : accès internet pour `dnf install` et téléchargements
- **Interface 2 — Host-Only** : réseau privé entre les VMs et l'hôte

Configuration recommandée :

```
VM1 (node1) :
  hostname : node1.lab.local
  IP fixe  : 192.168.56.11/24

VM2 (node2) :
  hostname : node2.lab.local
  IP fixe  : 192.168.56.12/24
```

Configurer avec `nmcli` après installation :
```bash
nmcli con mod eth1 ipv4.addresses 192.168.56.11/24 ipv4.method manual
nmcli con mod eth1 connection.autoconnect yes
nmcli con up eth1
```

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

## 🔗 Liens officiels RHEL 10

### Documentation Red Hat
- Objectifs examen EX200 : `redhat.com/en/services/training/ex200`
- Documentation RHEL 10 (FR) : `docs.redhat.com/fr/documentation/red_hat_enterprise_linux/10`
- Release Notes RHEL 10 : `docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/html/10.0_release_notes`
- Guide d'administration système RHEL 10 : `docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/html/managing_systems_using_the_rhel_system_roles`

### Documentation par domaine (RHEL 10)
- Stockage et LVM : `docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/html/managing_storage_devices`
- SELinux : `docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/html/using_selinux`
- Conteneurs Podman : `docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/html/building_running_and_managing_containers`
- Réseau NetworkManager : `docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/html/configuring_and_managing_networking`
- Firewalld : `docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/html/using_and_configuring_firewalld`

### ISOs compatibles
- AlmaLinux 10 : `almalinux.org/get-almalinux`
- Rocky Linux 10 : `rockylinux.org/download`
- RHEL 10 Developer : `developers.redhat.com/products/rhel/download`

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

## 🔄 Snapshots — Bonne pratique

Créer des **snapshots** réguliers pour revenir à un état propre sans réinstaller :

```
Snapshot 1 : "OS propre post-install"    → avant toute configuration
Snapshot 2 : "Lab configuré"             → après config réseau et paquets
Snapshot 3 : "Avant exercice LVM"        → avant chaque série d'exercices risqués
```

> 💡 Avec VirtualBox : `Machine → Prendre un instantané`  
> Avec KVM/virt-manager : `Snapshot → Créer`

:one

---

## 🎯 Rappels examen

- Les configurations doivent **survivre au reboot** — toujours tester avec `reboot`
- SELinux doit rester en mode **enforcing** — ne jamais le désactiver
- Utiliser `man`, `--help` et `/usr/share/doc` — aucune ressource externe autorisée
- Score minimum pour la certification : **210/300**
- Durée : **3 heures** sur 2 VMs fournies

---

*RHCSA EX200 — RHEL 10 — Lab Setup 2026*
