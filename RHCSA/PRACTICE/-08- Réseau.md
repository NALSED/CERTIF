
# -8- Gestion de base du réseau

`[INTRO]`

**Commande de bases**

=> `ip`

- Voir les configuration actuelles
````
# Address
ip a

# Interface
ip l

# Route
ip r

# Statistiques paquets
ip -s link
````

- Pour tester une configuration utiliser `ip` (configuration non percistante)
````
#Address 
ip addr add dev enp0s3 192.168.0.4/24

# Route
ip route add default via 192.168.0.2
````

---

=> `Résolution de nom de domaine et hostname`

- hostnamectl => voir option `hostnamctl --help`

- hostname inscri dans `/etc/hostname`

- résolution statique locale  `/etc/hosts` 

- DNS /etc/resolv.conf

- fichier de configuration qui définit l'ordre et les sources à consulter `/etc/nsswitch.conf` (Name Service Switch)





---

---

#  8.1 — Adresses IPv4 et IPv6 — nmcli, nmtui, /etc/NetworkManager/

---
---

# 8.2 — Résolution du nom d'hôte — hostnamectl, /etc/hosts, /etc/resolv.conf

---
---

# 8.3 — Services réseau au démarrage — nmcli con mod ... connection.autoconnect yes

---
---

# 8.4 — Pare-feu — firewall-cmd --permanent, firewall-cmd --reload
