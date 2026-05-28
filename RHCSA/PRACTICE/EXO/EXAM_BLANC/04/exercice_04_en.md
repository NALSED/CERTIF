# RHCSA Mock Exam — #04
**Duration: 2h30 | RHEL 10 | SELinux enforcing | No external documentation**

> Every configuration must survive a reboot.
> SELinux must remain in enforcing mode.

---

## Task 01 — Users

Create a group `auditors` with GID `7000`. Create user `audit1` with UID `5001`, bash shell, primary group `auditors`, home `/audit/audit1` and password `Aud!t2026`. Create user `audit2` with the same configuration. Create a user `readonly` with shell `/sbin/nologin`, home `/dev/null` and no supplementary group. Configure `/etc/skel` so that every new user automatically has a `~/.bashrc` file with `alias ll='ls -alh'` and a `~/scripts/` directory. Verify these are present for `audit1`.

---

## Task 02 — Sudo

Configure `audit1` so that it can run any command in `/usr/sbin/` without a password. Configure `audit2` so that it can run `journalctl` and `ausearch` without a password. Prevent `audit2` from using `su` and `sudo` even if it belongs to a group that allows sudo. Verify with `sudo -l -U audit1` and `sudo -l -U audit2`.

---

## Task 03 — find

Find all files in `/etc/` where the execute permission is set for others. Find files in `/home/` whose access date is older than 30 days. Find all `.log` files in `/var/log/` larger than 5M and display them with their human-readable size. Find files in `/tmp/` whose name contains a space. Find all files on the system belonging to `audit1` or `audit2` in a single `find` command.

---

## Task 04 — Text Processing

Generate the list of the 10 processes consuming the most CPU using `ps`, extract the PID and %CPU columns with `awk` and redirect to `/tmp/top_cpu.txt`. Use `sed` to remove all comment lines and blank lines from `/etc/passwd` and save to `/tmp/passwd_clean.txt`. Count the number of users with a valid shell (not `/sbin/nologin` or `/bin/false`) using a `grep | wc` pipeline. Use `tr` to display the content of `/etc/hostname` in uppercase.

---

## Task 05 — LVM: pvmove

On `/dev/sdb`, create a PV, a VG `vg_thin` and a LV `lv_main` of 6 GiB in xfs mounted on `/mnt/main`. Add `/dev/sdc` as a second PV to the VG. Move the physical extents from `/dev/sdb` to `/dev/sdc` using `pvmove` without unmounting. Remove `/dev/sdb` from the VG with `vgreduce`. Verify `/mnt/main` is still accessible and data is intact.

---

## Task 06 — Filesystem Labels and UUID

Create an ext4 partition on `/dev/sdd` and assign it the label `DATAPART`. Create an xfs partition in a second space and assign it the label `XFSPART`. Mount both persistently in `/etc/fstab` using the `LABEL=` syntax. Verify the labels with `blkid` and `lsblk -f`.

---

## Task 07 — SELinux: Port, Boolean and Context

Install and configure `vsftpd` to serve files from `/srv/ftp/data/` on port 2121. Apply the correct SELinux context on `/srv/ftp/data/`. Enable the SELinux boolean that allows FTP access to home directories. Open port 2121 in firewalld and test with `curl ftp://localhost:2121`.

---

## Task 08 — Systemd: Conditions

Create a `watchdog.service` that checks every 30 seconds whether `/var/run/app.pid` exists and writes an alert to `/var/log/watchdog.log` if it does not. Add a `ConditionPathExists=/etc/watchdog.conf` directive so the service only starts if this file exists. Create `/etc/watchdog.conf` with content `enabled=yes`. Enable the service and verify its behavior.

---

## Task 09 — rsyslog and logrotate

Configure rsyslog to send all messages at level `crit` and above to `/var/log/critical.log`. Configure logrotate for this file with daily rotation, 7-day retention, compression and no error if the file is absent. Test the rotation manually and generate a test message with `logger -p kern.crit "CRITICAL TEST"` to verify it appears in the log.

