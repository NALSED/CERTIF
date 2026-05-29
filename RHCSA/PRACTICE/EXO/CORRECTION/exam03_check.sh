#!/usr/bin/env bash
# ============================================================
# RHCSA Mock Exam #03 — Auto-correction script
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
task 01 "Users and Groups"
PASS=0
getent group webadmin | grep -q ':6000:' && ok "group webadmin GID 6000" || { fail "group webadmin GID 6000"; PASS=1; }
getent group dba | grep -q ':6001:' && ok "group dba GID 6001" || { fail "group dba GID 6001"; PASS=1; }
getent passwd tom | grep -q '4001' && ok "tom UID 4001" || { fail "tom UID 4001"; PASS=1; }
id tom 2>/dev/null | grep -q 'webadmin' && id tom | grep -q 'dba' && ok "tom in webadmin and dba" || { fail "tom group membership wrong"; PASS=1; }
getent passwd sara | grep -q '4002' && ok "sara UID 4002" || { fail "sara UID 4002"; PASS=1; }
getent passwd batch | grep -qE '(/sbin/nologin|/bin/false)' && ok "batch no shell" || { fail "batch has interactive shell"; PASS=1; }
[ -d /var/lib/batch ] && ok "/var/lib/batch home exists" || { fail "/var/lib/batch missing"; PASS=1; }
id tom 2>/dev/null | grep -q 'dba' && ok "tom primary/effective group dba configured" || { fail "tom new files won't inherit dba"; PASS=1; }
[ $PASS -eq 0 ] && SCORE=$((SCORE + PTS))
echo "  score: $SCORE / $TOTAL"

# ============================================================
task 02 "SSH Hardening"
PASS=0
grep -qE '^PermitRootLogin no' /etc/ssh/sshd_config && ok "root login disabled" || { fail "root login not disabled"; PASS=1; }
grep -q 'AllowUsers.*tom.*sara\|AllowUsers.*sara.*tom' /etc/ssh/sshd_config && ok "AllowUsers tom sara" || { fail "AllowUsers not set"; PASS=1; }
grep -qE '^Port 2200' /etc/ssh/sshd_config && ok "SSH on port 2200" || { fail "SSH port not 2200"; PASS=1; }
grep -qE '^PasswordAuthentication no' /etc/ssh/sshd_config && ok "PasswordAuthentication disabled" || { fail "PasswordAuthentication not disabled"; PASS=1; }
semanage port -l 2>/dev/null | grep ssh | grep -q '2200' && ok "SELinux allows port 2200" || { fail "SELinux not updated for 2200"; PASS=1; }
firewall-cmd --list-ports 2>/dev/null | grep -q '2200' && ok "firewalld allows port 2200" || { fail "firewalld not updated for 2200"; PASS=1; }
[ $PASS -eq 0 ] && SCORE=$((SCORE + PTS))
echo "  score: $SCORE / $TOTAL"

# ============================================================
task 03 "find"
PASS=0
[ -f /tmp/orphans.txt ] && ok "/tmp/orphans.txt exists" || { fail "/tmp/orphans.txt missing"; PASS=1; }
[ -f /tmp/sgid_files.txt ] && ok "/tmp/sgid_files.txt exists" || { fail "/tmp/sgid_files.txt missing"; PASS=1; }
[ -s /tmp/sgid_files.txt ] && ok "sgid_files.txt non-empty" || { fail "sgid_files.txt is empty"; PASS=1; }
[ $PASS -eq 0 ] && SCORE=$((SCORE + PTS))
echo "  score: $SCORE / $TOTAL"

# ============================================================
task 04 "Archiving"
PASS=0
[ -f /backup/etc_full.tar.xz ] && ok "/backup/etc_full.tar.xz exists" || { fail "archive not found"; PASS=1; }
tar -tJf /backup/etc_full.tar.xz 2>/dev/null | grep -q 'etc/' && ok "archive contains /etc content" || { fail "archive content wrong"; PASS=1; }
[ -f /tmp/restore/httpd.conf ] && ok "httpd.conf extracted to /tmp/restore/" || { fail "httpd.conf not in /tmp/restore/"; PASS=1; }
[ $PASS -eq 0 ] && SCORE=$((SCORE + PTS))
echo "  score: $SCORE / $TOTAL"

