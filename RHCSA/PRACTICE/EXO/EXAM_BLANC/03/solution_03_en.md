# ✅ Solution — RHCSA Mock Exam #03

---

## Task 01 — System Users and Environment

```bash
groupadd -g 6000 webadmin
groupadd -g 6001 dba

useradd -u 4001 -s /bin/bash -G webadmin,dba tom
useradd -u 4002 -s /bin/bash -G webadmin sara
useradd -r -s /sbin/nologin -d /var/lib/batch batch
mkdir -p /var/lib/batch
chown batch:batch /var/lib/batch

echo 'T0mPwd#' | passwd --stdin tom
echo 'T0mPwd#' | passwd --stdin sara

# tom's primary group = dba (new files will belong to dba by default)
usermod -g dba tom

# Verification
id tom
```

> 💡 `usermod -g dba tom` changes the **primary group** — all new files will belong to `dba`.

---

## Task 02 — Secured SSH

```bash
# SELinux + firewalld for port 2200
semanage port -a -t ssh_port_t -p tcp 2200
firewall-cmd --add-port=2200/tcp --permanent
firewall-cmd --reload

# sshd configuration
vim /etc/ssh/sshd_config
```
Lines to modify:
```
Port 22
Port 2200
PermitRootLogin no
AllowUsers tom sara
PasswordAuthentication no
PubkeyAuthentication yes
```

```bash
systemctl restart sshd
ss -tlnp | grep 2200

# Key for sara
sudo -u sara ssh-keygen -t ed25519 -N '' -f /home/sara/.ssh/id_ed25519
cat /home/sara/.ssh/id_ed25519.pub >> /home/sara/.ssh/authorized_keys
chmod 700 /home/sara/.ssh
chmod 600 /home/sara/.ssh/authorized_keys
chown -R sara:sara /home/sara/.ssh

# Test
ssh -p 2200 -i /home/sara/.ssh/id_ed25519 sara@localhost
```

---

## Task 03 — find: Search and Processing

```bash
# 1. Files with no owner
find / -nouser 2>/dev/null > /tmp/orphans.txt

# 2. .conf files in /etc/ modified in last 48h
find /etc -name "*.conf" -mtime -2 -type f

# 3. 5 largest files in /var/
find /var -type f -printf "%s\t%p\n" 2>/dev/null | sort -rn | head -5

# 4. Copy executables from /usr/local/bin/ to /tmp/local_bins/
mkdir -p /tmp/local_bins
find /usr/local/bin -type f -executable -exec cp {} /tmp/local_bins/ \;

# 5. Files with SGID
find / -perm -2000 -type f 2>/dev/null > /tmp/sgid_files.txt
```

---

## Task 04 — Archiving

```bash
mkdir -p /backup /tmp/restore

# 1. Full archive of /etc/
tar --selinux -cJf /backup/etc_full.tar.xz /etc/

# 2. Explanation: .tar.xz does not support --append because xz is a stream compression format.
# The entire archive must be decompressed before appending, making it unsupported.
# Solution: create a new archive
dnf install -y httpd
tar --selinux -cJf /backup/etc_httpd.tar.xz /etc/ /etc/httpd/

# 3. Integrity test
tar -tJf /backup/etc_full.tar.xz > /dev/null && echo 'Archive OK'

# 4. Extract httpd.conf
tar -xJf /backup/etc_full.tar.xz -C /tmp/restore/ etc/httpd/conf/httpd.conf

# 5. Compare
diff /tmp/restore/etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf
```

---

## Task 05 — LVM Reduction (ext4)

```bash
pvcreate /dev/sdb
vgcreate vg_test /dev/sdb
lvcreate -L 2G -n lv_a vg_test
lvcreate -L 2G -n lv_b vg_test

mkfs.ext4 /dev/vg_test/lv_a
mkfs.ext4 /dev/vg_test/lv_b

mkdir -p /mnt/lva /mnt/lvb

UUID_A=$(blkid -s UUID -o value /dev/vg_test/lv_a)
UUID_B=$(blkid -s UUID -o value /dev/vg_test/lv_b)
echo "UUID=$UUID_A /mnt/lva ext4 defaults 0 0" >> /etc/fstab
echo "UUID=$UUID_B /mnt/lvb ext4 defaults 0 0" >> /etc/fstab
mount -a

dd if=/dev/urandom of=/mnt/lva/bigfile bs=1M count=100

# Reduce lv_a to 1G
umount /mnt/lva
e2fsck -f /dev/vg_test/lv_a
resize2fs /dev/vg_test/lv_a 1G
lvreduce -L 1G /dev/vg_test/lv_a
mount /mnt/lva
ls -lh /mnt/lva/bigfile
df -hT /mnt/lva
```

