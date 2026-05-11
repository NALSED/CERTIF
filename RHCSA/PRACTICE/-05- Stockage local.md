# -5- Configurer le stockage local


# 5.1 — Partitions GPT / MBR — fdisk, gdisk, parted

`[NOTE]`

- Différences partition **MBR** et **GPT**

| | MBR | GPT |
|---|---|---|
| Année | Ancien (1983) | Moderne (années 2000) |
| Taille max disque | 2 To | 9,4 Zo (illimité en pratique) |
| Nombre de partitions | 4 primaires max | 128 partitions max |
| UEFI | ✗ | ✓ obligatoire |
| BIOS legacy | ✓ | ✓ (compatible) |

---
---

# 5.2 - LVM

---



# 5.2.1 — Volumes physiques LVM — pvcreate, pvremove, pvs


---

# 5.2.2 — Groupes de volumes — vgcreate, vgextend, vgs

---

# 5.2.3 — Volumes logiques — lvcreate, lvremove, lvs

---

# 5.2.4 — Montage au démarrage par UUID/label — /etc/fstab, blkid, lsblk -f

---
---

# 5.3 — Ajout non destructif de partitions, LV et swap — mkswap, swapon, swapoff
