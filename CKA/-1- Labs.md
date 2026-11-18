# Création du lab Kubernetes sur Proxmox


---
 
## 🇫🇷

### `Hardware`
    
  - 'CPU' : Intel(R) Core(TM) i7 CPU 920  @ 2.67 GHz
  - 'RAM' : 16 Go DDR3 
  - Network : Filaire : 192.168.2.2
  - IP : https://192.168.2.2:8006



### -1- Création des VM via `KVM` / `QEMU` / `libvirt`

[https://www.stephane-robert.info/docs/virtualiser/type1/kvm/](https://www.stephane-robert.info/docs/virtualiser/type1/kvm/)

`[NOTE]`

- A la fin de installation de `KVM` et `libvirt` la commande
````
virt-host-validate
````

- Fait apparaite des **FAIL** , il sont du à des problémes d'autorisation de `cgroups`.

- Pour fixer le probléme :
````
# Editer GRUB
sudo vim /etc/default/grub

# Editer
GRUB_CMDLINE_LINUX="rhgb quiet intel_iommu=on systemd.unified_cgroup_hierarchy=0"
````

- Reload la configuration
````
sudo grub-mkconfig -o /boot/grub/grub.cfg
````


### -2- Création des VM via `virt-manager`:



### `VM`

`[NOTE]`

- Edition des `IP`

````
sudo vim /etc/netplan/00-installer-config.yaml
````
````
network:
  version: 2
  ethernets:
    enp1s0:
      dhcp4: false
      addresses:
        - <CHANGER IP DU SERVER>
      routes:
        - to: default
          via: 192.168.122.1
      nameservers:
        addresses:
          - 192.168.122.1
          - 1.1.1.1
````
````
sudo netplan try
sudo netplan apply
ip -br a
````

###-3- vm Ubuntu 26.04 

`-1-` k8s-master 192.168.122.59

`-2-` k8s-worker1 192.168.122.58

`-3-` k8s-worker2 192.168.122.57

```
┌─────────────┬───────┬───────┬────────┐
│ Nom         │ vCPU  │ RAM   │ Disque │
├─────────────┼───────┼───────┼────────┤
│ master      │ 2     │ 3 Go  │ 20 Go  │
│ k8s-worker1 │ 2     │ 4 Go  │ 15 Go  │
│ k8s-worker2 │ 2     │ 4 Go  │ 15 Go  │
└─────────────┴───────┴───────┴────────┘
```

---
---

## 🇦🇲

### `Hardware`
    
  - 'CPU' : 13th Gen Intel(R) Core(TM) i7-13700KF
  - 'RAM' : 32 Go DDR5 
  - Network : Filaire : 192.168.0.242
  - IP : https://192.168.0.242:8006

### `VM`

3 vm Ubuntu-Server26

`-1-` k8s-master 192.168.0.5

`-2-` k8s-worker1 192.168.0.6

`-3-` k8s-worker2 192.168.0.7

```
┌─────────────┬───────┬───────┬────────┐
│ Nom         │ vCPU  │ RAM   │ Disque │
├─────────────┼───────┼───────┼────────┤
│ k8s-master  │ 6     │ 8 Go  │ 20 Go  │
│ k8s-worker1 │ 4     │ 6 Go  │ 15 Go  │
│ k8s-worker2 │ 4     │ 6 Go  │ 15 Go  │
└─────────────┴───────┴───────┴────────┘
```

### Snapshot
````
for id in 105 106 107; do qm shutdown $id; done
sleep 30
for id in 105 106 107; do qm snapshot $id pre-init --description "prereqs + binaires v1.36.4, avant kubeadm init"; done
````

- !!! Test !!!
````
Last login: Wed Sep  9 12:16:59 +04 2026 on pts/0
root@pve:~# qm listsnapshot 105
`-> pre-init                    2026-09-09 12:17:35     prereqs + binaires v1.36.4, avant kubeadm init
 `-> current                                            You are here!
root@pve:~# qm listsnapshot 106
`-> pre-init                    2026-09-09 12:17:36     prereqs + binaires v1.36.4, avant kubeadm init
 `-> current                                            You are here!
root@pve:~# qm listsnapshot 107
`-> pre-init                    2026-09-09 12:17:36     prereqs + binaires v1.36.4, avant kubeadm init
 `-> current                                            You are here!
````


### Restauration
````
qm rollback 105 pre-init
qm rollback 106 pre-init
qm rollback 107 pre-init
````


### Lister / supprimer
```
qm listsnapshot 105
qm delsnapshot 105 pre-init
```