> ⚠️ XFS does not support reduction — always use ext4 for LVs you plan to shrink.

---

## Task 06 — NFS Loopback

```bash
dnf install -y nfs-utils
mkdir -p /srv/share/ro /srv/share/rw
echo 'read only test' > /srv/share/ro/test.txt

cat >> /etc/exports << 'EOF'
/srv/share/ro *(ro,no_root_squash)
/srv/share/rw *(rw,no_root_squash)
EOF

systemctl enable --now nfs-server
exportfs -rv

for svc in nfs mountd rpc-bind; do
  firewall-cmd --add-service=$svc --permanent
done
firewall-cmd --reload

mkdir -p /mnt/nfs_ro /mnt/nfs_rw

cat >> /etc/fstab << 'EOF'
localhost:/srv/share/ro /mnt/nfs_ro nfs4 ro,_netdev 0 0
localhost:/srv/share/rw /mnt/nfs_rw nfs4 rw,_netdev 0 0
EOF

mount -a
df -hT | grep nfs

# Test read-only
touch /mnt/nfs_ro/test 2>&1   # => permission denied
touch /mnt/nfs_rw/test        # => OK
```

---

## Task 07 — SELinux nginx

```bash
dnf install -y nginx
mkdir -p /data/nginx/html
echo 'NGINX OK' > /data/nginx/html/index.html

sed -i 's|root.*html;|root /data/nginx/html;|' /etc/nginx/nginx.conf

# Test permissive
setenforce 0
systemctl start nginx
curl http://localhost   # => works
setenforce 1
curl http://localhost   # => fails (403 or connection refused)

# Diagnostic
ausearch -m avc -ts recent
sealert -a /var/log/audit/audit.log

# Fix
semanage fcontext -a -t httpd_sys_content_t "/data/nginx/html(/.*)?" 
restorecon -Rv /data/nginx/html/

systemctl restart nginx
curl http://localhost
```

---

## Task 08 — Complex systemd Units

```bash
cat > /usr/local/bin/monitor.sh << 'EOF'
#!/bin/bash
while true; do
  date >> /var/log/monitor.log
  sleep 5
done &
echo $! > /var/run/monitor.pid
EOF
chmod +x /usr/local/bin/monitor.sh

cat > /etc/systemd/system/monitor.service << 'EOF'
[Unit]
Description=Monitor Service

[Service]
Type=forking
PIDFile=/var/run/monitor.pid
ExecStart=/usr/local/bin/monitor.sh

[Install]
WantedBy=multi-user.target
EOF

cat > /etc/systemd/system/cleanup.service << 'EOF'
[Unit]
Description=Cleanup Service
After=monitor.service
Requires=monitor.service

[Service]
Type=oneshot
ExecStart=/usr/bin/find /tmp -type f -mtime +1 -delete
EOF

cat > /etc/systemd/system/cleanup.timer << 'EOF'
[Unit]
Description=Cleanup every hour

[Timer]
OnCalendar=hourly
Persistent=true

[Install]
WantedBy=timers.target
EOF

systemctl daemon-reload
systemctl enable --now monitor.service cleanup.timer
systemctl list-dependencies cleanup.service
```

---

## Task 09 — tmpfiles + journald

```bash
cat > /etc/tmpfiles.d/webapp.conf << 'EOF'
d /run/webapp 0755 tom tom 7d
f /run/webapp/status 0644 tom tom -
EOF
systemd-tmpfiles --create /etc/tmpfiles.d/webapp.conf

# Journald: size + retention
sed -i 's/#SystemMaxUse=/SystemMaxUse=200M/' /etc/systemd/journald.conf
sed -i 's/#MaxRetentionSec=/MaxRetentionSec=4weeks/' /etc/systemd/journald.conf
systemctl restart systemd-journald
journalctl --disk-usage
```

---

## Task 10 — batch_users Script

