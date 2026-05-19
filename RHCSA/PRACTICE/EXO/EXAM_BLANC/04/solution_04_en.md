# ✅ Solution — RHCSA Mock Exam #04

---

## Task 01 — Users and /etc/skel

```bash
groupadd -g 7000 auditors
mkdir -p /audit/audit1 /audit/audit2

useradd -u 5001 -s /bin/bash -g auditors -d /audit/audit1 audit1
useradd -u 5002 -s /bin/bash -g auditors -d /audit/audit2 audit2
useradd -s /sbin/nologin -d /dev/null readonly

echo 'Aud!t2026' | passwd --stdin audit1
echo 'Aud!t2026' | passwd --stdin audit2

# /etc/skel
echo "alias ll='ls -alh'" >> /etc/skel/.bashrc
mkdir -p /etc/skel/scripts

# Homes already created, copy manually
cp /etc/skel/.bashrc /audit/audit1/
mkdir -p /audit/audit1/scripts
chown -R audit1:auditors /audit/audit1
chown -R audit2:auditors /audit/audit2

# Verification
ls -la /audit/audit1/
cat /audit/audit1/.bashrc
```

---

## Task 02 — Sudo Restrictions

```bash
# audit1: only /usr/sbin/*
visudo -f /etc/sudoers.d/audit1
```
```
audit1 ALL=(ALL) NOPASSWD: /usr/sbin/
```

```bash
# audit2: journalctl + ausearch only
visudo -f /etc/sudoers.d/audit2
```
```
audit2 ALL=(ALL) NOPASSWD: /usr/bin/journalctl, /usr/bin/ausearch
audit2 ALL=(ALL) !su, !/usr/bin/sudo
```

```bash
visudo -c -f /etc/sudoers.d/audit1
visudo -c -f /etc/sudoers.d/audit2
sudo -l -U audit1
sudo -l -U audit2
```

---

## Task 03 — find Edge Cases

```bash
# 1. Files with execute bit for others in /etc/
find /etc -perm -o+x -type f 2>/dev/null

# 2. Files in /home/ not accessed in +30 days
find /home -atime +30 -type f 2>/dev/null

# 3. .log files >5M in /var/log/ with readable size
find /var/log -name "*.log" -size +5M -ls 2>/dev/null
# -ls displays: inode size perms links user group size date name

# 4. Files with space in name in /tmp/
find /tmp -name "* *" -type f

# 5. Files belonging to audit1 OR audit2
find / \( -user audit1 -o -user audit2 \) 2>/dev/null
```

---

## Task 04 — Combined Text Processing

```bash
# 1. Top 10 CPU
ps -eo pid,%cpu,comm --sort=-%cpu | head -11 | awk '{print $1, $2}' > /tmp/top_cpu.txt

# 2. Remove comments and blank lines with sed
sed -e '/^#/d' -e '/^$/d' /etc/passwd > /tmp/passwd_clean.txt

# 3. Count users with valid shell
grep -v '/sbin/nologin\|/bin/false' /etc/passwd | wc -l

# 4. Hostname in uppercase with tr
cat /etc/hostname | tr '[:lower:]' '[:upper:]'
```

---

## Task 05 — LVM pvmove

```bash
pvcreate /dev/sdb
vgcreate vg_thin /dev/sdb
lvcreate -L 6G -n lv_main vg_thin
mkfs.xfs /dev/vg_thin/lv_main
mkdir -p /mnt/main
mount /dev/vg_thin/lv_main /mnt/main
echo 'test data' > /mnt/main/testfile

# Add /dev/sdc to VG
pvcreate /dev/sdc
vgextend vg_thin /dev/sdc

# Move PE from sdb to sdc
pvmove /dev/sdb /dev/sdc
# (operation may take time, data remains accessible)

# Remove sdb from VG
vgreduce vg_thin /dev/sdb

# Verification
df -hT /mnt/main
cat /mnt/main/testfile
pvs
vgs
```

---

## Task 06 — Labels

