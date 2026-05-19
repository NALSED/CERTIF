# ✅ Solution — RHCSA Mock Exam #01

---

## Task 01 — Users and Groups

```bash
groupadd -g 3100 ops
useradd -u 1900 -s /bin/bash -G ops anna
useradd -u 1901 -s /bin/bash -G ops leo
useradd -s /sbin/nologin ghost
usermod -L ghost

echo 'R3dHat!' | passwd --stdin anna
echo 'R3dHat!' | passwd --stdin leo

# Expiration: 45 days max, warning 5 days, disable 7 days after expiration
chage -M 45 -W 5 -I 7 anna

# Verification
chage -l anna
id anna
id leo
```

---

## Task 02 — Granular Sudo

```bash
visudo -f /etc/sudoers.d/leo
```

File content:
```
leo ALL=(ALL) NOPASSWD: /usr/sbin/useradd, /usr/sbin/usermod, /usr/sbin/userdel, /usr/bin/passwd, !/usr/bin/passwd root
```

```bash
# Syntax validation
visudo -c -f /etc/sudoers.d/leo

# Test
sudo -l -U leo
```

---

## Task 03 — Advanced Permissions

```bash
mkdir -p /data/ops
chown root:ops /data/ops
chmod 3770 /data/ops
# 3770 = sgid(2) + sticky(1) + rwx owner + rwx group + --- others

# Verification
ls -ld /data/ops/
# Expected: drwxrws--T. root ops

# Persistent umask for anna
echo 'umask 0027' >> /home/anna/.bashrc
# Verification
su - anna -c 'umask'
```

---

## Task 04 — find Command

```bash
# 1. Files owned by anna
find / -user anna 2>/dev/null > /tmp/find_anna.txt

# 2. SUID in /usr/bin/
find /usr/bin -perm -4000 -type f 2>/dev/null > /tmp/find_suid.txt

# 3. Files modified in last 72h in /etc/ - filename only
find /etc -mtime -3 -type f -printf "%f\n"
# -mtime -3 = less than 3 days (72h)

# 4. Files > 10M in /var/log/
find /var/log -size +10M -type f -printf "%s\t%p\n"

# 5. Empty directories under /tmp/ - delete
find /tmp -type d -empty -delete
```

> 💡 `-mtime -3` = modified less than 3x24h ago | `-printf "%s\t%p\n"` = size in bytes + path | `-perm -4000` = SUID

---

## Task 05 — Archiving

```bash
mkdir -p /backup /tmp/restore

# Create gz archive with SELinux contexts
tar --selinux -czf /backup/conf_backup.tar.gz /etc/ssh/ /etc/chrony.conf

# Verify contents
tar -tvf /backup/conf_backup.tar.gz

# Extract only sshd_config
tar -xf /backup/conf_backup.tar.gz -C /tmp/restore/ etc/ssh/sshd_config
ls /tmp/restore/etc/ssh/
```

---

## Task 06 — Full LVM

```bash
# GPT table + 8 GiB partition
parted /dev/sdb mklabel gpt
parted /dev/sdb mkpart primary 1MiB 8193MiB
partprobe /dev/sdb

# LVM
pvcreate /dev/sdb1
vgcreate vg_prod /dev/sdb1
lvcreate -L 4G -n lv_data vg_prod

# Format + mount
mkfs.xfs /dev/vg_prod/lv_data
mkdir -p /mnt/data

# UUID in fstab
UUID=$(blkid -s UUID -o value /dev/vg_prod/lv_data)
echo "UUID=$UUID /mnt/data xfs defaults 0 0" >> /etc/fstab

mount -a
df -hT /mnt/data
```

---

## Task 07 — Live LVM Extension

```bash
# New PV
pvcreate /dev/sdc
vgextend vg_prod /dev/sdc

# Extend LV + resize FS in one command (-r)
lvextend -r -L +2G /dev/vg_prod/lv_data

# Verification
df -hT /mnt/data
lvs
```

> 💡 `-r` with `lvextend` automatically calls `xfs_growfs` for XFS or `resize2fs` for ext4

---

## Task 08 — Swap

```bash
# 2nd partition on sdb
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

## Task 09 — SELinux: File Context

```bash
dnf install -y httpd

mkdir -p /webroot
echo 'RHCSA OK' > /webroot/index.html