# ============================================================
task 05 "LVM"
PASS=0
vgs 2>/dev/null | grep -q 'vg_test' && ok "VG vg_test exists" || { fail "VG vg_test not found"; PASS=1; }
lvs 2>/dev/null | grep -q 'lv_a' && ok "LV lv_a exists" || { fail "LV lv_a not found"; PASS=1; }
lvs 2>/dev/null | grep -q 'lv_b' && ok "LV lv_b exists" || { fail "LV lv_b not found"; PASS=1; }
LVA_SIZE=$(lvdisplay 2>/dev/null | grep -A3 'lv_a' | awk '/LV Size/ { print int($3) }')
[ "${LVA_SIZE:-0}" -le 1 ] && ok "lv_a reduced to <=1G" || { fail "lv_a not reduced (size: ${LVA_SIZE}G)"; PASS=1; }
[ $PASS -eq 0 ] && SCORE=$((SCORE + PTS))
echo "  score: $SCORE / $TOTAL"

# ============================================================
task 06 "NFS"
PASS=0
showmount -e localhost 2>/dev/null | grep -q '/srv/share/ro' && ok "/srv/share/ro exported" || { fail "/srv/share/ro not exported"; PASS=1; }
showmount -e localhost 2>/dev/null | grep -q '/srv/share/rw' && ok "/srv/share/rw exported" || { fail "/srv/share/rw not exported"; PASS=1; }
grep -q 'srv/share' /etc/fstab && ok "NFS mounts in fstab" || { fail "NFS mounts not in fstab"; PASS=1; }
[ $PASS -eq 0 ] && SCORE=$((SCORE + PTS))
echo "  score: $SCORE / $TOTAL"

# ============================================================
task 07 "SELinux Troubleshooting"
PASS=0
systemctl is-active nginx &>/dev/null && ok "nginx running" || { fail "nginx not running"; PASS=1; }
ls -Z /data/nginx/html/ 2>/dev/null | grep -q 'httpd_sys_content_t' && ok "SELinux context correct on /data/nginx/html" || { fail "SELinux context wrong on /data/nginx/html"; PASS=1; }
curl -s http://localhost | grep -qv 'Permission denied\|403\|Failed' && ok "nginx serves content" || { fail "nginx not serving — SELinux issue?"; PASS=1; }
[ $PASS -eq 0 ] && SCORE=$((SCORE + PTS))
echo "  score: $SCORE / $TOTAL"

# ============================================================
task 08 "Systemd Units"
PASS=0
[ -f /etc/systemd/system/monitor.service ] && ok "monitor.service exists" || { fail "monitor.service missing"; PASS=1; }
grep -q 'Type=forking' /etc/systemd/system/monitor.service 2>/dev/null && ok "Type=forking" || { fail "Type=forking missing"; PASS=1; }
[ -f /etc/systemd/system/cleanup.service ] && ok "cleanup.service exists" || { fail "cleanup.service missing"; PASS=1; }
grep -q 'monitor.service' /etc/systemd/system/cleanup.service 2>/dev/null && ok "cleanup depends on monitor" || { fail "dependency on monitor missing"; PASS=1; }
[ -f /etc/systemd/system/cleanup.timer ] && ok "cleanup.timer exists" || { fail "cleanup.timer missing"; PASS=1; }
systemctl is-enabled cleanup.timer &>/dev/null && ok "cleanup.timer enabled" || { fail "cleanup.timer not enabled"; PASS=1; }
[ $PASS -eq 0 ] && SCORE=$((SCORE + PTS))
echo "  score: $SCORE / $TOTAL"