```bash
cat > /usr/local/bin/batch_users.sh << 'EOF'
#!/bin/bash
if [ $# -eq 0 ] || [ ! -f "$1" ]; then
    echo "Usage: $0 <file>"
    exit 2
fi

CREATED=0
SKIPPED=0

while IFS=: read -r username password group; do
    [ -z "$username" ] && continue
    getent group "$group" &>/dev/null || groupadd "$group"
    if id "$username" &>/dev/null; then
        echo "SKIP: $username already exists"
        ((SKIPPED++))
    else
        useradd -G "$group" "$username"
        echo "$password" | passwd --stdin "$username" &>/dev/null
        ((CREATED++))
    fi
done < "$1"

echo "$CREATED users created, $SKIPPED skipped"
[ $SKIPPED -gt 0 ] && exit 1 || exit 0
EOF
chmod +x /usr/local/bin/batch_users.sh

# Test
cat > /tmp/users_test.txt << 'EOF'
user_a:pass123:testgroup
user_b:pass123:testgroup
tom:pass123:dba
EOF
/usr/local/bin/batch_users.sh /tmp/users_test.txt
```

---

## Task 11 — grep and Regex

```bash
# 1. UID between 1000 and 9999
grep -E '^[^:]+:[^:]+:(1[0-9]{3}|[2-9][0-9]{3}):' /etc/passwd

# 2. Failed logins in /var/log/secure
grep -E 'Failed password|authentication failure' /var/log/secure 2>/dev/null

# 3. Count per user
grep 'Failed password' /var/log/secure 2>/dev/null | \
  awk '{print $(NF-5)}' | sort | uniq -c | sort -rn

# 4. TCP services ports 1-1024 in /etc/services
grep -E '^[^#].*\b([1-9][0-9]{0,2}|10[0-1][0-9]|102[0-4])/tcp' /etc/services

# 5. Security report
{
  echo '=== Failed Logins ==='
  grep -E 'Failed password' /var/log/secure 2>/dev/null
  echo '=== Count per user ==='
  grep 'Failed password' /var/log/secure 2>/dev/null | awk '{print $(NF-5)}' | sort | uniq -c | sort -rn
} > /tmp/security_report.txt
```

---

## Task 12 — Zombie Processes

```bash
# 1. Identify zombies
ps aux | awk '$8 == "Z" {print $0}'

# 2. Explanation
cat > /tmp/zombie_explain.txt << 'EOF'
A process becomes a zombie when it has finished but its parent has not called wait().
It keeps its entry in the process table. You cannot kill a zombie directly.
Solution: kill the parent process (SIGCHLD or SIGKILL) so init/systemd adopts and cleans the zombie.
EOF

# 3. Launch 3 sleep instances
sleep 3600 &
sleep 3600 &
sleep 3600 &
jobs

# 4. Kill all in one command
killall sleep

# 5. Verification
ps aux | grep sleep
jobs
```

---

## Task 13 — Custom Tuning

```bash
# 1. Active profile
tuned-adm active

# 2. Custom profile
mkdir -p /etc/tuned/rhcsa-custom
cat > /etc/tuned/rhcsa-custom/tuned.conf << 'EOF'
[main]
include=throughput-performance

[sysctl]
vm.swappiness=10
EOF

# 3. Apply
tuned-adm profile rhcsa-custom

# 4. Verify
sysctl vm.swappiness

# 5. Independent sysctl persistence
cat > /etc/sysctl.d/99-swappiness.conf << 'EOF'
vm.swappiness = 10
EOF
sysctl -p /etc/sysctl.d/99-swappiness.conf
```

---

## Task 14 — Advanced Firewalld

```bash
# 1. Default zone
firewall-cmd --get-default-zone
firewall-cmd --get-zones

# 2. SSH only from 192.168.0.0/24
firewall-cmd --permanent --add-rich-rule='rule family=ipv4 source address=192.168.0.0/24 service name=ssh accept'

# 3. Block 10.0.0.99
firewall-cmd --permanent --add-rich-rule='rule family=ipv4 source address=10.0.0.99 drop'

# 4. MySQL port in internal zone
firewall-cmd --permanent --zone=internal --add-port=3306/tcp

# 5. Reload + verification
firewall-cmd --reload
firewall-cmd --list-all
firewall-cmd --zone=internal --list-all
```

---

## Task 15 — RPM and DNF

```bash
# 1. Install + list files
dnf install -y httpd
rpm -ql httpd

# 2. Download without installing
mkdir -p /tmp/rpms
dnf download httpd --destdir /tmp/rpms/

# 3. Inspect RPM
RPM=$(ls /tmp/rpms/httpd*.rpm)
rpm -qip $RPM
rpm -qRp $RPM
rpm -q --scripts -p $RPM

# 4. Uninstall + reinstall from local RPM
dnf remove -y httpd
rpm -ivh $RPM

# 5. Verify integrity
rpm -V httpd
```

