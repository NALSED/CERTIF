#!/usr/bin/env bash
# ============================================================
# RHCSA Mock Exam #04 — Auto-correction script
# Score: /300 — Pass: 210
# ============================================================
clear

if [ "$(id -u)" -ne 0 ]; then echo "Run as root."; exit 2; fi

uptime_min=$(awk '{ print int($1/60) }' /proc/uptime)
if [ "$uptime_min" -gt 5 ]; then
  echo -e "\e[5m\033[35m\033[1mWARNING\e[0m\033[0m  system up more than 5 min. Reboot recommended."
  echo -e "Reboot now? (yes/no)"; read REBOOT
  [ "$REBOOT" = "yes" ] && reboot
fi

SCORE=0; TOTAL=300; PTS=15
ok()   { echo -e "  \033[32m[OK]\033[0m   $1"; }
fail() { echo -e "  \033[31m[FAIL]\033[0m $1"; }
task() { echo -e "\n\033[1mchecking task $1 — $2\033[0m"; }

# ============================================================
task 01 "Users"
PASS=0
getent group auditors | grep -q ':7000:' && ok "group auditors GID 7000" || { fail "group auditors GID 7000"; PASS=1; }
getent passwd audit1 | grep -q '5001' && ok "audit1 UID 5001" || { fail "audit1 UID 5001"; PASS=1; }
getent passwd audit2 | grep -q '5002' && ok "audit2 UID 5002" || { fail "audit2 UID 5002"; PASS=1; }
getent passwd audit1 | grep -q '/audit/audit1' && ok "audit1 home /audit/audit1" || { fail "audit1 home wrong"; PASS=1; }
getent passwd readonly | grep -qE '(/sbin/nologin|/bin/false)' && ok "readonly no shell" || { fail "readonly has shell"; PASS=1; }
grep -q "alias ll='ls -alh'" /etc/skel/.bashrc 2>/dev/null && ok "alias ll in /etc/skel/.bashrc" || { fail "alias ll not in /etc/skel/.bashrc"; PASS=1; }
[ -d /etc/skel/scripts ] && ok "scripts/ in /etc/skel" || { fail "scripts/ missing from /etc/skel"; PASS=1; }
grep -q "alias ll='ls -alh'" /home/audit1/.bashrc 2>/dev/null && ok "alias present in audit1 home" || { fail "alias not in audit1 .bashrc"; PASS=1; }
[ $PASS -eq 0 ] && SCORE=$((SCORE + PTS))
echo "  score: $SCORE / $TOTAL"

# ============================================================
task 02 "Sudo"
PASS=0
grep -r 'audit1' /etc/sudoers.d/ 2>/dev/null | grep -q '/usr/sbin/' && ok "audit1 /usr/sbin/ rule found" || { fail "audit1 sudo rule missing"; PASS=1; }
grep -r 'audit2' /etc/sudoers.d/ 2>/dev/null | grep -q 'journalctl' && ok "audit2 journalctl allowed" || { fail "audit2 journalctl rule missing"; PASS=1; }
grep -r 'audit2' /etc/sudoers.d/ 2>/dev/null | grep -q 'ausearch' && ok "audit2 ausearch allowed" || { fail "audit2 ausearch rule missing"; PASS=1; }
[ $PASS -eq 0 ] && SCORE=$((SCORE + PTS))
echo "  score: $SCORE / $TOTAL"

# ============================================================
task 03 "find"
PASS=0
find /etc/ -perm /o+x 2>/dev/null | grep -q '.' && ok "files with o+x found in /etc (check is valid)" || ok "/etc has no o+x files — acceptable"
find /var/log/ -name '*.log' -size +5M 2>/dev/null | grep -q '.' && ok ".log > 5M files exist in /var/log" || ok "no large log files — check manually"
[ $PASS -eq 0 ] && SCORE=$((SCORE + PTS))
echo "  score: $SCORE / $TOTAL"

