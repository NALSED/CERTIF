# ✅ Solution — Examen Blanc RHCSA N°01

---

## Tâche 01 — Utilisateurs et groupes

```bash
groupadd -g 3100 ops
useradd -u 1900 -s /bin/bash -G ops anna
useradd -u 1901 -s /bin/bash -G ops leo
useradd -s /sbin/nologin ghost
usermod -L ghost

echo 'R3dHat!' | passwd --stdin anna
echo 'R3dHat!' | passwd --stdin leo

# Expiration : 45j max, avertissement 5j, désactivation 7j après expiration
chage -M 45 -W 5 -I 7 anna

# Vérification
chage -l anna
id anna
id leo
```

---

## Tâche 02 — Sudo granulaire

```bash
visudo -f /etc/sudoers.d/leo
```

Contenu du fichier :
```
leo ALL=(ALL) NOPASSWD: /usr/sbin/useradd, /usr/sbin/usermod, /usr/sbin/userdel, /usr/bin/passwd, !/usr/bin/passwd root
```

```bash
# Validation syntaxe
visudo -c -f /etc/sudoers.d/leo

# Test
sudo -l -U leo
```

---

## Tâche 03 — Permissions avancées

```bash
mkdir -p /data/ops
chown root:ops /data/ops
chmod 3770 /data/ops
# 3770 = sgid(2) + sticky(1) + rwx owner + rwx group + --- others

# Vérification
ls -ld /data/ops/
# Attendu : drwxrws--T. root ops

# umask persistant pour anna
echo 'umask 0027' >> /home/anna/.bashrc
# Vérification
su - anna -c 'umask'
```

---

## Tâche 04 — Commande find

```bash
# 1. Fichiers appartenant à anna
find / -user anna 2>/dev/null > /tmp/find_anna.txt

# 2. SUID dans /usr/bin/
find /usr/bin -perm -4000 -type f 2>/dev/null > /tmp/find_suid.txt

# 3. Fichiers modifiés dans les 72h dans /etc/ — nom seul
find /etc -mtime -3 -type f -printf "%f\n"
# -mtime -3 = moins de 3 jours (72h)

# 4. Fichiers > 10M dans /var/log/
find /var/log -size +10M -type f -printf "%s\t%p\n"

# 5. Répertoires vides sous /tmp/ — suppression
find /tmp -type d -empty -delete
```

> 💡 `-mtime -3` = modifié il y a moins de 3×24h | `-printf "%s\t%p\n"` = taille en octets + chemin | `-perm -4000` = SUID

---

## Tâche 05 — Archivage

```bash
mkdir -p /backup /tmp/restore

# Création archive gz avec contextes SELinux
tar --selinux -czf /backup/conf_backup.tar.gz /etc/ssh/ /etc/chrony.conf

# Vérifier le contenu
tar -tvf /backup/conf_backup.tar.gz

# Extraire uniquement sshd_config
tar -xf /backup/conf_backup.tar.gz -C /tmp/restore/ etc/ssh/sshd_config
ls /tmp/restore/etc/ssh/
```

---

## Tâche 06 — LVM complet

```bash
# Table GPT + partition 8 Gio
parted /dev/sdb mklabel gpt
parted /dev/sdb mkpart primary 1MiB 8193MiB
partprobe /dev/sdb

# LVM
pvcreate /dev/sdb1
vgcreate vg_prod /dev/sdb1
lvcreate -L 4G -n lv_data vg_prod

# Format + montage
mkfs.xfs /dev/vg_prod/lv_data
mkdir -p /mnt/data

# UUID dans fstab
UUID=$(blkid -s UUID -o value /dev/vg_prod/lv_data)
echo "UUID=$UUID /mnt/data xfs defaults 0 0" >> /etc/fstab

mount -a
df -hT /mnt/data
```

---

## Tâche 07 — Extension LVM à chaud

```bash
# Nouveau PV
pvcreate /dev/sdc
vgextend vg_prod /dev/sdc

# Étendre LV + resize FS en une commande (-r)
lvextend -r -L +2G /dev/vg_prod/lv_data

# Vérification
df -hT /mnt/data
lvs
```

