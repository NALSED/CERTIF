# ✅ Solution — RHCSA Mock Exam #02

---

## Task 01 — Users, Groups and Password Policies

```bash
groupadd -g 5000 devteam

useradd -u 3001 -s /bin/bash -g devteam dev1
useradd -u 3002 -s /bin/bash -g devteam dev2
useradd -u 3003 -s /sbin/nologin -M -r svc_app

echo 'Dev@2026' | passwd --stdin dev1
echo 'Dev@2026' | passwd --stdin dev2

# Policy dev1: 60d max, 5d min, 10d warning
chage -M 60 -m 5 -W 10 dev1

# Expiration dev2 on 2026-12-31
chage -E 2026-12-31 dev2

# Verifications
chage -l dev1
chage -l dev2
id svc_app
```

---

## Task 02 — SSH Key-Based Access

```bash
# Generate key for dev1
sudo -u dev1 ssh-keygen -t ed25519 -C 'dev1@lab' -N '' -f /home/dev1/.ssh/id_ed25519

# Copy public key into authorized_keys
mkdir -p /home/dev1/.ssh
cat /home/dev1/.ssh/id_ed25519.pub >> /home/dev1/.ssh/authorized_keys

# Mandatory permissions
chmod 700 /home/dev1/.ssh
chmod 600 /home/dev1/.ssh/authorized_keys
chown -R dev1:dev1 /home/dev1/.ssh

# Test
ssh -i /home/dev1/.ssh/id_ed25519 dev1@localhost
```

---

## Task 03 — Permissions and ACLs

```bash
mkdir -p /projects/devteam
chown root:devteam /projects/devteam
chmod 2770 /projects/devteam

# Granular ACLs
setfacl -m u:dev1:rwx /projects/devteam
setfacl -m u:dev2:r-x /projects/devteam
setfacl -m u:svc_app:--- /projects/devteam

# Verification
getfacl /projects/devteam
```

---

## Task 04 — Advanced find

```bash
# 1. Files owned by group devteam
find / -group devteam 2>/dev/null > /tmp/devteam_files.txt

# 2. Symbolic links in /etc/ with their target
find /etc -type l -printf "%p -> %l\n"

# 3. Files in /var/log/ not modified in +30d AND >1M
find /var/log -mtime +30 -size +1M -type f

# 4. Files with EXACT permissions 644 in /home/
find /home -perm 644 -type f
# Note: -perm 644 = exactly 644 | -perm -644 = at least 644

# 5. chmod 600 on those files
find /home -perm 644 -type f -exec chmod 600 {} \;
```

---

## Task 05 — Redirections and Text Processing

```bash
# 1. Sorted by UID (field 3) descending
sort -t: -k3 -rn /etc/passwd > /tmp/passwd_sorted.txt

# 2. Users with shell /bin/bash
awk -F: '$7 == "/bin/bash" {print $1}' /etc/passwd

# 3. Replace bash -> sh in a copy
sed 's/bash/sh/g' /etc/passwd > /tmp/passwd_copy.txt

# 4. Count lines/words/characters
wc /etc/passwd > /tmp/passwd_stats.txt
cat /tmp/passwd_stats.txt
```

---

## Task 06 — Partitions and Swap

```bash
parted /dev/sdb mklabel gpt
parted /dev/sdb mkpart primary xfs 1MiB 3073MiB
parted /dev/sdb mkpart primary linux-swap 3073MiB 4097MiB
partprobe /dev/sdb

mkfs.xfs /dev/sdb1
mkswap /dev/sdb2

mkdir -p /mnt/part1

UUID1=$(blkid -s UUID -o value /dev/sdb1)
UUID2=$(blkid -s UUID -o value /dev/sdb2)

echo "UUID=$UUID1 /mnt/part1 xfs defaults 0 0" >> /etc/fstab
echo "UUID=$UUID2 none swap defaults 0 0" >> /etc/fstab

mount -a
swapon -a

df -hT /mnt/part1
swapon --show
```

---

## Task 07 — LVM + Snapshot

```bash
pvcreate /dev/sdc
vgcreate vg_dev /dev/sdc
lvcreate -L 3G -n lv_code vg_dev
mkfs.ext4 /dev/vg_dev/lv_code
mkdir -p /mnt/code
mount /dev/vg_dev/lv_code /mnt/code
echo 'VERSION 1' > /mnt/code/testfile.txt

# Snapshot
lvcreate -L 500M -s -n lv_code_snap /dev/vg_dev/lv_code

# Modify the file
echo 'VERSION 2' > /mnt/code/testfile.txt
cat /mnt/code/testfile.txt

# Restore via merge
umount /mnt/code
lvconvert --merge /dev/vg_dev/lv_code_snap
mount /dev/vg_dev/lv_code /mnt/code
cat /mnt/code/testfile.txt
# Must display: VERSION 1
```

