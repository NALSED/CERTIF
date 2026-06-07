# Création du lab Kubernetes sur proxmox

---

### `Hardware`
    
  - 'CPU' : Intel(R) Core(TM) i7 CPU 920  @ 2.67GH
  - 'RAM' : 16 Gb DDR3 
  - Network : - Partage de connection via iPhone SE, pour troubleshoot voir la [section de résolution](https://github.com/NALSED/TUTO/blob/main/PERSO/LINUX/troubleshoot_Proxmox_Wifi.md) du probléme lié à la wifi via partage de connection.
  - IP : https://172.20.10.10:8006


### `VM`

3 vm Ubuntu 26.04 

`-1-` k8s-master

`-2-` k8s-worker1

`-3-` k8s-worker2

```
┌─────────────┬───────┬───────┬────────┐
│ Nom         │ vCPU  │ RAM   │ Disque │
├─────────────┼───────┼───────┼────────┤
│ k8s-master  │ 2     │ 4 Go  │ 20 Go  │
│ k8s-worker1 │ 2     │ 4 Go  │ 15 Go  │
│ k8s-worker2 │ 2     │ 4 Go  │ 15 Go  │
└─────────────┴───────┴───────┴────────┘
```
