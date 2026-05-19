# ✅ Solution — Examen Blanc RHCSA N°04

---

## Tâche 01 — Utilisateurs et /etc/skel

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

# Les homes étant déjà créés, copier manuellement
cp /etc/skel/.bashrc /audit/audit1/
mkdir -p /audit/audit1/scripts
chown -R audit1:auditors /audit/audit1
chown -R audit2:auditors /audit/audit2

# Vérification
ls -la /audit/audit1/
cat /audit/audit1/.bashrc
```

---

## Tâche 02 — Sudo restrictions

```bash
# audit1 : uniquement /usr/sbin/*
visudo -f /etc/sudoers.d/audit1
```
```
audit1 ALL=(ALL) NOPASSWD: /usr/sbin/
```

```bash
# audit2 : journalctl + ausearch uniquement
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

## Tâche 03 — find cas pièges

```bash
# 1. Fichiers avec x pour others dans /etc/
find /etc -perm -o+x -type f 2>/dev/null

# 2. Fichiers /home/ non accédés depuis +30 jours
find /home -atime +30 -type f 2>/dev/null

# 3. Fichiers .log >5M dans /var/log/ avec taille lisible
find /var/log -name "*.log" -size +5M -ls 2>/dev/null
# -ls affiche : inode taille perm liens user group size date nom

# 4. Fichiers avec espace dans le nom dans /tmp/
find /tmp -name "* *" -type f

# 5. Fichiers appartenant à audit1 OU audit2
find / \( -user audit1 -o -user audit2 \) 2>/dev/null
```

---

## Tâche 04 — Traitement de texte

```bash
# 1. Top 10 CPU
ps -eo pid,%cpu,comm --sort=-%cpu | head -11 | awk '{print $1, $2}' > /tmp/top_cpu.txt

# 2. Supprimer commentaires et lignes vides avec sed
sed -e '/^#/d' -e '/^$/d' /etc/passwd > /tmp/passwd_clean.txt

# 3. Compter utilisateurs avec shell valide
grep -v '/sbin/nologin\|/bin/false' /etc/passwd | wc -l

# 4. Hostname en majuscules avec tr
cat /etc/hostname | tr '[:lower:]' '[:upper:]'
```

---

## Tâche 05 — LVM pvmove

```bash
pvcreate /dev/sdb
vgcreate vg_thin /dev/sdb
lvcreate -L 6G -n lv_main vg_thin
mkfs.xfs /dev/vg_thin/lv_main
mkdir -p /mnt/main
mount /dev/vg_thin/lv_main /mnt/main
echo 'test data' > /mnt/main/testfile

# Ajouter /dev/sdc au VG
pvcreate /dev/sdc
vgextend vg_thin /dev/sdc

# Déplacer les PE de sdb vers sdc
pvmove /dev/sdb /dev/sdc
# (opération peut prendre du temps, les données restent accessibles)

# Retirer sdb du VG
vgreduce vg_thin /dev/sdb

# Vérification
df -hT /mnt/main
cat /mnt/main/testfile
pvs
vgs
```

---

## Tâche 06 — Labels

```bash
# Partition ext4 avec label
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

## Tâche 07 — SELinux vsftpd port 2121

```bash
dnf install -y vsftpd
mkdir -p /srv/ftp/data
echo 'FTP TEST' > /srv/ftp/data/test.txt

# Port 2121 dans vsftpd.conf
echo 'listen_port=2121' >> /etc/vsftpd/vsftpd.conf

# SELinux : port ftp
semanage port -a -t ftp_port_t -p tcp 2121

# Contexte sur /srv/ftp/data/
semanage fcontext -a -t public_content_t "/srv/ftp/data(/.*)?" 
restorecon -Rv /srv/ftp/data/

# Booléen homes
setsebool -P ftp_home_dir on

# Firewall
firewall-cmd --add-port=2121/tcp --permanent
firewall-cmd --reload