---

## Task 08 — SELinux Full Diagnostic

```bash
dnf install -y httpd setroubleshoot-server
mkdir -p /opt/webapp
echo 'APP OK' > /opt/webapp/index.html

sed -i 's|DocumentRoot "/var/www/html"|DocumentRoot "/opt/webapp"|' /etc/httpd/conf/httpd.conf
sed -i 's|<Directory "/var/www/html">|<Directory "/opt/webapp">|' /etc/httpd/conf/httpd.conf

systemctl start httpd
# => Will fail or return 403 due to SELinux

# Diagnostic
ausearch -m avc -ts recent
sealert -a /var/log/audit/audit.log

# Fix
semanage fcontext -a -t httpd_sys_content_t "/opt/webapp(/.*)?" 
restorecon -Rv /opt/webapp/

systemctl restart httpd
curl http://localhost
```

---

## Task 09 — SELinux Boolean + Port 8080

```bash
# Boolean: httpd read home directories
setsebool -P httpd_enable_homedirs on

# Port 8080 in httpd.conf
sed -i 's/Listen 80/Listen 8080/' /etc/httpd/conf/httpd.conf

# SELinux port
semanage port -a -t http_port_t -p tcp 8080

# Firewall
firewall-cmd --add-port=8080/tcp --permanent
firewall-cmd --reload

systemctl restart httpd
curl http://localhost:8080
```

---

## Task 10 — Override sshd

```bash
systemctl edit sshd.service
# Content:
```

```ini
[Service]
Restart=on-failure
RestartSec=15s
StartLimitIntervalSec=60
StartLimitBurst=3
```

```bash
systemctl daemon-reload
systemctl restart sshd
systemctl cat sshd.service
```

---

## Task 11 — Journald Persistence + Filtering

```bash
# 1. Journald persistence
mkdir -p /var/log/journal
sed -i 's/#Storage=auto/Storage=persistent/' /etc/systemd/journald.conf
systemctl restart systemd-journald

# 2. Current boot logs for sshd
journalctl -b -u sshd

# 3. Logs err+ from last 2 hours
journalctl -p err --since "2 hours ago"

# 4. Rsyslog: authpriv warning+ to file
cat >> /etc/rsyslog.d/auth_warn.conf << 'EOF'
authpriv.warning /var/log/auth_warn.log
EOF
systemctl restart rsyslog
```

---

## Task 12 — Processes and Priority

```bash
# Launch dd with nice 10 in background
nice -n 10 dd if=/dev/zero of=/dev/null &

# PID and nice value
ps -eo pid,ni,comm | grep dd

# Renice to -5
renice -n -5 -p <PID>

# Verification
ps -o pid,ni,comm -p <PID>

# Kill cleanly
kill -15 <PID>
ps -p <PID> 2>/dev/null || echo 'process terminated'

# Tuned
tuned-adm profile throughput-performance
tuned-adm active
```

---

## Task 13 — Timer + anacron

```bash
# Service
cat > /etc/systemd/system/backup_home.service << 'EOF'
[Unit]
Description=Backup /home

[Service]
Type=oneshot
ExecStart=/bin/bash -c 'tar -czf /backup/home_$(date +%%Y%%m%%d).tar.gz /home/'
EOF

# Timer
cat > /etc/systemd/system/backup_home.timer << 'EOF'
[Unit]
Description=Daily backup home at 02:00

[Timer]
OnCalendar=*-*-* 02:00:00
Persistent=true

[Install]
WantedBy=timers.target
EOF

mkdir -p /backup
systemctl daemon-reload
systemctl enable --now backup_home.timer

# Anacron weekly
cat > /usr/local/bin/weekly_report.sh << 'EOF'
#!/bin/bash
echo "weekly report"
EOF
chmod +x /usr/local/bin/weekly_report.sh

echo '7  10  weekly_report  /usr/local/bin/weekly_report.sh' >> /etc/anacrontab
```

---

## Task 14 — disk_alert Script

```bash
cat > /usr/local/bin/disk_alert.sh << 'EOF'
#!/bin/bash
ALERT=0
while IFS= read -r line; do
    USE=$(echo "$line" | awk '{print $5}' | tr -d '%')
    MOUNT=$(echo "$line" | awk '{print $6}')
    if [[ "$USE" =~ ^[0-9]+$ ]] && [ "$USE" -gt 80 ]; then
        echo "ALERT: $MOUNT is at ${USE}%" >> /var/log/disk_alert.log
        ALERT=1
    fi
done < <(df -h | tail -n +2)

if [ $ALERT -eq 0 ]; then
    echo "OK - $(date)" >> /var/log/disk_alert.log
    exit 0
else
    exit 1
fi
EOF

chmod +x /usr/local/bin/disk_alert.sh

# Root cron: every hour
# Add to crontab -e:
# 0 * * * * /usr/local/bin/disk_alert.sh
```

