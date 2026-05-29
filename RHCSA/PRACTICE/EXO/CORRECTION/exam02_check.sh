#!/usr/bin/env bash
# ============================================================
# RHCSA Mock Exam #02 — Auto-correction script
# Score: /300 — Pass: 210
# ============================================================
clear

if [ "$(id -u)" -ne 0 ]; then echo "Run as root."; exit 2; fi

uptime_min=$(awk '{ print int($1/60) }' /proc/uptime)
if [ "$uptime_min" -gt 5 ]; then
  echo -e "\e[5m\033[35m\033[1mWARNING\e[0m\033[0m  system has been up for more than 5 minutes. Reboot recommended."
  echo -e "Reboot now? (yes/no)"; read REBOOT
  [ "$REBOOT" = "yes" ] && reboot
fi

SCORE=0; TOTAL=300; PTS=15
ok()   { echo -e "  \033[32m[OK]\033[0m   $1"; }
fail() { echo -e "  \033[31m[FAIL]\033[0m $1"; }
task() { echo -e "\n\033[1mchecking task $1 — $2\033[0m"; }

# ============================================================
task 01 "Users and Groups"
PASS=0
getent group devteam | grep -q ':5000:' && ok "group devteam GID 5000" || { fail "group devteam GID 5000"; PASS=1; }
getent passwd dev1 | grep -q '3001' && ok "dev1 UID 3001" || { fail "dev1 UID 3001"; PASS=1; }
getent passwd dev2 | grep -q '3002' && ok "dev2 UID 3002" || { fail "dev2 UID 3002"; PASS=1; }
getent passwd svc_app | grep -q '3003' && ok "svc_app UID 3003" || { fail "svc_app UID 3003"; PASS=1; }
getent passwd svc_app | grep -qE '(/sbin/nologin|/bin/false)' && ok "svc_app no shell" || { fail "svc_app has interactive shell"; PASS=1; }
chage -l dev1 2>/dev/null | grep -q 'Maximum.*60' && ok "dev1 password max 60 days" || { fail "dev1 password policy wrong"; PASS=1; }
chage -l dev2 2>/dev/null | grep -q '2026' && ok "dev2 account expires 2026" || { fail "dev2 expiry not set"; PASS=1; }
[ $PASS -eq 0 ] && SCORE=$((SCORE + PTS))
echo "  score: $SCORE / $TOTAL"

# ============================================================
task 02 "SSH Key Access"
PASS=0
[ -f /home/dev1/.ssh/authorized_keys ] && ok "authorized_keys exists for dev1" || { fail "authorized_keys missing for dev1"; PASS=1; }
grep -q 'dev1@lab' /home/dev1/.ssh/authorized_keys 2>/dev/null && ok "correct key comment dev1@lab" || { fail "key comment dev1@lab not found"; PASS=1; }
OCT=$(stat -c '%a' /home/dev1/.ssh/authorized_keys 2>/dev/null)
[ "$OCT" = "600" ] && ok "authorized_keys permissions 600" || { fail "authorized_keys permissions wrong ($OCT)"; PASS=1; }
[ $PASS -eq 0 ] && SCORE=$((SCORE + PTS))
echo "  score: $SCORE / $TOTAL"

# ============================================================
task 03 "Permissions and ACLs"
PASS=0
[ -d /projects/devteam ] && ok "/projects/devteam exists" || { fail "/projects/devteam missing"; PASS=1; }
stat -c '%G' /projects/devteam 2>/dev/null | grep -q 'devteam' && ok "group owner devteam" || { fail "group owner not devteam"; PASS=1; }
stat -c '%a' /projects/devteam 2>/dev/null | grep -qE '2770|3770' && ok "sgid set" || { fail "sgid not set"; PASS=1; }
getfacl /projects/devteam 2>/dev/null | grep -q 'dev1.*rwx' && ok "ACL dev1 rwx" || { fail "ACL dev1 rwx not set"; PASS=1; }
getfacl /projects/devteam 2>/dev/null | grep 'dev2' | grep -qv 'w' && ok "ACL dev2 no write" || { fail "ACL dev2 write incorrectly set"; PASS=1; }
[ $PASS -eq 0 ] && SCORE=$((SCORE + PTS))
echo "  score: $SCORE / $TOTAL"

