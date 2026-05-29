#!/usr/bin/env bash
# ============================================================
# RHCSA Mock Exam #01 — Auto-correction script
# Score: /300 — Pass: 210
# ============================================================
clear

# --- root check ---
if [ "$(id -u)" -ne 0 ]; then
  echo "Run this script as root."
  exit 2
fi

# --- uptime check ---
uptime_min=$(awk '{ print int($1/60) }' /proc/uptime)
if [ "$uptime_min" -gt 5 ]; then
  echo -e "\e[5m\033[35m\033[1mWARNING\e[0m\033[0m  system has been up for more than 5 minutes."
  echo -e "\e[5m\033[35m\033[1mWARNING\e[0m\033[0m  reboot before running this script."
  echo -e "Reboot now? (yes/no)"
  read REBOOT
  [ "$REBOOT" = "yes" ] && reboot
else
  echo -e "System recently rebooted. Good, let's go."
fi

SCORE=0
TOTAL=300
PTS=15   # points per task (20 tasks × 15 = 300)

ok()   { echo -e "  \033[32m[OK]\033[0m   $1"; }
fail() { echo -e "  \033[31m[FAIL]\033[0m $1"; }
task() { echo -e "\n\033[1mchecking task $1 — $2\033[0m"; }

# ============================================================
task 01 "Users and Groups"
PASS=0
getent group ops | grep -q ':3100:' && ok "group ops GID 3100" || { fail "group ops GID 3100"; PASS=1; }
getent passwd anna | grep -q '1900' && ok "user anna UID 1900" || { fail "user anna UID 1900"; PASS=1; }
getent passwd anna | grep -q '/bin/bash' && ok "anna shell bash" || { fail "anna shell bash"; PASS=1; }
id anna 2>/dev/null | grep -q 'ops' && ok "anna in group ops" || { fail "anna in group ops"; PASS=1; }
getent passwd leo | grep -q '1901' && ok "user leo UID 1901" || { fail "user leo UID 1901"; PASS=1; }
getent passwd ghost | grep -qE '(/sbin/nologin|/bin/false)' && ok "ghost no shell" || { fail "ghost no shell"; PASS=1; }
passwd -S ghost 2>/dev/null | grep -qE '(L|LK)' && ok "ghost account locked" || { fail "ghost account locked"; PASS=1; }
chage -l anna 2>/dev/null | grep 'Maximum.*45' && ok "anna maxdays 45" || { fail "anna maxdays 45"; PASS=1; }
[ $PASS -eq 0 ] && SCORE=$((SCORE + PTS))
echo "  score: $SCORE / $TOTAL"

# ============================================================
task 02 "Sudo"
PASS=0
ls /etc/sudoers.d/ | grep -q '.' && ok "sudoers.d file exists" || { fail "no file in /etc/sudoers.d/"; PASS=1; }
grep -r 'leo' /etc/sudoers.d/ | grep -q 'NOPASSWD' && ok "leo NOPASSWD rule found" || { fail "leo NOPASSWD rule not found"; PASS=1; }
grep -r 'leo' /etc/sudoers.d/ | grep -q '!passwd.*root\|passwd.*!.*root\|Cmnd_Alias\|passwd .* root' \
  || grep -r 'leo' /etc/sudoers.d/ | grep -q 'passwd' && ok "passwd restriction present" || { fail "passwd root restriction missing"; PASS=1; }
[ $PASS -eq 0 ] && SCORE=$((SCORE + PTS))
echo "  score: $SCORE / $TOTAL"

# ============================================================
task 03 "Permissions"
PASS=0
[ -d /data/ops ] && ok "/data/ops exists" || { fail "/data/ops missing"; PASS=1; }
stat -c '%G' /data/ops 2>/dev/null | grep -q 'ops' && ok "group owner ops" || { fail "group owner not ops"; PASS=1; }
stat -c '%a' /data/ops 2>/dev/null | grep -qE '^[23][0-9]70$|^3770$|^2770$' && ok "permissions correct (rwxrws--T)" || { fail "permissions incorrect on /data/ops"; PASS=1; }
grep -r 'umask.*0027\|umask.*027' /home/anna/.bashrc /home/anna/.bash_profile /etc/profile.d/ 2>/dev/null | grep -q '.' \
  && ok "anna umask 0027 set" || { fail "anna umask 0027 not found"; PASS=1; }
[ $PASS -eq 0 ] && SCORE=$((SCORE + PTS))
echo "  score: $SCORE / $TOTAL"