---

## Task 15 — Dual Interface

```bash
nmcli con add type ethernet ifname enp0s8 con-name "static-enp0s8"
nmcli con mod "static-enp0s8" ipv4.addresses 10.0.0.10/24
nmcli con mod "static-enp0s8" ipv4.method manual
nmcli con mod "static-enp0s8" ipv4.dns 10.0.0.1
nmcli con mod "static-enp0s8" connection.autoconnect yes
nmcli con up "static-enp0s8"

echo '10.0.0.1 internal.lab.local' >> /etc/hosts

ip a show enp0s8
ping -c 2 internal.lab.local
```

---

## Task 16 — NFS Client

```bash
dnf install -y nfs-utils autofs
mkdir -p /srv/exports/data /srv/exports/homes

cat >> /etc/exports << 'EOF'
/srv/exports/data *(rw,no_root_squash)
/srv/exports/homes *(rw,no_root_squash)
EOF

systemctl enable --now nfs-server
exportfs -rv

for svc in nfs mountd rpc-bind; do
  firewall-cmd --add-service=$svc --permanent
done
firewall-cmd --reload

# Persistent NFS mount
mkdir -p /mnt/nfs_data
echo 'localhost:/srv/exports/data /mnt/nfs_data nfs4 _netdev,defaults 0 0' >> /etc/fstab
mount -a

# autofs homes
mkdir -p /mnt/homes
echo '/mnt/homes /etc/auto.homes' >> /etc/auto.master
echo '* -rw localhost:/srv/exports/homes/&' > /etc/auto.homes
systemctl enable --now autofs
```

---

## Task 17 — RPM and DNF

```bash
# 1. Package that installed /usr/bin/find
rpm -qf /usr/bin/find

# 2. Config files of that package
rpm -qc $(rpm -qf /usr/bin/find)

# 3. Integrity verification
rpm -V $(rpm -qf /usr/bin/find)

# 4. Package providing seinfo
dnf provides seinfo
# => setools-console

# 5. Install + list SELinux modules
dnf install -y setools-console
seinfo -t | head -20
```

---

## Task 18 — Advanced Flatpak

```bash
# User remote for dev1
sudo -u dev1 flatpak remote-add --user --if-not-exists flathub-user https://dl.flathub.org/repo/flathub.flatpakrepo

# List all remotes
flatpak remotes
sudo -u dev1 flatpak remotes

# Search Inkscape without installing
flatpak search org.inkscape.Inkscape

# Remove user remote
sudo -u dev1 flatpak remote-delete --user flathub-user

# Document difference
cat > /tmp/flatpak_diff.txt << 'EOF'
--system : remote installed for all users (requires root), stored in /var/lib/flatpak
--user   : remote installed only for the current user, stored in ~/.local/share/flatpak
EOF
```

---

## Task 19 — Hard and Symbolic Links

```bash
mkdir -p /data
echo 'ORIGINAL CONTENT' > /data/original.txt

# Hard link
ln /data/original.txt /data/hardlink.txt

# Symbolic link
ln -s /data/original.txt /data/symlink.txt

ls -li /data/

# Delete the original
rm /data/original.txt

# Observe
cat /data/hardlink.txt   # => works (same inode, data still present)
cat /data/symlink.txt    # => ERROR: dangling symlink

# Find files with same inode as hardlink
INODE=$(stat -c %i /data/hardlink.txt)
find / -inum $INODE 2>/dev/null

# Observations
cat > /tmp/links_obs.txt << 'EOF'
- Hard link: same inode, data accessible even after original is deleted
- Symbolic link: different inode, points to the path -> becomes dangling if original is deleted
- find -inum allows finding all hard links of the same file
EOF
```

---

## Task 20 — System Troubleshooting

```bash
# 1. Default boot target
systemctl set-default multi-user.target
systemctl get-default

# 2. Remove 'quiet' from kernel
grubby --update-kernel=ALL --remove-args="quiet"

# 3. Add systemd.log_level=debug temporarily
grubby --update-kernel=DEFAULT --args="systemd.log_level=debug"
# After testing, remove it:
grubby --update-kernel=DEFAULT --remove-args="systemd.log_level=debug"

# 4. Last boot journal lines
journalctl -b | tail -20

# 5. Mask a useless service
systemctl mask cups.service

cat > /tmp/mask_justif.txt << 'EOF'
Masked service: cups.service (print service)
Reason: server has no printer, service is unnecessary and exposes an unneeded attack surface.
systemctl mask creates a symlink to /dev/null, preventing any start.
EOF
```

---

*RHCSA EX200 Mock Exam — RHEL 10 — 2026*
