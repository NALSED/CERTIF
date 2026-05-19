# ✅ Solution — Examen Blanc RHCSA N°03

---

## Tâche 01 — Utilisateurs système et environnement

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

# Groupe principal de tom = dba (fichiers créés appartiennent à dba par défaut)
usermod -g dba tom
# Vérification
id tom
```

> 💡 `usermod -g dba tom` change le **groupe principal** — tous les nouveaux fichiers appartiendront à `dba`.

---

## Tâche 02 — SSH sécurisé

```bash
# SELinux + firewalld pour port 2200
semanage port -a -t ssh_port_t -p tcp 2200
firewall-cmd --add-port=2200/tcp --permanent
firewall-cmd --reload

# Configuration sshd
vim /etc/ssh/sshd_config
```
Lignes à modifier :
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

# Clé pour sara
sudo -u sara ssh-keygen -t ed25519 -N '' -f /home/sara/.ssh/id_ed25519
cat /home/sara/.ssh/id_ed25519.pub >> /home/sara/.ssh/authorized_keys
chmod 700 /home/sara/.ssh
chmod 600 /home/sara/.ssh/authorized_keys
chown -R sara:sara /home/sara/.ssh

# Test
ssh -p 2200 -i /home/sara/.ssh/id_ed25519 sara@localhost
```

---

## Tâche 03 — find : recherche et traitement

```bash
# 1. Fichiers sans propriétaire
find / -nouser 2>/dev/null > /tmp/orphans.txt

# 2. Fichiers .conf dans /etc/ modifiés dans les 48h
find /etc -name "*.conf" -mtime -2 -type f

# 3. 5 plus gros fichiers de /var/
find /var -type f -printf "%s\t%p\n" 2>/dev/null | sort -rn | head -5

# 4. Copier les exécutables de /usr/local/bin/ dans /tmp/local_bins/
mkdir -p /tmp/local_bins
find /usr/local/bin -type f -executable -exec cp {} /tmp/local_bins/ \;

# 5. Fichiers avec SGID
find / -perm -2000 -type f 2>/dev/null > /tmp/sgid_files.txt
```

---

## Tâche 04 — Archivage

```bash
mkdir -p /backup /tmp/restore

# 1. Archive complète de /etc/
tar --selinux -cJf /backup/etc_full.tar.xz /etc/

# 2. Explication : .tar.xz ne supporte pas --append car xz est un flux compressé
# Pour ajouter httpd, on crée une nouvelle archive
dnf install -y httpd
tar --selinux -cJf /backup/etc_httpd.tar.xz /etc/ /etc/httpd/

# 3. Test intégrité
tar -tJf /backup/etc_full.tar.xz > /dev/null && echo 'Archive OK'

# 4. Extraire httpd.conf
tar -xJf /backup/etc_full.tar.xz -C /tmp/restore/ etc/httpd/conf/httpd.conf

# 5. Comparer
diff /tmp/restore/etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf
```

---

## Tâche 05 — LVM réduction ext4

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

# Réduction lv_a à 1G
umount /mnt/lva
e2fsck -f /dev/vg_test/lv_a
resize2fs /dev/vg_test/lv_a 1G
lvreduce -L 1G /dev/vg_test/lv_a
mount /mnt/lva
ls -lh /mnt/lva/bigfile
df -hT /mnt/lva
```

> ⚠️ XFS ne supporte pas la réduction — toujours utiliser ext4 pour les LV qu'on prévoit de réduire.

---

## Tâche 06 — NFS loopback

```bash
dnf install -y nfs-utils
mkdir -p /srv/share/ro /srv/share/rw
echo 'lecture seule' > /srv/share/ro/test.txt

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

# Test lecture seule
touch /mnt/nfs_ro/test 2>&1   # => permission denied
touch /mnt/nfs_rw/test        # => OK
```

---

## Tâche 07 — SELinux nginx

```bash
dnf install -y nginx
mkdir -p /data/nginx/html
echo 'NGINX OK' > /data/nginx/html/index.html

sed -i 's|root.*html;|root /data/nginx/html;|' /etc/nginx/nginx.conf

# Test permissive
setenforce 0
systemctl start nginx
curl http://localhost   # => fonctionne
setenforce 1
curl http://localhost   # => échoue (403 ou connexion refusée)

# Diagnostic
ausearch -m avc -ts recent
sealert -a /var/log/audit/audit.log