> 💡 `-r` avec `lvextend` appelle automatiquement `xfs_growfs` pour XFS ou `resize2fs` pour ext4

---

## Tâche 08 — Swap

```bash
# 2ème partition sur sdb
parted /dev/sdb mkpart primary linux-swap 8193MiB 8705MiB
partprobe /dev/sdb

mkswap /dev/sdb2

UUID=$(blkid -s UUID -o value /dev/sdb2)
echo "UUID=$UUID none swap defaults 0 0" >> /etc/fstab

swapon -a
swapon --show
free -h
```

---

## Tâche 09 — SELinux : contexte fichier

```bash
dnf install -y httpd

mkdir -p /webroot
echo 'RHCSA OK' > /webroot/index.html

# Modifier DocumentRoot
sed -i 's|DocumentRoot "/var/www/html"|DocumentRoot "/webroot"|' /etc/httpd/conf/httpd.conf
sed -i 's|<Directory "/var/www/html">|<Directory "/webroot">|' /etc/httpd/conf/httpd.conf

# Contexte SELinux persistant
semanage fcontext -a -t httpd_sys_content_t "/webroot(/.*)?">
restorecon -Rv /webroot/

# Firewall
firewall-cmd --add-service=http --permanent
firewall-cmd --reload

# Service
systemctl enable --now httpd

# Test
curl http://localhost
```

---

## Tâche 10 — SELinux : port non standard

```bash
# Ajouter port 2222 dans SELinux
semanage port -a -t ssh_port_t -p tcp 2222

# Vérifier
semanage port -l | grep ssh

# Modifier sshd_config
echo 'Port 2222' >> /etc/ssh/sshd_config

# Firewall
firewall-cmd --add-port=2222/tcp --permanent
firewall-cmd --reload

# Redémarrer sshd
systemctl restart sshd

# Vérification
ss -tlnp | grep 2222
```

---

## Tâche 11 — SELinux : booléen

```bash
# Identifier le booléen
getsebool -a | grep httpd_can_network
# => httpd_can_network_connect --> off

# Activer de façon persistante
setsebool -P httpd_can_network_connect on

# Vérification
getsebool httpd_can_network_connect

# Documenter
echo 'setsebool -P httpd_can_network_connect on' > /tmp/selinux_bool.txt
```

---

## Tâche 12 — Systemd : service custom

```bash
# Script
cat > /usr/local/bin/hello.sh << 'EOF'
#!/bin/bash
echo "$(date) - hello service ran" >> /var/log/hello.log
EOF
chmod +x /usr/local/bin/hello.sh

# Unit file
cat > /etc/systemd/system/hello.service << 'EOF'
[Unit]
Description=Hello Logger Service
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/hello.sh
Restart=on-failure
RestartSec=10s

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now hello.service
systemctl status hello.service
cat /var/log/hello.log
```

---

## Tâche 13 — Systemd timer

```bash
# Service
cat > /etc/systemd/system/clean_tmp.service << 'EOF'
[Unit]
Description=Clean old /tmp files

[Service]
Type=oneshot
ExecStart=/usr/bin/find /tmp -type f -mtime +5 -delete
EOF

# Timer
cat > /etc/systemd/system/clean_tmp.timer << 'EOF'
[Unit]
Description=Run clean_tmp every 30 minutes

[Timer]
OnCalendar=*:0/30
Persistent=true

[Install]
WantedBy=timers.target
EOF

systemctl daemon-reload
systemctl enable --now clean_tmp.timer
systemctl list-timers | grep clean_tmp
```

---

## Tâche 14 — Systemd tmpfiles

```bash
cat > /etc/tmpfiles.d/myapp.conf << 'EOF'
d /run/myapp 0750 anna anna 10d
f /run/myapp/pid 0640 anna anna -
EOF

# Appliquer immédiatement
systemd-tmpfiles --create /etc/tmpfiles.d/myapp.conf

# Vérification
ls -la /run/myapp/
stat /run/myapp/
```

---

## Tâche 15 — Planification cron + at