# ============================================================
task 04 "find"
PASS=0
[ -f /tmp/find_anna.txt ] && ok "/tmp/find_anna.txt exists" || { fail "/tmp/find_anna.txt missing"; PASS=1; }
[ -f /tmp/find_suid.txt ] && ok "/tmp/find_suid.txt exists" || { fail "/tmp/find_suid.txt missing"; PASS=1; }
[ -s /tmp/find_suid.txt ] && ok "find_suid.txt non-empty" || { fail "find_suid.txt is empty"; PASS=1; }
[ $PASS -eq 0 ] && SCORE=$((SCORE + PTS))
echo "  score: $SCORE / $TOTAL"

# ============================================================
task 05 "Archiving"
PASS=0
[ -f /backup/conf_backup.tar.gz ] && ok "/backup/conf_backup.tar.gz exists" || { fail "archive not found"; PASS=1; }
tar -tzf /backup/conf_backup.tar.gz 2>/dev/null | grep -q 'ssh' && ok "archive contains ssh content" || { fail "ssh content missing from archive"; PASS=1; }
[ -f /tmp/restore/sshd_config ] && ok "sshd_config extracted to /tmp/restore/" || { fail "sshd_config not in /tmp/restore/"; PASS=1; }
[ $PASS -eq 0 ] && SCORE=$((SCORE + PTS))
echo "  score: $SCORE / $TOTAL"

# ============================================================
task 06 "LVM"
PASS=0
pvs 2>/dev/null | grep -q '/dev/sdb' && ok "PV on /dev/sdb" || { fail "no PV on /dev/sdb"; PASS=1; }
vgs 2>/dev/null | grep -q 'vg_prod' && ok "VG vg_prod exists" || { fail "VG vg_prod not found"; PASS=1; }
lvs 2>/dev/null | grep -q 'lv_data' && ok "LV lv_data exists" || { fail "LV lv_data not found"; PASS=1; }
mount | grep -q '/mnt/data' && ok "lv_data mounted on /mnt/data" || { fail "lv_data not mounted on /mnt/data"; PASS=1; }
grep -q '/mnt/data' /etc/fstab && ok "/mnt/data in fstab" || { fail "/mnt/data not in fstab"; PASS=1; }
blkid | grep -q 'xfs' && ok "filesystem is xfs" || { fail "xfs filesystem not found"; PASS=1; }
[ $PASS -eq 0 ] && SCORE=$((SCORE + PTS))
echo "  score: $SCORE / $TOTAL"

# ============================================================
task 07 "LVM Extension"
PASS=0
pvs 2>/dev/null | grep -q '/dev/sdc' && ok "PV on /dev/sdc" || { fail "no PV on /dev/sdc"; PASS=1; }
LVSIZE=$(lvdisplay /dev/vg_prod/lv_data 2>/dev/null | awk '/LV Size/ { print int($3) }')
[ "${LVSIZE:-0}" -ge 6 ] && ok "lv_data >= 6 GiB" || { fail "lv_data not extended to >= 6 GiB (found ${LVSIZE}G)"; PASS=1; }
df -h /mnt/data 2>/dev/null | grep -q '/mnt/data' && ok "filesystem still mounted after resize" || { fail "/mnt/data not accessible"; PASS=1; }
[ $PASS -eq 0 ] && SCORE=$((SCORE + PTS))
echo "  score: $SCORE / $TOTAL"

# ============================================================
task 08 "Swap"
PASS=0
SWAPUUID=$(blkid | awk '/swap/ && !/mapper/ { gsub(/"/,""); for(i=1;i<=NF;i++) if($i~/^UUID=/) print $i }' | head -1)
[ -n "$SWAPUUID" ] && ok "swap UUID found: $SWAPUUID" || { fail "no swap partition found"; PASS=1; }
grep -q 'swap' /etc/fstab && ok "swap in /etc/fstab" || { fail "swap not in /etc/fstab"; PASS=1; }
swapon --show | grep -q '.' && ok "swap active" || { fail "swap not active"; PASS=1; }
[ $PASS -eq 0 ] && SCORE=$((SCORE + PTS))
echo "  score: $SCORE / $TOTAL"

# ============================================================
task 09 "Apache and SELinux"
PASS=0
rpm -q httpd &>/dev/null && ok "httpd installed" || { fail "httpd not installed"; PASS=1; }
systemctl is-active httpd &>/dev/null && ok "httpd running" || { fail "httpd not running"; PASS=1; }
[ -f /webroot/index.html ] && ok "/webroot/index.html exists" || { fail "/webroot/index.html missing"; PASS=1; }
grep -q 'RHCSA OK' /webroot/index.html 2>/dev/null && ok "index.html content correct" || { fail "index.html content wrong"; PASS=1; }
ls -Z /webroot/ 2>/dev/null | grep -q 'httpd_sys_content_t' && ok "SELinux context correct on /webroot" || { fail "SELinux context wrong on /webroot"; PASS=1; }
curl -s http://localhost | grep -q 'RHCSA OK' && ok "curl http://localhost returns content" || { fail "curl http://localhost failed"; PASS=1; }
[ $PASS -eq 0 ] && SCORE=$((SCORE + PTS))
echo "  score: $SCORE / $TOTAL"

