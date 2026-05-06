
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

- `NetworkManager` est l'utilitaire de gestion de réseau sur RHEL, on peux l'administré de 2 maniéres:

   - `nmcli` : outil en ligne de commande pour gérer les connexions réseau, scriptable.
   
   - `nmtui` : interface texte interactive pour les mêmes opérations, sans mémoriser les commandes. 

- Les configurations sont stockées dans `/etc/NetworkManager`
- 
⚠️ Pour RHCSA utiliser nmtui, plus rapide ⚠️

---

**nmcli**

`nmcli` utilise l'autocomplétion, il est donc possible d'éditer une commande en utilisant l'autocomplétion, ce qui est trés pratique pour éviter les erreurs

- Pour les syntaxe et exemples :

`man nmcli`

`man nmcli-examples`

---

**nmtui**


Utilitaire interactif, suivre les instructions

---

Commande utile pour Toubleshooting
````
ping
# ping -c 4           4 pings puis arrêt
# ping6               IPv6
# ping6 ADDR%enp0s3   IPv6 lien local

ss
# ss -tulnp           ports en écoute (TCP/UDP, PID)
# ss -t state established  connexions actives

nslookup
# nslookup example.com        résolution DNS simple
# nslookup example.com 8.8.8.8  via un DNS spécifique

dig
# dig example.com              résolution DNS détaillée
# dig example.com MX           enregistrement MX
# dig @8.8.8.8 example.com     via un DNS spécifique

````


---
---

# 8.2 — Résolution du nom d'hôte — hostnamectl, /etc/hosts, /etc/resolv.conf

OK

---
---

# 8.3 — Services réseau au démarrage — nmcli con mod ... connection.autoconnect yes

---
---

# 8.4 — Pare-feu — firewall-cmd --permanent, firewall-cmd --reload