# ============================================================
task 04 "find"
PASS=0
[ -f /tmp/devteam_files.txt ] && ok "/tmp/devteam_files.txt exists" || { fail "/tmp/devteam_files.txt missing"; PASS=1; }
[ -s /tmp/devteam_files.txt ] && ok "devteam_files.txt non-empty" || { fail "devteam_files.txt is empty"; PASS=1; }
[ $PASS -eq 0 ] && SCORE=$((SCORE + PTS))
echo "  score: $SCORE / $TOTAL"

# ============================================================
task 05 "Text Processing"
PASS=0
[ -f /tmp/passwd_sorted.txt ] && ok "/tmp/passwd_sorted.txt exists" || { fail "/tmp/passwd_sorted.txt missing"; PASS=1; }
[ -f /tmp/passwd_copy.txt ] && ok "/tmp/passwd_copy.txt exists" || { fail "/tmp/passwd_copy.txt missing"; PASS=1; }
grep -q 'sh$\|/sh:' /tmp/passwd_copy.txt 2>/dev/null && ok "bash replaced by sh in copy" || { fail "replacement not found in copy"; PASS=1; }
[ -f /tmp/passwd_stats.txt ] && ok "/tmp/passwd_stats.txt exists" || { fail "/tmp/passwd_stats.txt missing"; PASS=1; }
[ $PASS -eq 0 ] && SCORE=$((SCORE + PTS))
echo "  score: $SCORE / $TOTAL"

# ============================================================
task 06 "Partitions and Swap"
PASS=0
mount | grep -q '/mnt/part1' && ok "/mnt/part1 mounted" || { fail "/mnt/part1 not mounted"; PASS=1; }
blkid | grep '/mnt/part1\|TYPE=.xfs' | grep -q '.' || df -T /mnt/part1 2>/dev/null | grep -q 'xfs' \
  && ok "xfs on /mnt/part1" || { fail "xfs not found on /mnt/part1"; PASS=1; }
grep -q 'UUID.*swap\|swap.*UUID' /etc/fstab && ok "swap by UUID in fstab" || { fail "swap UUID not in fstab"; PASS=1; }
swapon --show | grep -q '.' && ok "swap active" || { fail "swap not active"; PASS=1; }
[ $PASS -eq 0 ] && SCORE=$((SCORE + PTS))
echo "  score: $SCORE / $TOTAL"

# ============================================================
task 07 "LVM Snapshot"
PASS=0
vgs 2>/dev/null | grep -q 'vg_dev' && ok "VG vg_dev exists" || { fail "VG vg_dev not found"; PASS=1; }
df -T /mnt/code 2>/dev/null | grep -q 'ext4' && ok "lv_code mounted as ext4" || { fail "lv_code not ext4 on /mnt/code"; PASS=1; }
[ -f /mnt/code/testfile.txt ] && ok "testfile.txt exists" || { fail "testfile.txt missing"; PASS=1; }
grep -q 'VERSION 1' /mnt/code/testfile.txt 2>/dev/null && ok "snapshot restored — VERSION 1" || { fail "snapshot restore failed — not VERSION 1"; PASS=1; }
[ $PASS -eq 0 ] && SCORE=$((SCORE + PTS))
echo "  score: $SCORE / $TOTAL"

# ============================================================
task 08 "Apache and SELinux"
PASS=0
systemctl is-active httpd &>/dev/null && ok "httpd running" || { fail "httpd not running"; PASS=1; }
[ -f /opt/webapp/index.html ] && ok "/opt/webapp/index.html exists" || { fail "/opt/webapp/index.html missing"; PASS=1; }
grep -q 'APP OK' /opt/webapp/index.html 2>/dev/null && ok "content APP OK" || { fail "content wrong"; PASS=1; }
ls -Z /opt/webapp/ 2>/dev/null | grep -q 'httpd_sys_content_t' && ok "SELinux context correct" || { fail "SELinux context wrong on /opt/webapp"; PASS=1; }
curl -s http://localhost | grep -q 'APP OK' && ok "curl returns APP OK" || { fail "curl failed"; PASS=1; }
[ $PASS -eq 0 ] && SCORE=$((SCORE + PTS))
echo "  score: $SCORE / $TOTAL"