# ============================================================
task 10 "SSH Non-Standard Port"
PASS=0
grep -qE '^Port 2222' /etc/ssh/sshd_config && ok "Port 2222 in sshd_config" || { fail "Port 2222 not configured"; PASS=1; }
semanage port -l 2>/dev/null | grep ssh | grep -q '2222' && ok "SELinux allows port 2222" || { fail "SELinux not updated for port 2222"; PASS=1; }
firewall-cmd --list-ports 2>/dev/null | grep -q '2222/tcp' && ok "firewalld allows port 2222" || { fail "firewalld not updated for port 2222"; PASS=1; }
[ $PASS -eq 0 ] && SCORE=$((SCORE + PTS))
echo "  score: $SCORE / $TOTAL"

# ============================================================
task 11 "SELinux Boolean"
PASS=0
[ -f /tmp/selinux_bool.txt ] && ok "/tmp/selinux_bool.txt exists" || { fail "/tmp/selinux_bool.txt missing"; PASS=1; }
getsebool -a 2>/dev/null | grep -q 'httpd_can_network_connect.*on' && ok "httpd_can_network_connect is on" || { fail "httpd_can_network_connect not enabled"; PASS=1; }
[ $PASS -eq 0 ] && SCORE=$((SCORE + PTS))
echo "  score: $SCORE / $TOTAL"

# ============================================================
task 12 "Custom Service"
PASS=0
[ -f /etc/systemd/system/hello.service ] && ok "hello.service unit exists" || { fail "hello.service not found"; PASS=1; }
grep -q 'hello.sh' /etc/systemd/system/hello.service 2>/dev/null && ok "hello.service runs hello.sh" || { fail "hello.sh not referenced in unit"; PASS=1; }
grep -q 'Restart=' /etc/systemd/system/hello.service 2>/dev/null && ok "Restart directive found" || { fail "Restart directive missing"; PASS=1; }
systemctl is-enabled hello.service &>/dev/null && ok "hello.service enabled" || { fail "hello.service not enabled"; PASS=1; }
[ $PASS -eq 0 ] && SCORE=$((SCORE + PTS))
echo "  score: $SCORE / $TOTAL"

# ============================================================
task 13 "Systemd Timer"
PASS=0
[ -f /etc/systemd/system/clean_tmp.timer ] && ok "clean_tmp.timer exists" || { fail "clean_tmp.timer not found"; PASS=1; }
grep -qi 'OnUnitActiveSec.*30\|OnCalendar.*30' /etc/systemd/system/clean_tmp.timer 2>/dev/null && ok "timer interval 30 min" || { fail "timer interval not 30 min"; PASS=1; }
systemctl is-enabled clean_tmp.timer &>/dev/null && ok "clean_tmp.timer enabled" || { fail "clean_tmp.timer not enabled"; PASS=1; }
[ $PASS -eq 0 ] && SCORE=$((SCORE + PTS))
echo "  score: $SCORE / $TOTAL"

# ============================================================
task 14 "tmpfiles"
PASS=0
TF=$(grep -rl '/run/myapp' /etc/tmpfiles.d/ 2>/dev/null | head -1)
[ -n "$TF" ] && ok "tmpfiles.d entry for /run/myapp found" || { fail "no tmpfiles.d config for /run/myapp"; PASS=1; }
grep -q 'anna' "${TF:-/dev/null}" && ok "owner anna in tmpfiles config" || { fail "owner anna not set in tmpfiles config"; PASS=1; }
[ -d /run/myapp ] && ok "/run/myapp exists" || { fail "/run/myapp not created"; PASS=1; }
[ $PASS -eq 0 ] && SCORE=$((SCORE + PTS))
echo "  score: $SCORE / $TOTAL"

# ============================================================
task 15 "Scheduling"
PASS=0
crontab -u anna -l 2>/dev/null | grep -q '45.*23.*df' || crontab -u anna -l 2>/dev/null | grep -q '23.*45.*df' \
  && ok "anna cron job at 23:45" || { fail "anna cron at 23:45 not found"; PASS=1; }
atq 2>/dev/null | grep -q '.' && ok "at job pending" || { fail "no at job found"; PASS=1; }
[ $PASS -eq 0 ] && SCORE=$((SCORE + PTS))
echo "  score: $SCORE / $TOTAL"