```bash
# ext4 partition with label
parted /dev/sdd mklabel gpt
parted /dev/sdd mkpart primary ext4 1MiB 3073MiB
parted /dev/sdd mkpart primary xfs 3073MiB 6145MiB
partprobe /dev/sdd

mkfs.ext4 -L DATAPART /dev/sdd1
mkfs.xfs -L XFSPART /dev/sdd2

mkdir -p /mnt/datapart /mnt/xfspart

cat >> /etc/fstab << 'EOF'
LABEL=DATAPART /mnt/datapart ext4 defaults 0 0
LABEL=XFSPART  /mnt/xfspart  xfs  defaults 0 0
EOF

mount -a
blkid | grep -E 'DATAPART|XFSPART'
lsblk -f /dev/sdd
```

---

## Task 07 — SELinux vsftpd port 2121

```bash
dnf install -y vsftpd
mkdir -p /srv/ftp/data
echo 'FTP TEST' > /srv/ftp/data/test.txt

# Port 2121 in vsftpd.conf
echo 'listen_port=2121' >> /etc/vsftpd/vsftpd.conf

# SELinux: ftp port
semanage port -a -t ftp_port_t -p tcp 2121

# Context on /srv/ftp/data/
semanage fcontext -a -t public_content_t "/srv/ftp/data(/.*)?" 
restorecon -Rv /srv/ftp/data/

# Boolean: ftp home dirs
setsebool -P ftp_home_dir on

# Firewall
firewall-cmd --add-port=2121/tcp --permanent
firewall-cmd --reload

systemctl enable --now vsftpd
curl ftp://localhost:2121
```

---

## Task 08 — Watchdog Service

```bash
cat > /usr/local/bin/watchdog_check.sh << 'EOF'
#!/bin/bash
if [ ! -f /var/run/app.pid ]; then
    echo "$(date) - ALERT: /var/run/app.pid missing" >> /var/log/watchdog.log
fi
EOF
chmod +x /usr/local/bin/watchdog_check.sh

echo 'enabled=yes' > /etc/watchdog.conf

cat > /etc/systemd/system/watchdog.service << 'EOF'
[Unit]
Description=Watchdog Service
ConditionPathExists=/etc/watchdog.conf

[Service]
Type=simple
ExecStart=/bin/bash -c 'while true; do /usr/local/bin/watchdog_check.sh; sleep 30; done'
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now watchdog.service
systemctl status watchdog.service
```

---

## Task 09 — Rsyslog + logrotate

```bash
# Rsyslog: crit+
cat > /etc/rsyslog.d/critical.conf << 'EOF'
*.crit /var/log/critical.log
EOF
systemctl restart rsyslog

# Logrotate
cat > /etc/logrotate.d/critical << 'EOF'
/var/log/critical.log {
    daily
    rotate 7
    compress
    missingok
    notifempty
    postrotate
        systemctl kill -s HUP rsyslog.service
    endscript
}
EOF

# Test rotation
logrotate -f /etc/logrotate.d/critical

# Generate test message
logger -p kern.crit "CRITICAL TEST"
cat /var/log/critical.log
```

---

## Task 10 — sysreport Script

```bash
cat > /usr/local/bin/sysreport.sh << 'EOF'
#!/bin/bash
REPORT="/tmp/sysreport_$(date +%Y%m%d).txt"
ALL_OK=0

{
echo "=== SYSTEM REPORT ==="
echo "Hostname : $(hostname)"
echo "Date     : $(date)"
echo ""
echo "=== DISK USAGE ==="
df -hT
echo ""
echo "=== TOP 5 MEMORY ==="
ps -eo pid,pmem,comm --sort=-pmem | head -6
echo ""
echo "=== LOGGED-IN USERS ==="
who | wc -l
echo ""
echo "=== SERVICE STATUS ==="
for svc in sshd firewalld chronyd; do
    STATUS=$(systemctl is-active $svc)
    echo "$svc : $STATUS"
    [ "$STATUS" != "active" ] && ALL_OK=1
done
} > "$REPORT"

cat "$REPORT"
exit $ALL_OK
EOF
chmod +x /usr/local/bin/sysreport.sh
/usr/local/bin/sysreport.sh
echo "Return code: $?"
```