```bash
# cron pour anna
crontab -u anna -e
# Ajouter :
# 45 23 * * * df -h >> /home/anna/disk.log

# Vérification
crontab -u anna -l

# at dans 2 heures
echo 'sync && echo done >> /tmp/at_done.txt' | at now +2 hours

# Lister les tâches at
atq
```

---

## Tâche 16 — Script shell

```bash
cat > /usr/local/bin/user_report.sh << 'EOF'
#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Usage: $0 <groupe>"
    exit 2
fi

GROUP=$1

if ! getent group "$GROUP" &>/dev/null; then
    echo "ERREUR: groupe non trouvé"
    exit 1
fi

MEMBERS=$(getent group "$GROUP" | awk -F: '{print $4}' | tr ',' ' ')

for user in $MEMBERS; do
    UID_VAL=$(id -u "$user" 2>/dev/null)
    HOME_VAL=$(getent passwd "$user" | cut -d: -f6)
    SHELL_VAL=$(getent passwd "$user" | cut -d: -f7)
    echo "$user | $UID_VAL | $HOME_VAL | $SHELL_VAL"
done

exit 0
EOF

chmod +x /usr/local/bin/user_report.sh

# Tests
/usr/local/bin/user_report.sh ops
/usr/local/bin/user_report.sh groupinexistant
echo $?
```

---

## Tâche 17 — Réseau statique

```bash
# Avec nmcli (adapter NOM_CONNEXION à votre interface)
nmcli con mod "enp0s3" ipv4.addresses 192.168.0.100/24
nmcli con mod "enp0s3" ipv4.gateway 192.168.0.1
nmcli con mod "enp0s3" ipv4.dns "1.1.1.1,8.8.8.8"
nmcli con mod "enp0s3" ipv4.method manual
nmcli con mod "enp0s3" connection.autoconnect yes
nmcli con up "enp0s3"

# Hostname
hostnamectl set-hostname rhcsa-node1.lab.local

# Vérifications
ip a
hostnamectl
ping -c 2 192.168.0.1
```

---

## Tâche 18 — NFS + autofs

```bash
dnf install -y nfs-utils autofs

# Créer et exporter le partage
mkdir -p /srv/nfs/share
echo '/srv/nfs/share *(rw,no_root_squash)' >> /etc/exports

systemctl enable --now nfs-server
exportfs -rv

# Firewall
for svc in nfs mountd rpc-bind; do
    firewall-cmd --add-service=$svc --permanent
done
firewall-cmd --reload

# autofs
mkdir -p /mnt/auto
echo '/mnt/auto /etc/auto.share' >> /etc/auto.master
echo 'share -rw localhost:/srv/nfs/share' > /etc/auto.share

systemctl enable --now autofs

# Test
ls /mnt/auto/share
```

---

## Tâche 19 — Flatpak

```bash
# Vérifier / installer flatpak
rpm -q flatpak || dnf install -y flatpak

# Ajouter remote Flathub en system
flatpak remote-add --system --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Lister les remotes
flatpak remotes

# Rechercher sans installer
flatpak search org.gnome.Calculator

# Documenter
cat > /tmp/flatpak_setup.txt << 'EOF'
flatpak remote-add --system --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak remotes
flatpak search org.gnome.Calculator
EOF
```

---

## Tâche 20 — GRUB / rd.break

```bash
# Documenter la procédure rd.break
cat > /tmp/rdbreak_procedure.txt << 'EOF'
Procédure reset mot de passe root via rd.break :
1. Au menu GRUB, sélectionner le kernel, appuyer sur 'e'
2. Sur la ligne commençant par 'linux', ajouter : rd.break enforcing=0
3. Ctrl+X pour booter
4. Au prompt switch_root : mount -o remount,rw /sysroot
5. chroot /sysroot
6. passwd root
7. touch /.autorelabel
8. exit
9. exit (reboot)
10. Après reboot : setenforce 1
EOF

# Ajouter argument 'quiet' de façon persistante
grubby --update-kernel=ALL --args="quiet"

# Vérification
grubby --info=DEFAULT
```

---

*Solution examen blanc RHCSA EX200 — RHEL 10 — 2026*
