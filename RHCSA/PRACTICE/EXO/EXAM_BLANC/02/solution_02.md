# ✅ Solution — Examen Blanc RHCSA N°02

---

## Tâche 01 — Utilisateurs, groupes et politiques

```bash
groupadd -g 5000 devteam

useradd -u 3001 -s /bin/bash -g devteam dev1
useradd -u 3002 -s /bin/bash -g devteam dev2
useradd -u 3003 -s /sbin/nologin -M -r svc_app

echo 'Dev@2026' | passwd --stdin dev1
echo 'Dev@2026' | passwd --stdin dev2

# Politique dev1 : 60j max, 5j min, 10j avertissement
chage -M 60 -m 5 -W 10 dev1

# Expiration dev2 au 2026-12-31
chage -E 2026-12-31 dev2

# Vérifications
chage -l dev1
chage -l dev2
id svc_app
```

---

## Tâche 02 — SSH par clé

```bash
# Générer la clé pour dev1
sudo -u dev1 ssh-keygen -t ed25519 -C 'dev1@lab' -N '' -f /home/dev1/.ssh/id_ed25519

# Copier la clé publique dans authorized_keys
mkdir -p /home/dev1/.ssh
cat /home/dev1/.ssh/id_ed25519.pub >> /home/dev1/.ssh/authorized_keys

# Permissions obligatoires
chmod 700 /home/dev1/.ssh
chmod 600 /home/dev1/.ssh/authorized_keys
chown -R dev1:dev1 /home/dev1/.ssh

# Test
ssh -i /home/dev1/.ssh/id_ed25519 dev1@localhost
```

---

## Tâche 03 — Permissions et ACL

```bash
# Prérequis : s'assurer que acl est supporté (xfs/ext4 le supportent nativement)
mkdir -p /projects/devteam
chown root:devteam /projects/devteam
chmod 2770 /projects/devteam

# ACL granulaires
setfacl -m u:dev1:rwx /projects/devteam
setfacl -m u:dev2:r-x /projects/devteam
setfacl -m u:svc_app:--- /projects/devteam

# Vérification
getfacl /projects/devteam
```

---

## Tâche 04 — find avancée

```bash
# 1. Fichiers groupe devteam
find / -group devteam 2>/dev/null > /tmp/devteam_files.txt

# 2. Liens symboliques dans /etc/ avec leur cible
find /etc -type l -printf "%p -> %l\n"

# 3. Fichiers /var/log/ non modifiés depuis +30j ET >1M
find /var/log -mtime +30 -size +1M -type f

# 4. Fichiers avec permissions EXACTES 644 dans /home/
find /home -perm 644 -type f
# Note : -perm 644 = exactement 644 | -perm -644 = au moins 644

# 5. chmod 600 sur ces fichiers
find /home -perm 644 -type f -exec chmod 600 {} \;
```

---

## Tâche 05 — Redirections et traitement texte

```bash
# 1. Trié par UID (champ 3) décroissant
sort -t: -k3 -rn /etc/passwd > /tmp/passwd_sorted.txt

# 2. Utilisateurs avec shell /bin/bash
awk -F: '$7 == "/bin/bash" {print $1}' /etc/passwd

# 3. Remplacement bash -> sh dans une copie
sed 's/bash/sh/g' /etc/passwd > /tmp/passwd_copy.txt

# 4. Comptage lignes/mots/caractères
wc /etc/passwd > /tmp/passwd_stats.txt
cat /tmp/passwd_stats.txt
```

---

## Tâche 06 — Partitions et swap

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

## Tâche 07 — LVM + snapshot

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

# Modifier le fichier
echo 'VERSION 2' > /mnt/code/testfile.txt
cat /mnt/code/testfile.txt

# Restaurer via merge
umount /mnt/code
lvconvert --merge /dev/vg_dev/lv_code_snap
mount /dev/vg_dev/lv_code /mnt/code
cat /mnt/code/testfile.txt
# Doit afficher : VERSION 1
```

---

## Tâche 08 — SELinux diagnostic

```bash
dnf install -y httpd setroubleshoot-server
mkdir -p /opt/webapp
echo 'APP OK' > /opt/webapp/index.html

sed -i 's|DocumentRoot "/var/www/html"|DocumentRoot "/opt/webapp"|' /etc/httpd/conf/httpd.conf
sed -i 's|<Directory "/var/www/html">|<Directory "/opt/webapp">|' /etc/httpd/conf/httpd.conf

systemctl start httpd
# => Va échouer ou donner 403 à cause de SELinux

# Diagnostic
ausearch -m avc -ts recent
sealert -a /var/log/audit/audit.log

# Correction
semanage fcontext -a -t httpd_sys_content_t "/opt/webapp(/.*)?" 
restorecon -Rv /opt/webapp/

systemctl restart httpd
curl http://localhost
```

---

## Tâche 09 — SELinux booléen + port 8080

```bash
# Booléen : httpd lire les home
setsebool -P httpd_enable_homedirs on

# Port 8080 dans httpd.conf
sed -i 's/Listen 80/Listen 8080/' /etc/httpd/conf/httpd.conf

# Port SELinux
semanage port -a -t http_port_t -p tcp 8080

# Firewall
firewall-cmd --add-port=8080/tcp --permanent
firewall-cmd --reload

systemctl restart httpd
curl http://localhost:8080
```

---

## Tâche 10 — Override sshd

```bash
systemctl edit sshd.service
# Contenu :
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

## Tâche 11 — Journald persistance + filtrage