# ============================================================
task 09 "tmpfiles and journald"
PASS=0
TF=$(grep -rl '/run/webapp' /etc/tmpfiles.d/ 2>/dev/null | head -1)
[ -n "$TF" ] && ok "tmpfiles.d config for /run/webapp" || { fail "no tmpfiles.d entry for /run/webapp"; PASS=1; }
grep -q 'tom' "${TF:-/dev/null}" && ok "owner tom in tmpfiles" || { fail "owner tom missing"; PASS=1; }
grep -qi 'SystemMaxUse.*200M\|SystemMaxUse.*200m' /etc/systemd/journald.conf 2>/dev/null && ok "journald max 200M" || { fail "journald SystemMaxUse not set"; PASS=1; }
[ $PASS -eq 0 ] && SCORE=$((SCORE + PTS))
echo "  score: $SCORE / $TOTAL"

# ============================================================
task 10 "Shell Script"
PASS=0
[ -x /usr/local/bin/batch_users.sh ] && ok "batch_users.sh executable" || { fail "batch_users.sh missing or not executable"; PASS=1; }
[ $PASS -eq 0 ] && SCORE=$((SCORE + PTS))
echo "  score: $SCORE / $TOTAL"

# ============================================================
task 11 "grep and Regex"
PASS=0
[ -f /tmp/security_report.txt ] && ok "/tmp/security_report.txt exists" || { fail "/tmp/security_report.txt missing"; PASS=1; }
[ -s /tmp/security_report.txt ] && ok "security_report.txt non-empty" || { fail "security_report.txt empty"; PASS=1; }
[ $PASS -eq 0 ] && SCORE=$((SCORE + PTS))
echo "  score: $SCORE / $TOTAL"

# ============================================================
task 12 "Process Management"
PASS=0
[ -f /tmp/zombie_explain.txt ] && ok "/tmp/zombie_explain.txt exists" || { fail "/tmp/zombie_explain.txt missing"; PASS=1; }
grep -qi 'zombie\|parent\|wait\|SIGCHLD' /tmp/zombie_explain.txt 2>/dev/null && ok "zombie explanation adequate" || { fail "zombie explanation incomplete"; PASS=1; }
[ $PASS -eq 0 ] && SCORE=$((SCORE + PTS))
echo "  score: $SCORE / $TOTAL"

# ============================================================
task 13 "Tuning"
PASS=0
[ -d /etc/tuned/rhcsa-custom ] && ok "tuned profile rhcsa-custom exists" || { fail "tuned profile rhcsa-custom missing"; PASS=1; }
tuned-adm active 2>/dev/null | grep -q 'rhcsa-custom' && ok "rhcsa-custom profile active" || { fail "rhcsa-custom not active"; PASS=1; }
sysctl vm.swappiness 2>/dev/null | grep -q '= 10' && ok "vm.swappiness = 10" || { fail "vm.swappiness != 10"; PASS=1; }
ls /etc/sysctl.d/ 2>/dev/null | grep -q '.' && ok "sysctl.d config present" || { fail "no sysctl.d config"; PASS=1; }
[ $PASS -eq 0 ] && SCORE=$((SCORE + PTS))
echo "  score: $SCORE / $TOTAL"

# ============================================================
task 14 "Firewalld"
PASS=0
firewall-cmd --list-rich-rules 2>/dev/null | grep -q '192.168.0.0/24' && ok "SSH rich rule 192.168.0.0/24" || { fail "SSH rich rule missing"; PASS=1; }
firewall-cmd --list-rich-rules 2>/dev/null | grep -q '10.0.0.99' && ok "block rule for 10.0.0.99" || { fail "block rule for 10.0.0.99 missing"; PASS=1; }
firewall-cmd --zone=internal --list-ports 2>/dev/null | grep -q '3306' && ok "3306/tcp in internal zone" || { fail "3306/tcp not in internal zone"; PASS=1; }
[ $PASS -eq 0 ] && SCORE=$((SCORE + PTS))
echo "  score: $SCORE / $TOTAL"