# Modify DocumentRoot
sed -i 's|DocumentRoot "/var/www/html"|DocumentRoot "/webroot"|' /etc/httpd/conf/httpd.conf
sed -i 's|<Directory "/var/www/html">|<Directory "/webroot">|' /etc/httpd/conf/httpd.conf

# Persistent SELinux context
semanage fcontext -a -t httpd_sys_content_t "/webroot(/.*)?" 
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

## Task 10 — SELinux: Non-Standard Port

```bash
# Add port 2222 in SELinux
semanage port -a -t ssh_port_t -p tcp 2222

# Verify
semanage port -l | grep ssh

# Modify sshd_config
echo 'Port 2222' >> /etc/ssh/sshd_config

# Firewall
firewall-cmd --add-port=2222/tcp --permanent
firewall-cmd --reload

# Restart sshd
systemctl restart sshd

# Verification
ss -tlnp | grep 2222
```

---

## Task 11 — SELinux: Boolean

```bash
# Identify the boolean
getsebool -a | grep httpd_can_network
# => httpd_can_network_connect --> off

# Enable persistently
setsebool -P httpd_can_network_connect on

# Verification
getsebool httpd_can_network_connect

# Document
echo 'setsebool -P httpd_can_network_connect on' > /tmp/selinux_bool.txt
```

---

## Task 12 — Systemd: Custom Service

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

## Task 13 — Systemd Timer

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

## Task 14 — Systemd tmpfiles

```bash
cat > /etc/tmpfiles.d/myapp.conf << 'EOF'
d /run/myapp 0750 anna anna 10d
f /run/myapp/pid 0640 anna anna -
EOF

# Apply immediately
systemd-tmpfiles --create /etc/tmpfiles.d/myapp.conf

# Verification
ls -la /run/myapp/
stat /run/myapp/
```

---

## Task 15 — cron + at Scheduling

```bash
# cron for anna
crontab -u anna -e
# Add:
# 45 23 * * * df -h >> /home/anna/disk.log

# Verification
crontab -u anna -l

# at in 2 hours
echo 'sync && echo done >> /tmp/at_done.txt' | at now +2 hours

# List at jobs
atq
```

---

## Task 16 — Shell Script

```bash
cat > /usr/local/bin/user_report.sh << 'EOF'
#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Usage: $0 <group>"
    exit 2
fi

GROUP=$1

if ! getent group "$GROUP" &>/dev/null; then
    echo "ERROR: group not found"
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
/usr/local/bin/user_report.sh nonexistentgroup
echo $?
```

---

## Task 17 — Static Network

```bash
# With nmcli (adapt NOM_CONNEXION to your interface)
nmcli con mod "enp0s3" ipv4.addresses 192.168.0.100/24
nmcli con mod "enp0s3" ipv4.gateway 192.168.0.1
nmcli con mod "enp0s3" ipv4.dns "1.1.1.1,8.8.8.8"
nmcli con mod "enp0s3" ipv4.method manual
nmcli con mod "enp0s3" connection.autoconnect yes
nmcli con up "enp0s3"

# Hostname
hostnamectl set-hostname rhcsa-node1.lab.local

# Verifications
ip a
hostnamectl
ping -c 2 192.168.0.1
```

---

## Task 18 — NFS + autofs

```bash
dnf install -y nfs-utils autofs

# Create and export the share
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

## Task 19 — Flatpak

```bash
# Check / install flatpak
rpm -q flatpak || dnf install -y flatpak

# Add Flathub remote in system mode
flatpak remote-add --system --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# List remotes
flatpak remotes

# Search without installing
flatpak search org.gnome.Calculator

# Document
cat > /tmp/flatpak_setup.txt << 'EOF'
flatpak remote-add --system --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak remotes
flatpak search org.gnome.Calculator
EOF
```

---

## Task 20 — GRUB / rd.break

```bash
# Document rd.break procedure
cat > /tmp/rdbreak_procedure.txt << 'EOF'
Root password reset procedure via rd.break:
1. At GRUB menu, select the kernel, press 'e'
2. On the line starting with 'linux', append: rd.break enforcing=0
3. Ctrl+X to boot
4. At switch_root prompt: mount -o remount,rw /sysroot
5. chroot /sysroot
6. passwd root
7. touch /.autorelabel
8. exit
9. exit (reboot)
10. After reboot: setenforce 1
EOF

# Add 'quiet' argument persistently
grubby --update-kernel=ALL --args="quiet"

# Verification
grubby --info=DEFAULT
```

---

*RHCSA EX200 Mock Exam — RHEL 10 — 2026*