systemctl enable --now vsftpd
curl ftp://localhost:2121
```

---

## Tâche 08 — Service watchdog

```bash
cat > /usr/local/bin/watchdog_check.sh << 'EOF'
#!/bin/bash
if [ ! -f /var/run/app.pid ]; then
    echo "$(date) - ALERTE: /var/run/app.pid absent" >> /var/log/watchdog.log
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

## Tâche 09 — Rsyslog + logrotate

```bash
# Rsyslog : crit+
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

# Générer message test
logger -p kern.crit "TEST CRITIQUE"
cat /var/log/critical.log
```

---

## Tâche 10 — Script sysreport

```bash
cat > /usr/local/bin/sysreport.sh << 'EOF'
#!/bin/bash
REPORT="/tmp/sysreport_$(date +%Y%m%d).txt"
ALL_OK=0

{
echo "=== RAPPORT SYSTEME ==="
echo "Hostname : $(hostname)"
echo "Date     : $(date)"
echo ""
echo "=== DISQUES ==="
df -hT
echo ""
echo "=== TOP 5 MEMOIRE ==="
ps -eo pid,pmem,comm --sort=-pmem | head -6
echo ""
echo "=== UTILISATEURS CONNECTES ==="
who | wc -l
echo ""
echo "=== STATUT SERVICES ==="
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
echo "Code retour : $?"
```

---

## Tâche 11 — Processus et loginctl

```bash
# 1. Sessions actives
loginctl list-sessions

# 2. Top mémoire
ps -eo pid,pmem,comm --sort=-pmem | head -5

# 3. Renice sshd
PID_SSHD=$(pgrep -o sshd)
renice -n -5 -p $PID_SSHD
ps -o pid,ni,comm -p $PID_SSHD

# 4. Terminer session audit2
loginctl terminate-user audit2

# 5. Vérification
loginctl list-users
```

---

## Tâche 12 — Chrony

```bash
# 1. Tracking
chronyc tracking

# 2. Ajouter serveur NTP
echo 'server 0.fr.pool.ntp.org iburst' >> /etc/chrony.conf
systemctl restart chronyd

# 3. Synchronisation forcée
chronyc makestep

# 4. Fuseau horaire
timedatectl set-timezone Europe/Paris

# 5. Vérification
timedatectl status
chronyc sources
```

---

## Tâche 13 — Flatpak permissions

```bash
# 1. Version
flatpak --version

# 2. Remote Flathub
flatpak remote-add --system --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# 3. Recherche text editor
flatpak search "text editor"

# 4. Permissions d'une app installée
flatpak list
# Si aucune app installée :
flatpak install --system flathub org.gnome.gedit -y 2>/dev/null || true
flatpak info --show-permissions org.gnome.gedit 2>/dev/null || echo 'Non installé'

# 5. Documentation
cat > /tmp/flatpak_perms.txt << 'EOF'
Pour restreindre l'accès réseau d'une app Flatpak :
flatpak override --nofilesystem=host <APP_ID>
flatpak override --no-share=network <APP_ID>

Exemple :
flatpak override --no-share=network org.gnome.gedit

Pour voir les overrides appliqués :
flatpak override --show <APP_ID>
EOF
```

---

## Tâche 14 — Firewalld zones

```bash
# 1. Zone par défaut
firewall-cmd --get-default-zone
firewall-cmd --get-zones

# Interface principale
INTERFACE=$(ip route | awk '/default/ {print $5}' | head -1)

# 2. Interface principale -> trusted
firewall-cmd --permanent --zone=trusted --add-interface=$INTERFACE

# 3. Zone public : SSH + HTTPS uniquement
firewall-cmd --permanent --zone=public --remove-service=dhcpv6-client
firewall-cmd --permanent --zone=public --add-service=ssh
firewall-cmd --permanent --zone=public --add-service=https

# 4. Zone trusted : tout le trafic
firewall-cmd --permanent --zone=trusted --set-target=ACCEPT

# 5. Persistant
firewall-cmd --reload
firewall-cmd --get-active-zones
firewall-cmd --zone=public --list-all
```