# Correction
semanage fcontext -a -t httpd_sys_content_t "/data/nginx/html(/.*)?" 
restorecon -Rv /data/nginx/html/

systemctl restart nginx
curl http://localhost
```

---

## Tâche 08 — Units systemd complexes

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

## Tâche 09 — tmpfiles + journald

```bash
cat > /etc/tmpfiles.d/webapp.conf << 'EOF'
d /run/webapp 0755 tom tom 7d
f /run/webapp/status 0644 tom tom -
EOF
systemd-tmpfiles --create /etc/tmpfiles.d/webapp.conf

# Journald : taille + rétention
sed -i 's/#SystemMaxUse=/SystemMaxUse=200M/' /etc/systemd/journald.conf
sed -i 's/#MaxRetentionSec=/MaxRetentionSec=4weeks/' /etc/systemd/journald.conf
systemctl restart systemd-journald
journalctl --disk-usage
```

---

## Tâche 10 — Script batch_users

```bash
cat > /usr/local/bin/batch_users.sh << 'EOF'
#!/bin/bash
if [ $# -eq 0 ] || [ ! -f "$1" ]; then
    echo "Usage: $0 <fichier>"
    exit 2
fi

CREATED=0
SKIPPED=0

while IFS=: read -r username password group; do
    [ -z "$username" ] && continue
    getent group "$group" &>/dev/null || groupadd "$group"
    if id "$username" &>/dev/null; then
        echo "SKIP: $username existe déjà"
        ((SKIPPED++))
    else
        useradd -G "$group" "$username"
        echo "$password" | passwd --stdin "$username" &>/dev/null
        ((CREATED++))
    fi
done < "$1"

echo "$CREATED utilisateurs créés, $SKIPPED ignorés"
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

## Tâche 11 — Grep et regex

```bash
# 1. UID entre 1000 et 9999
grep -E '^[^:]+:[^:]+:(1[0-9]{3}|[2-9][0-9]{3}):' /etc/passwd

# 2. Connexions échouées dans /var/log/secure
grep -E 'Failed password|authentication failure' /var/log/secure 2>/dev/null

# 3. Compte par utilisateur
grep 'Failed password' /var/log/secure 2>/dev/null | \
  awk '{print $(NF-5)}' | sort | uniq -c | sort -rn

# 4. Services TCP ports 1-1024 dans /etc/services
grep -E '^[^#].*\b([1-9][0-9]{0,2}|10[0-1][0-9]|102[0-4])/tcp' /etc/services

# 5. Rapport sécurité
{
  echo '=== Connexions échouées ==='
  grep -E 'Failed password' /var/log/secure 2>/dev/null
  echo '=== Compte par user ==='
  grep 'Failed password' /var/log/secure 2>/dev/null | awk '{print $(NF-5)}' | sort | uniq -c | sort -rn
} > /tmp/security_report.txt
```

---

## Tâche 12 — Processus zombies

```bash
# 1. Identifier les zombies
ps aux | awk '$8 == "Z" {print $0}'

# 2. Explication
cat > /tmp/zombie_explain.txt << 'EOF'
Un processus devient zombie quand il est terminé mais que son parent n'a pas appelé wait().
Il conserve son entrée dans la table des processus. On ne peut pas tuer un zombie directement.
Solution : tuer le processus parent (SIGCHLD ou SIGKILL) pour que init/systemd adopte et nettoie le zombie.
EOF

# 3. Lancer 3 sleep
sleep 3600 &
sleep 3600 &
sleep 3600 &
jobs

# 4. Tuer tous en une commande
killall sleep

# 5. Vérification
ps aux | grep sleep
jobs
```

---

## Tâche 13 — Tuning personnalisé

```bash
# 1. Profil actif
tuned-adm active

# 2. Profil custom
mkdir -p /etc/tuned/rhcsa-custom
cat > /etc/tuned/rhcsa-custom/tuned.conf << 'EOF'
[main]
include=throughput-performance

[sysctl]
vm.swappiness=10
EOF

# 3. Appliquer
tuned-adm profile rhcsa-custom

# 4. Vérifier
sysctl vm.swappiness

# 5. Persistance sysctl indépendante
cat > /etc/sysctl.d/99-swappiness.conf << 'EOF'
vm.swappiness = 10
EOF
sysctl -p /etc/sysctl.d/99-swappiness.conf
```

---

## Tâche 14 — Firewalld avancé

```bash
# 1. Zone par défaut
firewall-cmd --get-default-zone
firewall-cmd --get-zones

# 2. SSH uniquement depuis 192.168.0.0/24
firewall-cmd --permanent --add-rich-rule='rule family=ipv4 source address=192.168.0.0/24 service name=ssh accept'

# 3. Bloquer 10.0.0.99
firewall-cmd --permanent --add-rich-rule='rule family=ipv4 source address=10.0.0.99 drop'

# 4. Port MySQL zone internal
firewall-cmd --permanent --zone=internal --add-port=3306/tcp

# 5. Reload + vérification
firewall-cmd --reload
firewall-cmd --list-all
firewall-cmd --zone=internal --list-all
```

---

## Tâche 15 — RPM et DNF

```bash
# 1. Installer + lister fichiers
dnf install -y httpd
rpm -ql httpd

# 2. Télécharger sans installer
mkdir -p /tmp/rpms
dnf download httpd --destdir /tmp/rpms/

# 3. Inspecter le RPM
RPM=$(ls /tmp/rpms/httpd*.rpm)
rpm -qip $RPM
rpm -qRp $RPM
rpm -q --scripts -p $RPM

# 4. Désinstaller + réinstaller depuis RPM local
dnf remove -y httpd
rpm -ivh $RPM

# 5. Vérifier intégrité
rpm -V httpd
```

---

## Tâche 16 — Flatpak

```bash
# 1. Version
flatpak --version

# 2. Remote Flathub system
flatpak remote-add --system --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# 3. Lister les applications installées
flatpak list

# 4. Détails LibreOffice
flatpak search org.libreoffice.LibreOffice
flatpak remote-info flathub org.libreoffice.LibreOffice

# 5. Documenter
cat > /tmp/flatpak_commands.txt << 'EOF'
Installation : flatpak install flathub org.libreoffice.LibreOffice
Suppression  : flatpak uninstall org.libreoffice.LibreOffice
EOF
```

---

## Tâche 17 — Planification avancée

```bash
# 1. at demain 08h00
echo 'uptime > /tmp/uptime_report.txt' | at 08:00 tomorrow

# 2. Cron sara : lundis 04h30
crontab -u sara -e
# Ajouter : 30 4 * * 1 find /home/sara -name "*.tmp" -delete

# 3 + 4. Timer log_rotate
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

## Tâche 18 — Réseau DNS

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
Le fichier /etc/nsswitch.conf (Name Service Switch) définit l'ordre de résolution.
Ligne : hosts: files dns
- 'files' = /etc/hosts consulté en premier
- 'dns'   = serveurs DNS consultés ensuite
EOF
```

---

## Tâche 19 — autofs indirect + direct

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
echo '/-  /etc/auto.direct' >> /etc/auto.master
echo '/direct/data -rw localhost:/srv/share/rw' > /etc/auto.direct

systemctl enable --now autofs

# Test
ls /mnt/nfs/ro
ls /direct/data
mount | grep autofs
```

---

## Tâche 20 — GRUB et récupération

```bash
# 1. Timeout GRUB
sed -i 's/GRUB_TIMEOUT=.*/GRUB_TIMEOUT=5/' /etc/default/grub

# 2. Appliquer (vérifier BIOS ou EFI)
lsblk | grep boot
# Si /boot => BIOS
grub2-mkconfig -o /boot/grub2/grub.cfg
# Si /boot/efi => EFI
# grub2-mkconfig -o /boot/efi/EFI/redhat/grub.cfg

# 3. Ajouter mem=2G
grubby --update-kernel=DEFAULT --args="mem=2G"
grubby --info=DEFAULT | grep args

# 4. Supprimer immédiatement
grubby --update-kernel=DEFAULT --remove-args="mem=2G"

# 5. Documentation
cat > /tmp/grub_recovery.txt << 'EOF'
rd.break :
  - Interrompt le boot dans l'initramfs AVANT le pivot_root
  - /sysroot = système non encore monté en rw
  - Utile pour : reset mot de passe root (mount -o remount,rw /sysroot + chroot)

init=/bin/bash :
  - Remplace systemd par un shell bash comme PID 1
  - Système de fichiers monté en ro, à remounter en rw
  - Moins propre que rd.break, pas de systemd

systemd.unit=rescue.target :
  - Démarre systemd mais s'arrête à rescue.target (mode single-user)
  - Services minimaux, systèmes de fichiers montés
  - Plus propre, demand e mot de passe root
EOF
```

---

*Solution examen blanc RHCSA EX200 — RHEL 10 — 2026*