---

## Task 10 — Shell Script

Write `/usr/local/bin/sysreport.sh` that generates a report in `/tmp/sysreport_$(date +%Y%m%d).txt` containing the hostname and date, disk usage of all filesystems, the 5 processes consuming the most memory, the number of logged-in users and the status of `sshd`, `firewalld` and `chronyd`. Exit with code 0 if all services are active, code 1 otherwise.

---

## Task 11 — Processes

List active sessions with `loginctl`. Identify the process consuming the most memory. Change the priority of an `sshd` process to nice -5 with `renice`. Terminate the `audit2` session with `loginctl terminate-user audit2` and verify with `loginctl list-users`.

---

## Task 12 — Chrony and Time

Check NTP synchronization status with `chronyc tracking`. Add the server `0.fr.pool.ntp.org` to `/etc/chrony.conf`. Force an immediate sync with `chronyc makestep`. Set the timezone to `Europe/Paris` with `timedatectl`. Verify with `timedatectl status` and `chronyc sources`.

---

## Task 13 — Flatpak

Ensure flatpak is installed and the Flathub system remote is added. List available applications matching the keyword `text editor`. For an installed Flatpak application, display its permissions with `flatpak info --show-permissions`. Document in `/tmp/flatpak_perms.txt` how to restrict network permissions of a Flatpak app using `--no-share=network`.

---

## Task 14 — Firewalld Zones

Assign the main network interface to the `trusted` zone and a second interface to the `public` zone. In the `public` zone, allow only SSH and HTTPS. In the `trusted` zone, allow all traffic. Make the configuration persistent and verify with `firewall-cmd --get-active-zones`.

---

## Task 15 — RPM

List all installed packages whose name starts with `python` and display their name and version using `rpm --qf`. Find which package provides `/usr/bin/python3`. Check if a package contains post-install scripts with `rpm -q --scripts`. Export a complete inventory of installed packages (name, version, architecture) to `/tmp/pkg_inventory.txt`.

---

## Task 16 — Links and SUID

Find all binaries with SUID set in `/usr/bin/` and `/usr/sbin/`. Explain the security risk of SUID on a custom binary in `/tmp/suid_risk.txt`. Create a symbolic link `/usr/local/bin/ll` pointing to `/usr/bin/ls`. Create a hard link from `/etc/hosts` to `/tmp/hosts_backup` and verify with `ls -li` that the inode is identical.

---

## Task 17 — Scheduling

Schedule an `at` job to run `rpm -Va > /tmp/rpm_verify.txt` in 10 minutes. Create a system cron in `/etc/cron.d/` to run `sync` every 5 minutes as `root`. Create a timer `rpm_check.timer` that checks RPM integrity every Sunday at 01:00 and writes the result to `/var/log/rpm_check.log`. Verify with `atq`, `crontab -l` and `systemctl list-timers`.

---

## Task 18 — NFS Mount Options

Export `/srv/nfs/soft` and `/srv/nfs/hard` via NFS. Mount `/srv/nfs/soft` with the `soft,timeo=30` option and `/srv/nfs/hard` with the `hard,intr` option. Explain in `/tmp/nfs_options.txt` the difference between soft and hard mounts and when to use each.

---

## Task 19 — autofs: Direct Map

Configure autofs to mount `/srv/nfs/hard` on `/mnt/direct_hard` via a direct map with an unmount timeout of 120 seconds. Verify that the mount appears on access and disappears after the timeout. Check autofs logs with `journalctl -u autofs`.

---

## Task 20 — Recovery Scenario

Describe the complete `rd.break` procedure for resetting the root password with `enforcing=0` and write the steps to `/tmp/full_recovery.txt`. Explain why `touch /.autorelabel` is mandatory after resetting the password. Use `grubby` to temporarily add `enforcing=0`, reboot, then restore `enforcing=1`. Verify the SELinux mode after reboot with `getenforce` and `sestatus`.

---

*RHCSA EX200 Mock Exam — RHEL 10 — 2026*