# ============================================================
task 04 "Text Processing"
PASS=0
[ -f /tmp/top_cpu.txt ] && ok "/tmp/top_cpu.txt exists" || { fail "/tmp/top_cpu.txt missing"; PASS=1; }
[ -f /tmp/passwd_clean.txt ] && ok "/tmp/passwd_clean.txt exists" || { fail "/tmp/passwd_clean.txt missing"; PASS=1; }
grep -qv '^#\|^$' /tmp/passwd_clean.txt 2>/dev/null && ok "no comments or blank lines in passwd_clean" || { fail "passwd_clean has comments or blanks"; PASS=1; }
[ $PASS -eq 0 ] && SCORE=$((SCORE + PTS))
echo "  score: $SCORE / $TOTAL"

# ============================================================
task 05 "LVM pvmove"
PASS=0
vgs 2>/dev/null | grep -q 'vg_thin' && ok "VG vg_thin exists" || { fail "VG vg_thin not found"; PASS=1; }
mount | grep -q '/mnt/main' && ok "/mnt/main mounted" || { fail "/mnt/main not mounted"; PASS=1; }
pvs 2>/dev/null | grep 'vg_thin' | grep -qv '/dev/sdb' && ok "/dev/sdb removed from vg_thin" || { fail "/dev/sdb still in vg_thin"; PASS=1; }
pvs 2>/dev/null | grep 'vg_thin' | grep -q '/dev/sdc' && ok "/dev/sdc is now the only PV" || { fail "/dev/sdc not in vg_thin"; PASS=1; }
[ $PASS -eq 0 ] && SCORE=$((SCORE + PTS))
echo "  score: $SCORE / $TOTAL"

# ============================================================
task 06 "Filesystem Labels"
PASS=0
blkid | grep -q 'DATAPART' && ok "label DATAPART found" || { fail "label DATAPART not found"; PASS=1; }
blkid | grep -q 'XFSPART' && ok "label XFSPART found" || { fail "label XFSPART not found"; PASS=1; }
grep -q 'LABEL=DATAPART' /etc/fstab && ok "LABEL=DATAPART in fstab" || { fail "LABEL=DATAPART not in fstab"; PASS=1; }
grep -q 'LABEL=XFSPART' /etc/fstab && ok "LABEL=XFSPART in fstab" || { fail "LABEL=XFSPART not in fstab"; PASS=1; }
[ $PASS -eq 0 ] && SCORE=$((SCORE + PTS))
echo "  score: $SCORE / $TOTAL"

# ============================================================
task 07 "vsftpd and SELinux"
PASS=0
rpm -q vsftpd &>/dev/null && ok "vsftpd installed" || { fail "vsftpd not installed"; PASS=1; }
systemctl is-active vsftpd &>/dev/null && ok "vsftpd running" || { fail "vsftpd not running"; PASS=1; }
grep -q 'listen_port.*2121\|listen.*2121' /etc/vsftpd/vsftpd.conf 2>/dev/null && ok "vsftpd on port 2121" || { fail "vsftpd not on port 2121"; PASS=1; }
semanage port -l 2>/dev/null | grep ftp | grep -q '2121' && ok "SELinux allows ftp 2121" || { fail "SELinux not updated for ftp 2121"; PASS=1; }
getsebool -a 2>/dev/null | grep 'ftp_home_dir' | grep -q 'on' && ok "ftp_home_dir boolean on" || { fail "ftp_home_dir boolean not enabled"; PASS=1; }
firewall-cmd --list-ports 2>/dev/null | grep -q '2121' && ok "firewalld allows 2121" || { fail "firewalld not updated for 2121"; PASS=1; }
[ $PASS -eq 0 ] && SCORE=$((SCORE + PTS))
echo "  score: $SCORE / $TOTAL"