# ============================================================
task 15 "RPM"
PASS=0
ls /tmp/rpms/*.rpm 2>/dev/null | grep -q 'httpd' && ok "httpd RPM in /tmp/rpms/" || { fail "httpd RPM not in /tmp/rpms/"; PASS=1; }
rpm -q httpd &>/dev/null && ok "httpd installed" || { fail "httpd not installed"; PASS=1; }
[ $PASS -eq 0 ] && SCORE=$((SCORE + PTS))
echo "  score: $SCORE / $TOTAL"

# ============================================================
task 16 "Flatpak"
PASS=0
[ -f /tmp/flatpak_commands.txt ] && ok "/tmp/flatpak_commands.txt exists" || { fail "/tmp/flatpak_commands.txt missing"; PASS=1; }
grep -qi 'install\|remove\|uninstall' /tmp/flatpak_commands.txt 2>/dev/null && ok "commands documented" || { fail "commands not documented"; PASS=1; }
[ $PASS -eq 0 ] && SCORE=$((SCORE + PTS))
echo "  score: $SCORE / $TOTAL"

# ============================================================
task 17 "Scheduling"
PASS=0
atq 2>/dev/null | grep -q '.' && ok "at job pending" || { fail "no at job found"; PASS=1; }
crontab -u sara -l 2>/dev/null | grep -qE '30.*4.*1.*tmp\|4.*30.*Mon' && ok "sara cron Monday 04:30" || { fail "sara cron not found"; PASS=1; }
[ -f /etc/systemd/system/log_rotate.timer ] && ok "log_rotate.timer exists" || { fail "log_rotate.timer missing"; PASS=1; }
grep -q 'OnCalendar.*01.*03:00\|OnCalendar.*\*-\*-01' /etc/systemd/system/log_rotate.timer 2>/dev/null && ok "timer on 1st of month 03:00" || { fail "timer schedule incorrect"; PASS=1; }
[ $PASS -eq 0 ] && SCORE=$((SCORE + PTS))
echo "  score: $SCORE / $TOTAL"

# ============================================================
task 18 "DNS and Hostname"
PASS=0
hostname | grep -q 'rhcsa-srv3.prod.local' && ok "hostname correct" || { fail "hostname not rhcsa-srv3.prod.local"; PASS=1; }
grep -q 'db.prod.local' /etc/hosts && ok "db.prod.local in /etc/hosts" || { fail "db.prod.local missing"; PASS=1; }
grep -q 'app.prod.local' /etc/hosts && ok "app.prod.local in /etc/hosts" || { fail "app.prod.local missing"; PASS=1; }
[ -f /tmp/dns_order.txt ] && ok "/tmp/dns_order.txt exists" || { fail "/tmp/dns_order.txt missing"; PASS=1; }
[ $PASS -eq 0 ] && SCORE=$((SCORE + PTS))
echo "  score: $SCORE / $TOTAL"

# ============================================================
task 19 "autofs"
PASS=0
systemctl is-enabled autofs &>/dev/null && ok "autofs enabled" || { fail "autofs not enabled"; PASS=1; }
grep -q '/mnt/nfs' /etc/auto.master /etc/auto.master.d/*.autofs 2>/dev/null && ok "indirect map /mnt/nfs in master" || { fail "indirect map missing"; PASS=1; }
grep -rq '/direct/data\|/srv/share/rw' /etc/auto.master /etc/auto.master.d/ 2>/dev/null && ok "direct map /direct/data found" || { fail "direct map missing"; PASS=1; }
[ $PASS -eq 0 ] && SCORE=$((SCORE + PTS))
echo "  score: $SCORE / $TOTAL"

# ============================================================
task 20 "GRUB"
PASS=0
grep -q 'GRUB_TIMEOUT=5\|GRUB_TIMEOUT="5"' /etc/default/grub 2>/dev/null && ok "GRUB timeout 5s" || { fail "GRUB timeout not 5s"; PASS=1; }
grubby --info=DEFAULT 2>/dev/null | grep -qv 'mem=2G' && ok "mem=2G not present (correctly removed)" || { fail "mem=2G still present"; PASS=1; }
[ -f /tmp/grub_recovery.txt ] && ok "/tmp/grub_recovery.txt exists" || { fail "/tmp/grub_recovery.txt missing"; PASS=1; }
grep -qi 'rd.break\|rescue\|init=/bin/bash' /tmp/grub_recovery.txt 2>/dev/null && ok "recovery methods documented" || { fail "recovery file incomplete"; PASS=1; }
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