---

## Task 11 — Processes and loginctl

```bash
# 1. Active sessions
loginctl list-sessions

# 2. Top memory
ps -eo pid,pmem,comm --sort=-pmem | head -5

# 3. Renice sshd
PID_SSHD=$(pgrep -o sshd)
renice -n -5 -p $PID_SSHD
ps -o pid,ni,comm -p $PID_SSHD

# 4. Terminate audit2 session
loginctl terminate-user audit2

# 5. Verification
loginctl list-users
```

---

## Task 12 — Chrony

```bash
# 1. Tracking
chronyc tracking

# 2. Add NTP server
echo 'server 0.fr.pool.ntp.org iburst' >> /etc/chrony.conf
systemctl restart chronyd

# 3. Force sync
chronyc makestep

# 4. Timezone
timedatectl set-timezone Europe/Paris

# 5. Verification
timedatectl status
chronyc sources
```

---

## Task 13 — Flatpak Permissions

```bash
# 1. Version
flatpak --version

# 2. System Flathub remote
flatpak remote-add --system --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# 3. Search text editor
flatpak search "text editor"

# 4. Permissions of an installed app
flatpak list
flatpak info --show-permissions org.gnome.gedit 2>/dev/null || echo 'Not installed'

# 5. Documentation
cat > /tmp/flatpak_perms.txt << 'EOF'
To restrict network access of a Flatpak app:
flatpak override --nofilesystem=host <APP_ID>
flatpak override --no-share=network <APP_ID>

Example:
flatpak override --no-share=network org.gnome.gedit

To see applied overrides:
flatpak override --show <APP_ID>
EOF
```

---

## Task 14 — Firewalld Zones

```bash
# 1. Default zone
firewall-cmd --get-default-zone
firewall-cmd --get-zones

# Main interface
INTERFACE=$(ip route | awk '/default/ {print $5}' | head -1)

# 2. Main interface -> trusted
firewall-cmd --permanent --zone=trusted --add-interface=$INTERFACE

# 3. public zone: SSH + HTTPS only
firewall-cmd --permanent --zone=public --remove-service=dhcpv6-client
firewall-cmd --permanent --zone=public --add-service=ssh
firewall-cmd --permanent --zone=public --add-service=https

# 4. trusted zone: all traffic
firewall-cmd --permanent --zone=trusted --set-target=ACCEPT

# 5. Persistent
firewall-cmd --reload
firewall-cmd --get-active-zones
firewall-cmd --zone=public --list-all
```

---

## Task 15 — Advanced RPM

```bash
# 1. Python packages
rpm -qa | grep '^python'

# 2. Name + version with custom format
rpm -qa --qf "%{NAME} %{VERSION}\n" | grep '^python'

# 3. Package providing python3
rpm -qf /usr/bin/python3

# 4. Post-install scripts
rpm -q --scripts python3-libs

# 5. Full inventory
rpm -qa --qf "%{NAME} %{VERSION} %{ARCH}\n" | sort > /tmp/pkg_inventory.txt
wc -l /tmp/pkg_inventory.txt
```

---

## Task 16 — SUID + Links

```bash
# 1. SUID binaries
find /usr/bin /usr/sbin -perm -4000 -type f 2>/dev/null

# 2. SUID risk
cat > /tmp/suid_risk.txt << 'EOF'
SUID risk on a custom binary:
A binary with SUID runs with the privileges of its owner (often root).
If the binary contains a vulnerability (injection, buffer overflow, PATH hijacking),
an attacker can achieve privilege escalation to root.
Rule: only enable SUID on well-tested system binaries (passwd, sudo).
EOF

# 3. Symbolic link
ln -s /usr/bin/ls /usr/local/bin/ll
ls -la /usr/local/bin/ll

# 4. Hard link
ln /etc/hosts /tmp/hosts_backup

# 5. Verify same inode
ls -li /etc/hosts /tmp/hosts_backup
```