```bash
# 1. Persistance journald
mkdir -p /var/log/journal
sed -i 's/#Storage=auto/Storage=persistent/' /etc/systemd/journald.conf
systemctl restart systemd-journald

# 2. Logs boot actuel pour sshd
journalctl -b -u sshd

# 3. Logs err+ depuis 2 heures
journalctl -p err --since "2 hours ago"

# 4. Rsyslog : authpriv warning+ vers fichier
cat >> /etc/rsyslog.d/auth_warn.conf << 'EOF'
authpriv.warning /var/log/auth_warn.log
EOF
systemctl restart rsyslog
```

---

## Tâche 12 — Processus et priorité

```bash
# Lancer dd avec nice 10 en arrière-plan
nice -n 10 dd if=/dev/zero of=/dev/null &

# PID et valeur nice
ps -eo pid,ni,comm | grep dd

# Renice à -5
renice -n -5 -p <PID>

# Vérification
ps -o pid,ni,comm -p <PID>

# Tuer proprement
kill -15 <PID>
ps -p <PID> 2>/dev/null || echo 'processus terminé'

# Tuned
tuned-adm profile throughput-performance
tuned-adm active
```

---

## Tâche 13 — Timer + anacron

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

## Tâche 14 — Script disk_alert

```bash
cat > /usr/local/bin/disk_alert.sh << 'EOF'
#!/bin/bash
ALERT=0
while IFS= read -r line; do
    USE=$(echo "$line" | awk '{print $5}' | tr -d '%')
    MOUNT=$(echo "$line" | awk '{print $6}')
    if [[ "$USE" =~ ^[0-9]+$ ]] && [ "$USE" -gt 80 ]; then
        echo "ALERTE: $MOUNT est à ${USE}%" >> /var/log/disk_alert.log
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

# Cron root : toutes les heures
crontab -e
# Ajouter : 0 * * * * /usr/local/bin/disk_alert.sh
```

---

## Tâche 15 — Double interface

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

## Tâche 16 — NFS client

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

# Montage persistant NFS
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

## Tâche 17 — RPM et DNF

```bash
# 1. Paquet ayant installé /usr/bin/find
rpm -qf /usr/bin/find

# 2. Fichiers de config de ce paquet
rpm -qc $(rpm -qf /usr/bin/find)

# 3. Vérification intégrité
rpm -V $(rpm -qf /usr/bin/find)

# 4. Paquet fournissant seinfo
dnf provides seinfo
# => setools-console

# 5. Installation + liste modules SELinux
dnf install -y setools-console
seinfo -t | head -20
```

---

## Tâche 18 — Flatpak avancé

```bash
# Remote user pour dev1
sudo -u dev1 flatpak remote-add --user --if-not-exists flathub-user https://dl.flathub.org/repo/flathub.flatpakrepo

# Lister tous les remotes
flatpak remotes
sudo -u dev1 flatpak remotes

# Rechercher Inkscape sans installer
flatpak search org.inkscape.Inkscape

# Supprimer le remote user
sudo -u dev1 flatpak remote-delete --user flathub-user

# Documentation diff
cat > /tmp/flatpak_diff.txt << 'EOF'
--system : remote installé pour tous les utilisateurs (nécessite root), stocké dans /var/lib/flatpak
--user   : remote installé uniquement pour l'utilisateur courant, stocké dans ~/.local/share/flatpak
EOF
```

---

## Tâche 19 — Liens physiques et symboliques

```bash
mkdir -p /data
echo 'CONTENU ORIGINAL' > /data/original.txt

# Lien physique
ln /data/original.txt /data/hardlink.txt

# Lien symbolique
ln -s /data/original.txt /data/symlink.txt

ls -li /data/

# Supprimer l'original
rm /data/original.txt

# Observer
cat /data/hardlink.txt   # => fonctionne (même inode, données toujours présentes)
cat /data/symlink.txt    # => ERREUR : lien mort (dangling symlink)

# Trouver fichiers avec même inode que hardlink
INODE=$(stat -c %i /data/hardlink.txt)
find / -inum $INODE 2>/dev/null

# Observations
cat > /tmp/liens_obs.txt << 'EOF'
- Lien physique : même inode, données accessibles même après suppression de l'original
- Lien symbolique : inode différent, pointe vers le chemin -> devient mort si l'original est supprimé
- find -inum permet de retrouver tous les hardlinks d'un même fichier
EOF
```

---

## Tâche 20 — Troubleshooting système

```bash
# 1. Cible par défaut
systemctl set-default multi-user.target
systemctl get-default

# 2. Retirer 'quiet' du kernel
grubby --update-kernel=ALL --remove-args="quiet"

# 3. Ajouter systemd.log_level=debug temporairement (non persistant)
# Faire au boot : éditer la ligne kernel dans GRUB avec 'e', ajouter l'argument
# Ou via grubby sans --update (uniquement pour tester) :
grubby --update-kernel=DEFAULT --args="systemd.log_level=debug"
# Puis après test :
grubby --update-kernel=DEFAULT --remove-args="systemd.log_level=debug"

# 4. Derniers logs du boot
journalctl -b | tail -20

# 5. Masquer un service inutile (exemple : cups)
systemctl mask cups.service

cat > /tmp/mask_justif.txt << 'EOF'
Service masqué : cups.service (service d'impression)
Raison : serveur sans imprimante, service inutile et expose une surface d'attaque inutile.
systemctl mask crée un symlink vers /dev/null, empêchant tout démarrage.
EOF
```

---

*Solution examen blanc RHCSA EX200 — RHEL 10 — 2026*