---

## Tâche 15 — RPM avancé

```bash
# 1. Paquets python*
rpm -qa | grep '^python'

# 2. Nom + version avec format personnalisé
rpm -qa --qf "%{NAME} %{VERSION}\n" | grep '^python'

# 3. Paquet fournissant python3
rpm -qf /usr/bin/python3

# 4. Scripts post-install
rpm -q --scripts python3-libs

# 5. Inventaire complet
rpm -qa --qf "%{NAME} %{VERSION} %{ARCH}\n" | sort > /tmp/pkg_inventory.txt
wc -l /tmp/pkg_inventory.txt
```

---

## Tâche 16 — SUID + liens

```bash
# 1. Binaires SUID
find /usr/bin /usr/sbin -perm -4000 -type f 2>/dev/null

# 2. Risque SUID
cat > /tmp/suid_risk.txt << 'EOF'
Risque SUID sur binaire personnalisé :
Un binaire avec SUID s'exécute avec les privilèges du propriétaire (souvent root).
Si le binaire contient une vulnérabilité (injection, buffer overflow, PATH hijacking),
un attaquant peut obtenir une escalade de privilèges vers root.
Règle : n'activer SUID que sur des binaires système éprouvés (passwd, sudo).
EOF

# 3. Lien symbolique
ln -s /usr/bin/ls /usr/local/bin/ll
ls -la /usr/local/bin/ll

# 4. Lien physique
ln /etc/hosts /tmp/hosts_backup

# 5. Vérification inode identique
ls -li /etc/hosts /tmp/hosts_backup
```

---

## Tâche 17 — Planification combinée

```bash
# 1. at dans 10 minutes
echo 'rpm -Va > /tmp/rpm_verify.txt' | at now +10 minutes
atq

# 2. Cron système dans /etc/cron.d/
cat > /etc/cron.d/sync_job << 'EOF'
*/5 * * * * root /usr/bin/sync
EOF
chmod 644 /etc/cron.d/sync_job

# 3 + 4. Timer rpm_check
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

## Tâche 18 — NFS options soft/hard

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
soft : si le serveur NFS ne répond pas dans le délai (timeo=30 dixèmes de sec),
       l'opération échoue immédiatement avec une erreur I/O.
       Usage : lecture de données non critiques, évite les blocages.

hard : le client réessaie indéfiniment jusqu'à ce que le serveur réponde.
       intr : permet d'interrompre avec Ctrl+C.
       Usage : données critiques, ne pas risquer de corruption.
EOF
```

---

## Tâche 19 — autofs direct + timeout

```bash
dnf install -y autofs

# Direct map avec timeout
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

## Tâche 20 — Récupération complète

```bash
# Documentation procédure complète
cat > /tmp/full_recovery.txt << 'EOF'
PROCÉDURE RESET MOT DE PASSE ROOT + SELinux :

1. Au menu GRUB, sélectionner le kernel, appuyer sur 'e'
2. Ligne 'linux' : ajouter 'rd.break enforcing=0' à la fin
3. Ctrl+X pour booter
4. switch_root:/# mount -o remount,rw /sysroot
5. switch_root:/# chroot /sysroot
6. sh-5.2# passwd root
7. sh-5.2# touch /.autorelabel
   => OBLIGATOIRE : le chroot a modifié /etc/shadow sans mise à jour du contexte SELinux.
   => Sans autorelabel, SELinux refusera l'accès au fichier shadow au prochain boot.
8. sh-5.2# exit
9. switch_root:/# exit  => reboot
EOF

# grubby : ajouter enforcing=0 temporairement
grubby --update-kernel=DEFAULT --args="enforcing=0"
grubby --info=DEFAULT | grep args

# Après reboot, remettre enforcing=1
grubby --update-kernel=DEFAULT --remove-args="enforcing=0"

# Vérification
getenforce
sestatus | head -5
```

---

*Solution examen blanc RHCSA EX200 — RHEL 10 — 2026*