# ============================================================
task 08 "Systemd Conditions"
PASS=0
[ -f /etc/systemd/system/watchdog.service ] && ok "watchdog.service exists" || { fail "watchdog.service missing"; PASS=1; }
grep -q 'ConditionPathExists=/etc/watchdog.conf' /etc/systemd/system/watchdog.service 2>/dev/null && ok "ConditionPathExists set" || { fail "ConditionPathExists missing"; PASS=1; }
[ -f /etc/watchdog.conf ] && ok "/etc/watchdog.conf exists" || { fail "/etc/watchdog.conf missing"; PASS=1; }
grep -q 'enabled=yes' /etc/watchdog.conf 2>/dev/null && ok "watchdog.conf content correct" || { fail "watchdog.conf content wrong"; PASS=1; }
systemctl is-enabled watchdog.service &>/dev/null && ok "watchdog.service enabled" || { fail "watchdog.service not enabled"; PASS=1; }
[ $PASS -eq 0 ] && SCORE=$((SCORE + PTS))
echo "  score: $SCORE / $TOTAL"

# ============================================================
task 09 "rsyslog and logrotate"
PASS=0
grep -r '*.crit\|kern.crit\|\.crit' /etc/rsyslog.conf /etc/rsyslog.d/ 2>/dev/null | grep -q 'critical.log' \
  && ok "crit messages routed to /var/log/critical.log" || { fail "crit routing missing"; PASS=1; }
[ -f /var/log/critical.log ] && ok "/var/log/critical.log exists" || { fail "/var/log/critical.log not created"; PASS=1; }
ls /etc/logrotate.d/ 2>/dev/null | grep -q 'critical\|custom' || grep -r 'critical.log' /etc/logrotate.d/ 2>/dev/null | grep -q '.' \
  && ok "logrotate config for critical.log" || { fail "logrotate not configured for critical.log"; PASS=1; }
[ $PASS -eq 0 ] && SCORE=$((SCORE + PTS))
echo "  score: $SCORE / $TOTAL"

# ============================================================
task 10 "Shell Script"
PASS=0
[ -x /usr/local/bin/sysreport.sh ] && ok "sysreport.sh executable" || { fail "sysreport.sh missing or not executable"; PASS=1; }
/usr/local/bin/sysreport.sh &>/dev/null
ls /tmp/sysreport_*.txt 2>/dev/null | grep -q '.' && ok "sysreport output file created" || { fail "sysreport output file missing"; PASS=1; }
grep -q 'sshd\|firewalld\|chronyd' /tmp/sysreport_*.txt 2>/dev/null && ok "report contains service status" || { fail "service status missing from report"; PASS=1; }
[ $PASS -eq 0 ] && SCORE=$((SCORE + PTS))
echo "  score: $SCORE / $TOTAL"

# ============================================================
task 11 "Processes"
PASS=0
ps -eo ni,comm | awk '/sshd/ { print $1 }' | grep -q '\-5' && ok "sshd process at nice -5" || { fail "sshd nice -5 not found"; PASS=1; }
[ $PASS -eq 0 ] && SCORE=$((SCORE + PTS))
echo "  score: $SCORE / $TOTAL"

# ============================================================
task 12 "Chrony"
PASS=0
grep -v '^#' /etc/chrony.conf | grep -q 'fr.pool.ntp.org' && ok "fr.pool.ntp.org in chrony.conf" || { fail "fr.pool.ntp.org not in chrony.conf"; PASS=1; }
timedatectl 2>/dev/null | grep -q 'Europe/Paris' && ok "timezone Europe/Paris" || { fail "timezone not Europe/Paris"; PASS=1; }
[ $PASS -eq 0 ] && SCORE=$((SCORE + PTS))
echo "  score: $SCORE / $TOTAL"