# ============================================================
task 16 "Shell Script"
PASS=0
[ -x /usr/local/bin/user_report.sh ] && ok "user_report.sh exists and is executable" || { fail "user_report.sh missing or not executable"; PASS=1; }
/usr/local/bin/user_report.sh 2>/dev/null; RC=$?
[ $RC -eq 2 ] && ok "exit 2 when no argument" || { fail "wrong exit code with no argument (got $RC, want 2)"; PASS=1; }
/usr/local/bin/user_report.sh nonexistent_group_xyz 2>/dev/null; RC=$?
[ $RC -eq 1 ] && ok "exit 1 for non-existent group" || { fail "wrong exit code for missing group (got $RC, want 1)"; PASS=1; }
/usr/local/bin/user_report.sh ops 2>/dev/null | grep -q '|' && ok "output contains | separator" || { fail "output format incorrect"; PASS=1; }
[ $PASS -eq 0 ] && SCORE=$((SCORE + PTS))
echo "  score: $SCORE / $TOTAL"

# ============================================================
task 17 "Static Network"
PASS=0
ip a | grep -q '192.168.0.100' && ok "IP 192.168.0.100 configured" || { fail "IP 192.168.0.100 not found"; PASS=1; }
hostname | grep -q 'rhcsa-node1.lab.local' && ok "hostname correct" || { fail "hostname not rhcsa-node1.lab.local"; PASS=1; }
grep -q '1.1.1.1' /etc/resolv.conf 2>/dev/null && ok "DNS 1.1.1.1 configured" || { fail "DNS 1.1.1.1 not in resolv.conf"; PASS=1; }
[ $PASS -eq 0 ] && SCORE=$((SCORE + PTS))
echo "  score: $SCORE / $TOTAL"

# ============================================================
task 18 "NFS and autofs"
PASS=0
showmount -e localhost 2>/dev/null | grep -q '/srv/nfs/share' && ok "NFS export /srv/nfs/share found" || { fail "/srv/nfs/share not exported"; PASS=1; }
systemctl is-enabled autofs &>/dev/null && ok "autofs enabled" || { fail "autofs not enabled"; PASS=1; }
grep -q '/mnt/auto' /etc/auto.master /etc/auto.master.d/*.autofs 2>/dev/null && ok "autofs master entry found" || { fail "autofs master entry missing"; PASS=1; }
[ $PASS -eq 0 ] && SCORE=$((SCORE + PTS))
echo "  score: $SCORE / $TOTAL"

# ============================================================
task 19 "Flatpak"
PASS=0
flatpak remotes 2>/dev/null | grep -q 'flathub' && ok "flathub remote exists" || { fail "flathub remote not found"; PASS=1; }
flatpak remotes --system 2>/dev/null | grep -q 'flathub' && ok "flathub is system-wide" || { fail "flathub not system-wide"; PASS=1; }
[ -f /tmp/flatpak_setup.txt ] && ok "/tmp/flatpak_setup.txt exists" || { fail "/tmp/flatpak_setup.txt missing"; PASS=1; }
[ $PASS -eq 0 ] && SCORE=$((SCORE + PTS))
echo "  score: $SCORE / $TOTAL"

# ============================================================
task 20 "Root Password Recovery"
PASS=0
[ -f /tmp/rdbreak_procedure.txt ] && ok "/tmp/rdbreak_procedure.txt exists" || { fail "/tmp/rdbreak_procedure.txt missing"; PASS=1; }
grep -qi 'rd.break\|autorelabel\|chroot' /tmp/rdbreak_procedure.txt 2>/dev/null && ok "procedure contains key steps" || { fail "procedure incomplete"; PASS=1; }
grubby --info=DEFAULT 2>/dev/null | grep -q 'quiet' && ok "kernel arg quiet present" || { fail "kernel arg quiet not found"; PASS=1; }
[ $PASS -eq 0 ] && SCORE=$((SCORE + PTS))
echo "  score: $SCORE / $TOTAL"

# ============================================================
# SELinux penalty
if getenforce | grep -qiE 'Permissive|Disabled'; then
  echo -e "\n  \033[31m[PENALTY]\033[0m SELinux not in enforcing mode — minus 60 points"
  SCORE=$((SCORE - 60))
fi

# ============================================================
echo -e "\n========================================"
echo -e "  Final score: \033[1m$SCORE / $TOTAL\033[0m"
if [ "$SCORE" -ge 210 ]; then
  echo -e "  \033[32mEXAMEN BLANC RÉUSSI — PASS\033[0m"
else
  echo -e "  \033[31mEXAMEN BLANC RATÉ — FAIL\033[0m  (need 210, got $SCORE)"
fi
echo "========================================"