---

## Task 17 — Combined Scheduling

```bash
# 1. at in 10 minutes
echo 'rpm -Va > /tmp/rpm_verify.txt' | at now +10 minutes
atq

# 2. System cron in /etc/cron.d/
cat > /etc/cron.d/sync_job << 'EOF'
*/5 * * * * root /usr/bin/sync
EOF
chmod 644 /etc/cron.d/sync_job

# 3 + 4. rpm_check timer
cat > /etc/systemd/system/rpm_check.service << 'EOF'
[Unit]
Description=RPM Integrity Check

[Service]
Type=oneshot
ExecStart=/bin/bash -c 'rpm -Va >> /var/log/rpm_check.log 2>&1'
EOF

cat > /etc/systemd/system/rpm_check.timer << 'EOF'
[Unit]
Description=Weekly RPM check Sunday 01:00

[Timer]
OnCalendar=Sun *-*-* 01:00:00
Persistent=true

[Install]
WantedBy=timers.target
EOF

systemctl daemon-reload
systemctl enable --now rpm_check.timer
systemctl list-timers | grep rpm
```

---

## Task 18 — NFS soft/hard Options

```bash
dnf install -y nfs-utils
mkdir -p /srv/nfs/soft /srv/nfs/hard

cat >> /etc/exports << 'EOF'
/srv/nfs/soft *(rw,no_root_squash)
/srv/nfs/hard *(rw,no_root_squash)
EOF

systemctl enable --now nfs-server
exportfs -rv

mkdir -p /mnt/nfs_soft /mnt/nfs_hard

cat >> /etc/fstab << 'EOF'
localhost:/srv/nfs/soft /mnt/nfs_soft nfs4 soft,timeo=30,_netdev 0 0
localhost:/srv/nfs/hard /mnt/nfs_hard nfs4 hard,intr,_netdev 0 0
EOF

mount -a

cat > /tmp/nfs_options.txt << 'EOF'
soft: if the NFS server does not respond within the timeout (timeo=30 tenths of a second),
      the operation fails immediately with an I/O error.
      Use case: reading non-critical data, avoids hangs.

hard: the client retries indefinitely until the server responds.
      intr: allows interruption with Ctrl+C.
      Use case: critical data, do not risk corruption.
EOF
```

---

## Task 19 — autofs Direct + Timeout

```bash
dnf install -y autofs

# Direct map with timeout
cat >> /etc/auto.master << 'EOF'
/- /etc/auto.direct --timeout=120
EOF

mkdir -p /mnt/direct_hard
echo '/mnt/direct_hard -rw,hard,intr localhost:/srv/nfs/hard' > /etc/auto.direct

systemctl enable --now autofs

# Test
ls /mnt/direct_hard
mount | grep autofs

# Logs
journalctl -u autofs -f
```

---

## Task 20 — Complete Recovery

```bash
# Full procedure documentation
cat > /tmp/full_recovery.txt << 'EOF'
COMPLETE ROOT PASSWORD RESET + SELinux PROCEDURE:

1. At GRUB menu, select the kernel, press 'e'
2. On the 'linux' line: append 'rd.break enforcing=0' at the end
3. Ctrl+X to boot
4. switch_root:/# mount -o remount,rw /sysroot
5. switch_root:/# chroot /sysroot
6. sh-5.2# passwd root
7. sh-5.2# touch /.autorelabel
   => MANDATORY: the chroot modified /etc/shadow without updating its SELinux context.
   => Without autorelabel, SELinux will deny access to the shadow file on next boot.
8. sh-5.2# exit
9. switch_root:/# exit  => reboot
EOF

# grubby: add enforcing=0 temporarily
grubby --update-kernel=DEFAULT --args="enforcing=0"
grubby --info=DEFAULT | grep args

# After reboot, restore enforcing=1
grubby --update-kernel=DEFAULT --remove-args="enforcing=0"

# Verification
getenforce
sestatus | head -5
```

---

*RHCSA EX200 Mock Exam — RHEL 10 — 2026*