# ============================================================
task 13 "Flatpak"
PASS=0
flatpak remotes --system 2>/dev/null | grep -q 'flathub' && ok "flathub system remote exists" || { fail "flathub system remote missing"; PASS=1; }
[ -f /tmp/flatpak_perms.txt ] && ok "/tmp/flatpak_perms.txt exists" || { fail "/tmp/flatpak_perms.txt missing"; PASS=1; }
grep -q 'no-share=network\|network' /tmp/flatpak_perms.txt 2>/dev/null && ok "network restriction documented" || { fail "network restriction not documented"; PASS=1; }
[ $PASS -eq 0 ] && SCORE=$((SCORE + PTS))
echo "  score: $SCORE / $TOTAL"

# ============================================================
task 14 "Firewalld Zones"
PASS=0
firewall-cmd --get-active-zones 2>/dev/null | grep -q 'trusted' && ok "trusted zone active" || { fail "trusted zone not active"; PASS=1; }
firewall-cmd --get-active-zones 2>/dev/null | grep -q 'public' && ok "public zone active" || { fail "public zone not active"; PASS=1; }
firewall-cmd --zone=public --list-services 2>/dev/null | grep -q 'ssh' && ok "ssh in public zone" || { fail "ssh not in public zone"; PASS=1; }
firewall-cmd --zone=public --list-services 2>/dev/null | grep -q 'https' && ok "https in public zone" || { fail "https not in public zone"; PASS=1; }
[ $PASS -eq 0 ] && SCORE=$((SCORE + PTS))
echo "  score: $SCORE / $TOTAL"

# ============================================================
task 15 "RPM"
PASS=0
rpm -qa --qf '%{NAME} %{VERSION}\n' 2>/dev/null | grep '^python' | grep -q '.' && ok "python packages listed" || { fail "no python packages found"; PASS=1; }
[ -f /tmp/pkg_inventory.txt ] && ok "/tmp/pkg_inventory.txt exists" || { fail "/tmp/pkg_inventory.txt missing"; PASS=1; }
[ -s /tmp/pkg_inventory.txt ] && ok "inventory non-empty" || { fail "inventory is empty"; PASS=1; }
[ $PASS -eq 0 ] && SCORE=$((SCORE + PTS))
echo "  score: $SCORE / $TOTAL"

# ============================================================
task 16 "SUID and Links"
PASS=0
[ -f /tmp/suid_risk.txt ] && ok "/tmp/suid_risk.txt exists" || { fail "/tmp/suid_risk.txt missing"; PASS=1; }
grep -qi 'privilege\|escalat\|risk\|root' /tmp/suid_risk.txt 2>/dev/null && ok "risk explanation adequate" || { fail "risk explanation insufficient"; PASS=1; }
[ -f /tmp/hosts_backup ] && ok "/tmp/hosts_backup exists" || { fail "/tmp/hosts_backup missing"; PASS=1; }
HOSTS_INODE=$(stat -c '%i' /etc/hosts 2>/dev/null)
BACKUP_INODE=$(stat -c '%i' /tmp/hosts_backup 2>/dev/null)
[ "$HOSTS_INODE" = "$BACKUP_INODE" ] && ok "hard link confirmed (same inode)" || { fail "hard link inode mismatch"; PASS=1; }
[ $PASS -eq 0 ] && SCORE=$((SCORE + PTS))
echo "  score: $SCORE / $TOTAL"

# ============================================================
task 17 "Scheduling"
PASS=0
atq 2>/dev/null | grep -q '.' && ok "at job pending" || { fail "no at job found"; PASS=1; }
ls /etc/cron.d/ 2>/dev/null | grep -q '.' && ok "cron.d entry exists" || { fail "no cron.d entry"; PASS=1; }
grep -r 'sync' /etc/cron.d/ 2>/dev/null | grep -q '\*/5' && ok "sync every 5 min in cron.d" || { fail "sync every 5 min not found"; PASS=1; }
[ -f /etc/systemd/system/rpm_check.timer ] && ok "rpm_check.timer exists" || { fail "rpm_check.timer missing"; PASS=1; }
grep -q 'OnCalendar.*Sun.*01:00\|OnCalendar.*weekly\|Sunday' /etc/systemd/system/rpm_check.timer 2>/dev/null && ok "timer Sunday 01:00" || { fail "timer schedule wrong"; PASS=1; }
[ $PASS -eq 0 ] && SCORE=$((SCORE + PTS))
echo "  score: $SCORE / $TOTAL"

