# Création du lab Kubernetes sur proxmox

---

### `Hardware`
    
  - 'CPU' : Intel(R) Core(TM) i7 CPU 920  @ 2.67GH
  - 'RAM' : 16 Gb DDR3 
  - Network : Filaire : 192.168.2.2
  - IP : https://172.20.10.10:8006

[NOTE]

-1- Pour la connection au hotspot (iPhone), et partage de connection, desactiver successivement hotspot -> partage -> ethernet, puis réactiver.

-2- Config (8/06/26) :

- WIFI : 172.20.10.4
- Ethernet : 192.168.2.1/32 (Utilisation de DHCP avec une adresse manuelle)

-3- Configuration Network de Proxmox
```
auto lo
iface lo inet loopback

iface nic0 inet manual

auto vmbr0 
iface vmbr0 inet static
        address 192.168.2.2/24
        gateway 192.168.2.1
        bridge-ports nic0
        bridge-stp off
        bridge-fd 0


source /etc/network/interfaces.d/*
```


```
                                        WAN
                                         │
┌────────────────────────────────────────┴────┐
│   iPhone (hotspot)                          │
│   172.20.10.1/28                            │
└───────────┬─────────────────────────────────┘
            │ WiFi
            │
┌───────────┴──────────┐
│   MacBook            │
│   WiFi : 172.20.10.x │
│   ETH  : 192.168.2.1 │
└───────────┬──────────┘
            │ câble RJ45
┌───────────┴──────────────────────────────────┐
│   Proxmox                                    │
│   nic0  : 192.168.2.2                        │
│   vmbr0 ──── k8s-master  (192.168.2.5)       │
│         ──── k8s-worker1 (192.168.2.6)       │
│         ──── k8s-worker2 (192.168.2.7)       │
└──────────────────────────────────────────────┘
```

### `VM`

3 vm Ubuntu 26.04 

`-1-` k8s-master 192.168.2.5
sednal

`-2-` k8s-worker1 192.168.2.6

`-3-` k8s-worker2 192.168.2.7

```
┌─────────────┬───────┬───────┬────────┐
│ Nom         │ vCPU  │ RAM   │ Disque │
├─────────────┼───────┼───────┼────────┤
│ k8s-master  │ 2     │ 4 Go  │ 20 Go  │
│ k8s-worker1 │ 2     │ 4 Go  │ 15 Go  │
│ k8s-worker2 │ 2     │ 4 Go  │ 15 Go  │
└─────────────┴───────┴───────┴────────┘
```