# ============================================================
task 09 "SELinux Boolean and Port"
PASS=0
getsebool -a 2>/dev/null | grep 'httpd_read_user_content' | grep -q 'on' && ok "httpd_read_user_content on" || { fail "httpd_read_user_content not enabled"; PASS=1; }
grep -qE '^Listen 8080' /etc/httpd/conf/httpd.conf 2>/dev/null && ok "httpd listens on 8080" || { fail "httpd not on port 8080"; PASS=1; }
semanage port -l 2>/dev/null | grep http_port_t | grep -q '8080' && ok "SELinux allows port 8080" || { fail "SELinux not updated for 8080"; PASS=1; }
firewall-cmd --list-ports 2>/dev/null | grep -q '8080' && ok "firewalld allows 8080" || { fail "firewalld not updated for 8080"; PASS=1; }
[ $PASS -eq 0 ] && SCORE=$((SCORE + PTS))
echo "  score: $SCORE / $TOTAL"

# ============================================================
task 10 "Systemd Override"
PASS=0
[ -d /etc/systemd/system/sshd.service.d ] && ok "sshd override dir exists" || { fail "no override dir for sshd"; PASS=1; }
grep -r 'Restart=' /etc/systemd/system/sshd.service.d/ 2>/dev/null | grep -q '.' && ok "Restart in override" || { fail "Restart not in override"; PASS=1; }
grep -r 'RestartSec.*15' /etc/systemd/system/sshd.service.d/ 2>/dev/null | grep -q '.' && ok "RestartSec 15s" || { fail "RestartSec 15s missing"; PASS=1; }
[ $PASS -eq 0 ] && SCORE=$((SCORE + PTS))
echo "  score: $SCORE / $TOTAL"