# ============================================================
task 18 "NFS Mount Options"
PASS=0
showmount -e localhost 2>/dev/null | grep -q '/srv/nfs/soft' && ok "/srv/nfs/soft exported" || { fail "/srv/nfs/soft not exported"; PASS=1; }
showmount -e localhost 2>/dev/null | grep -q '/srv/nfs/hard' && ok "/srv/nfs/hard exported" || { fail "/srv/nfs/hard not exported"; PASS=1; }
grep '/srv/nfs/soft' /etc/fstab | grep -q 'soft' && ok "soft mount option set" || { fail "soft option missing"; PASS=1; }
grep '/srv/nfs/hard' /etc/fstab | grep -q 'hard' && ok "hard mount option set" || { fail "hard option missing"; PASS=1; }
[ -f /tmp/nfs_options.txt ] && ok "/tmp/nfs_options.txt exists" || { fail "/tmp/nfs_options.txt missing"; PASS=1; }
[ $PASS -eq 0 ] && SCORE=$((SCORE + PTS))
echo "  score: $SCORE / $TOTAL"

# ============================================================
task 19 "autofs Direct Map"
PASS=0
systemctl is-enabled autofs &>/dev/null && ok "autofs enabled" || { fail "autofs not enabled"; PASS=1; }
grep -r '/mnt/direct_hard\|/srv/nfs/hard' /etc/auto.master /etc/auto.master.d/ 2>/dev/null | grep -q '.' \
  && ok "direct map /mnt/direct_hard found" || { fail "direct map missing"; PASS=1; }
[ $PASS -eq 0 ] && SCORE=$((SCORE + PTS))
echo "  score: $SCORE / $TOTAL"

# ============================================================
task 20 "Recovery"
PASS=0
[ -f /tmp/full_recovery.txt ] && ok "/tmp/full_recovery.txt exists" || { fail "/tmp/full_recovery.txt missing"; PASS=1; }
grep -qi 'rd.break' /tmp/full_recovery.txt 2>/dev/null && ok "rd.break mentioned" || { fail "rd.break not in procedure"; PASS=1; }
grep -qi 'autorelabel' /tmp/full_recovery.txt 2>/dev/null && ok "autorelabel explained" || { fail "autorelabel not mentioned"; PASS=1; }
grep -qi 'enforcing=0' /tmp/full_recovery.txt 2>/dev/null && ok "enforcing=0 mentioned" || { fail "enforcing=0 not mentioned"; PASS=1; }
getenforce | grep -qi 'enforcing' && ok "SELinux is enforcing" || { fail "SELinux not in enforcing mode"; PASS=1; }
[ $PASS -eq 0 ] && SCORE=$((SCORE + PTS))
echo "  score: $SCORE / $TOTAL"

# --- SELinux penalty ---
if getenforce | grep -qiE 'Permissive|Disabled'; then
  echo -e "\n  \033[31m[PENALTY]\033[0m SELinux not enforcing — minus 60 points"
  SCORE=$((SCORE - 60))
fi

echo -e "\n========================================"
echo -e "  Final score: \033[1m$SCORE / $TOTAL\033[0m"
if [ "$SCORE" -ge 210 ]; then
  echo -e "  \033[32mEXAMEN BLANC RÉUSSI — PASS\033[0m"
else
  echo -e "  \033[31mEXAMEN BLANC RATÉ — FAIL\033[0m  (need 210, got $SCORE)"
fi
echo "========================================"