---

## Task 16 — Flatpak

```bash
# 1. Version
flatpak --version

# 2. System Flathub remote
flatpak remote-add --system --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# 3. List installed apps
flatpak list

# 4. LibreOffice details
flatpak search org.libreoffice.LibreOffice
flatpak remote-info flathub org.libreoffice.LibreOffice

# 5. Document
cat > /tmp/flatpak_commands.txt << 'EOF'
Install : flatpak install flathub org.libreoffice.LibreOffice
Remove  : flatpak uninstall org.libreoffice.LibreOffice
EOF
```

---

## Task 17 — Advanced Scheduling

```bash
# 1. at job tomorrow 08:00
echo 'uptime > /tmp/uptime_report.txt' | at 08:00 tomorrow

# 2. Cron for sara: Mondays 04:30
crontab -u sara -e
# Add: 30 4 * * 1 find /home/sara -name "*.tmp" -delete

# 3 + 4. log_rotate timer
cat > /etc/systemd/system/log_rotate.service << 'EOF'
[Unit]
Description=Force logrotate

[Service]
Type=oneshot
ExecStart=/usr/sbin/logrotate -f /etc/logrotate.conf
EOF

cat > /etc/systemd/system/log_rotate.timer << 'EOF'
[Unit]
Description=Monthly logrotate on 1st at 03:00

[Timer]
OnCalendar=*-*-01 03:00:00
Persistent=true

[Install]
WantedBy=timers.target
EOF

systemctl daemon-reload
systemctl enable --now log_rotate.timer
```

---

## Task 18 — Network DNS

```bash
hostnamectl set-hostname rhcsa-srv3.prod.local

cat >> /etc/hosts << 'EOF'
192.168.0.10 db.prod.local
192.168.0.11 app.prod.local
EOF

INTERFACE=$(nmcli -t -f NAME con show --active | head -1)
nmcli con mod "$INTERFACE" ipv4.dns "192.168.0.1,8.8.8.8"
nmcli con up "$INTERFACE"

nslookup db.prod.local
dig app.prod.local

cat > /tmp/dns_order.txt << 'EOF'
The file /etc/nsswitch.conf (Name Service Switch) defines the resolution order.
Line: hosts: files dns
- 'files' = /etc/hosts consulted first
- 'dns'   = DNS servers consulted next
EOF
```

---

## Task 19 — autofs indirect + direct

```bash
dnf install -y autofs

# Indirect map
mkdir -p /mnt/nfs
echo '/mnt/nfs /etc/auto.nfs' >> /etc/auto.master
cat > /etc/auto.nfs << 'EOF'
ro -ro localhost:/srv/share/ro
rw -rw localhost:/srv/share/rw
EOF

# Direct map
mkdir -p /direct/data
echo '/- /etc/auto.direct' >> /etc/auto.master
echo '/direct/data -rw localhost:/srv/share/rw' > /etc/auto.direct

systemctl enable --now autofs

# Test
ls /mnt/nfs/ro
ls /direct/data
mount | grep autofs
```

---

## Task 20 — GRUB and Recovery

```bash
# 1. GRUB timeout
sed -i 's/GRUB_TIMEOUT=.*/GRUB_TIMEOUT=5/' /etc/default/grub

# 2. Apply (check BIOS or EFI)
lsblk | grep boot
# If /boot => BIOS
grub2-mkconfig -o /boot/grub2/grub.cfg
# If /boot/efi => EFI
# grub2-mkconfig -o /boot/efi/EFI/redhat/grub.cfg

# 3. Add mem=2G
grubby --update-kernel=DEFAULT --args="mem=2G"
grubby --info=DEFAULT | grep args

# 4. Remove immediately
grubby --update-kernel=DEFAULT --remove-args="mem=2G"

# 5. Documentation
cat > /tmp/grub_recovery.txt << 'EOF'
rd.break:
  - Interrupts boot in the initramfs BEFORE pivot_root
  - /sysroot = system not yet mounted rw
  - Use case: reset root password (mount -o remount,rw /sysroot + chroot)

init=/bin/bash:
  - Replaces systemd with a bash shell as PID 1
  - Filesystem mounted ro, must remount rw
  - Less clean than rd.break, no systemd

systemd.unit=rescue.target:
  - Starts systemd but stops at rescue.target (single-user mode)
  - Minimal services, filesystems mounted
  - Cleaner, requires root password
EOF
```

---

*RHCSA EX200 Mock Exam — RHEL 10 — 2026*