# ============================================================
task 11 "Journald"
PASS=0
grep -q 'Storage=persistent' /etc/systemd/journald.conf 2>/dev/null && ok "journald persistent" || { fail "journald not persistent"; PASS=1; }
[ -d /var/log/journal ] && ok "/var/log/journal exists" || { fail "/var/log/journal missing"; PASS=1; }
grep -q 'authpriv.warning' /etc/rsyslog.conf /etc/rsyslog.d/*.conf 2>/dev/null && ok "authpriv.warning rule in rsyslog" || { fail "authpriv.warning rule missing"; PASS=1; }
[ $PASS -eq 0 ] && SCORE=$((SCORE + PTS))
echo "  score: $SCORE / $TOTAL"

# ============================================================
task 12 "Process Priority"
PASS=0
tuned-adm active 2>/dev/null | grep -q 'throughput-performance' && ok "tuned profile throughput-performance" || { fail "wrong tuned profile"; PASS=1; }
[ $PASS -eq 0 ] && SCORE=$((SCORE + PTS))
echo "  score: $SCORE / $TOTAL"

# ============================================================
task 13 "Scheduling"
PASS=0
[ -f /etc/systemd/system/backup_home.timer ] && ok "backup_home.timer exists" || { fail "backup_home.timer missing"; PASS=1; }
grep -q 'OnCalendar.*02:00\|OnCalendar.*02' /etc/systemd/system/backup_home.timer 2>/dev/null && ok "timer at 02:00" || { fail "timer time wrong"; PASS=1; }
grep -q 'Persistent=true' /etc/systemd/system/backup_home.timer 2>/dev/null && ok "Persistent=true set" || { fail "Persistent=true missing"; PASS=1; }
grep -q 'weekly_report' /etc/anacrontab 2>/dev/null && ok "anacron entry for weekly_report" || { fail "anacron entry missing"; PASS=1; }
[ $PASS -eq 0 ] && SCORE=$((SCORE + PTS))
echo "  score: $SCORE / $TOTAL"

# ============================================================
task 14 "Shell Script"
PASS=0
[ -x /usr/local/bin/disk_alert.sh ] && ok "disk_alert.sh executable" || { fail "disk_alert.sh missing or not executable"; PASS=1; }
crontab -l 2>/dev/null | grep -q 'disk_alert' && ok "disk_alert.sh in root crontab" || { fail "disk_alert.sh not scheduled"; PASS=1; }
[ $PASS -eq 0 ] && SCORE=$((SCORE + PTS))
echo "  score: $SCORE / $TOTAL"

# ============================================================
task 15 "Network"
PASS=0
ip a | grep -q '10.0.0.10' && ok "IP 10.0.0.10 configured" || { fail "IP 10.0.0.10 not found"; PASS=1; }
grep -q 'internal.lab.local' /etc/hosts && ok "hosts entry internal.lab.local" || { fail "hosts entry missing"; PASS=1; }
[ $PASS -eq 0 ] && SCORE=$((SCORE + PTS))
echo "  score: $SCORE / $TOTAL"

# ============================================================
task 16 "NFS Client"
PASS=0
grep -q '/mnt/nfs_data' /etc/fstab && ok "/mnt/nfs_data in fstab" || { fail "/mnt/nfs_data not in fstab"; PASS=1; }
grep '/mnt/nfs_data' /etc/fstab | grep -q '_netdev' && ok "_netdev option present" || { fail "_netdev missing for /mnt/nfs_data"; PASS=1; }
grep -q 'homes' /etc/auto.master /etc/auto.master.d/*.autofs 2>/dev/null && ok "autofs homes entry found" || { fail "autofs homes missing"; PASS=1; }
[ $PASS -eq 0 ] && SCORE=$((SCORE + PTS))
echo "  score: $SCORE / $TOTAL"

# ============================================================
task 17 "RPM and DNF"
PASS=0
rpm -qf /usr/bin/find &>/dev/null && ok "package owning /usr/bin/find identified" || { fail "cannot identify package for /usr/bin/find"; PASS=1; }
rpm -q setools-console &>/dev/null && ok "setools-console installed (provides seinfo)" || { fail "setools-console not installed"; PASS=1; }
[ $PASS -eq 0 ] && SCORE=$((SCORE + PTS))
echo "  score: $SCORE / $TOTAL"

# ============================================================
task 18 "Flatpak"
PASS=0
[ -f /tmp/flatpak_diff.txt ] && ok "/tmp/flatpak_diff.txt exists" || { fail "/tmp/flatpak_diff.txt missing"; PASS=1; }
grep -qi 'system\|user' /tmp/flatpak_diff.txt 2>/dev/null && ok "diff file explains system vs user" || { fail "diff file content insufficient"; PASS=1; }
[ $PASS -eq 0 ] && SCORE=$((SCORE + PTS))
echo "  score: $SCORE / $TOTAL"

# ============================================================
task 19 "Hard and Symbolic Links"
PASS=0
[ -f /tmp/links_obs.txt ] && ok "/tmp/links_obs.txt exists" || { fail "/tmp/links_obs.txt missing"; PASS=1; }
grep -qi 'hard\|inode\|sym\|broken\|dangling' /tmp/links_obs.txt 2>/dev/null && ok "observations mention link behavior" || { fail "observations incomplete"; PASS=1; }
[ $PASS -eq 0 ] && SCORE=$((SCORE + PTS))
echo "  score: $SCORE / $TOTAL"

# ============================================================
task 20 "System Troubleshooting"
PASS=0
systemctl get-default 2>/dev/null | grep -q 'multi-user' && ok "default target is multi-user" || { fail "default target is not multi-user"; PASS=1; }
[ -f /tmp/mask_justif.txt ] && ok "/tmp/mask_justif.txt exists" || { fail "/tmp/mask_justif.txt missing"; PASS=1; }
systemctl list-unit-files --state=masked 2>/dev/null | grep -q '.' && ok "at least one service masked" || { fail "no masked service found"; PASS=1; }
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
