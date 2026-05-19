# 🔴 RHCSA Mock Exam — #04
**Duration: 2h30 | RHEL 10 | SELinux enforcing | No external documentation**

> ⚠️ Every configuration must survive a `reboot`.
> ⚠️ SELinux must remain in `enforcing` mode.

---

## Task 01 — Users: Advanced Configuration

Create the group `auditors` (GID `7000`).
Create:
- `audit1`: UID `5001`, bash, primary group `auditors`, home `/audit/audit1`, password `Aud!t2026`
- `audit2`: same configuration, home `/audit/audit2`
- `readonly`: shell `/sbin/nologin`, home `/dev/null`, no supplementary group

Configure `/etc/skel` so that every new user automatically has:
- A `~/.bashrc` file with `alias ll='ls -alh'`
- A `~/scripts/` directory

Verify these elements are present for `audit1`.

---

## Task 02 — Sudo: Restrictions and Audit

1. Configure `audit1` to execute **only** commands in `/usr/sbin/` without password
2. Configure `audit2` to execute `journalctl` and `ausearch` without password
3. Prevent `audit2` from using `su` and `sudo` even if in a group that allows sudo
4. Verify with `sudo -l -U audit1` and `sudo -l -U audit2`

---

## Task 03 — find: Edge Cases

1. Find all files in `/etc/` where the **execute permission is set for others** (`-perm -o+x`)
2. Find files in `/home/` whose **access date** is older than **30 days** (`-atime +30`)
3. Find all `.log` files in `/var/log/` larger than **5M**, list them with their human-readable size (`-ls`)
4. Find files in `/tmp/` whose name contains a space (hint: `-name "* *"`)
5. Find all system files belonging to `audit1` **or** `audit2` in a single `find` command

---

## Task 04 — Combined Text Processing

1. Generate the list of the 10 processes consuming the most CPU with `ps`, extract PID and %CPU columns with `awk`, redirect to `/tmp/top_cpu.txt`
2. In `/etc/passwd`, use `sed` to delete all lines starting with `#` and blank lines → `/tmp/passwd_clean.txt`
3. Count the number of users with a valid shell (different from `/sbin/nologin` and `/bin/false`) with a `grep | wc` pipeline
4. Use `tr` to transform `/etc/hostname` to uppercase and display the result

---

## Task 05 — Storage: Advanced LVM + pvmove

On `/dev/sdb`:
1. Create PV, VG `vg_thin`, then LV `lv_main` of **6 GiB** in xfs on `/mnt/main`
2. Add a 2nd PV (`/dev/sdc`) to the VG
3. Move the Physical Extents from `/dev/sdb` to `/dev/sdc` with `pvmove` (without unmounting)
4. Remove `/dev/sdb` from the VG with `vgreduce`
5. Verify `/mnt/main` is still accessible and data is intact

---

## Task 06 — Filesystems: Labels and UUID

1. Create an ext4 partition on `/dev/sdd`, assign it the label `DATAPART`
2. Mount it via its **label** in `/etc/fstab` (syntax `LABEL=`)
3. Create an xfs partition on a 2nd space, assign it the label `XFSPART`
4. Verify the labels with `blkid` and `lsblk -f`
5. Mount both via `/etc/fstab` and verify persistence

---

## Task 07 — SELinux: Port + Boolean + Context Together

Complete scenario:
1. Install and configure `vsftpd` to serve files from `/srv/ftp/data/`
2. The service must listen on port **2121** (non-standard)
3. Apply the correct SELinux context on `/srv/ftp/data/`
4. Enable the SELinux boolean allowing FTP access to home directories
5. Open the port in firewalld and test with `curl ftp://localhost:2121`

---

## Task 08 — Systemd: Unit Paths and Conditions

1. Create a `watchdog.service` that checks every 30s whether `/var/run/app.pid` exists
2. If the file does not exist, the service writes an alert to `/var/log/watchdog.log`
3. Add a condition `ConditionPathExists=/etc/watchdog.conf` — the service only starts if this file exists
4. Create `/etc/watchdog.conf` with content `enabled=yes`
5. Enable the service and verify its behavior with `systemctl status`

---

## Task 09 — Logs: rsyslog + logrotate

1. Configure rsyslog to send **all** messages at level `crit` and above to `/var/log/critical.log`
2. Configure logrotate for this file: **daily** rotation, **7 days** retention, compression, no error if file is absent
3. Test the rotation manually with `logrotate -f`
4. Generate a test message with `logger -p kern.crit "CRITICAL TEST"` and verify it appears in `/var/log/critical.log`

---

## Task 10 — Script: System Report Generation

Write `/usr/local/bin/sysreport.sh` that generates a report in `/tmp/sysreport_$(date +%Y%m%d).txt` containing:
- Hostname and date
- Disk usage (all filesystems)
- The 5 processes consuming the most memory
- Number of logged-in users
- Status of services: `sshd`, `firewalld`, `chronyd`
- Return code `0` if all services are active, `1` otherwise

---

## Task 11 — Processes: cgroups and loginctl

1. List active sessions with `loginctl`
2. Identify the process consuming the most memory with `ps -eo pid,pmem,comm --sort=-pmem | head -5`
3. Change the priority of an `sshd` process to `nice -5` with `renice`
4. Terminate the `audit2` session with `loginctl terminate-user audit2`
5. Verify with `loginctl list-users`

---

## Task 12 — Chrony and Time

1. Check NTP synchronization status with `chronyc tracking`
2. Add the NTP server `0.fr.pool.ntp.org` in `/etc/chrony.conf`
3. Force an immediate sync with `chronyc makestep`
4. Configure the timezone `Europe/Paris` with `timedatectl`
5. Verify with `timedatectl status` and `chronyc sources`

---

## Task 13 — Flatpak: Override and Configuration

1. Install flatpak if absent
2. Add the system Flathub remote
3. List available applications in Flathub for the keyword `text editor`
4. For an installed Flatpak application (or simulate with an existing one), display its permissions with `flatpak info --show-permissions`
5. Document in `/tmp/flatpak_perms.txt`: how to restrict network permissions of a Flatpak app (`--no-share=network`)

---

## Task 14 — Network: Firewalld Zones and Interfaces

1. Assign the main network interface to the `trusted` zone
2. Assign a 2nd interface (or create a dummy connection) to the `public` zone
3. In the `public` zone: allow only SSH and HTTPS
4. In the `trusted` zone: allow all traffic
5. Make persistent and verify with `firewall-cmd --get-active-zones`

---

## Task 15 — RPM: Advanced Querying

1. List all installed packages whose name starts with `python` with `rpm -qa`
2. For each python package found, display its name and version with `rpm --qf`
3. Find which package provides `/usr/bin/python3` with `rpm -qf`
4. Check if a package contains post-install scripts with `rpm -q --scripts`
5. Export a complete inventory of installed packages (name + version + architecture) to `/tmp/pkg_inventory.txt`

---

## Task 16 — Links and SUID Permissions

1. Find all binaries with SUID in `/usr/bin/` and `/usr/sbin/`
2. Explain in `/tmp/suid_risk.txt` the security risk associated with SUID on a custom binary
3. Create a symbolic link `/usr/local/bin/ll` pointing to `/usr/bin/ls`
4. Create a hard link from `/etc/hosts` to `/tmp/hosts_backup`
5. Verify with `ls -li` that the inode is identical

---

## Task 17 — Scheduling: at + cron + timer Combined

1. Schedule with `at`: in **10 minutes**, run `rpm -Va > /tmp/rpm_verify.txt`
2. Create a system cron in `/etc/cron.d/` (not in crontab) to run `sync` every **5 minutes** as `root`
3. Create a timer `rpm_check.timer` that checks RPM integrity **every Sunday at 01:00** and writes the result to `/var/log/rpm_check.log`
4. Verify all scheduled jobs with `atq`, `crontab -l` and `systemctl list-timers`

---

## Task 18 — NFS: Mount Options

1. Export `/srv/nfs/soft` and `/srv/nfs/hard`
2. Mount `/srv/nfs/soft` with option `soft,timeo=30` (soft mount: fast failure)
3. Mount `/srv/nfs/hard` with option `hard,intr` (hard mount: uninterrupted retry)
4. Explain in `/tmp/nfs_options.txt` the difference between `soft` and `hard` and when to use each option

---

## Task 19 — autofs: Direct Map and Timeout

1. Configure autofs to mount `/srv/nfs/hard` on `/mnt/direct_hard` via direct map
2. Set an unmount timeout of **120 seconds** for this mount
3. Verify the mount appears on access and disappears after timeout
4. Check autofs logs with `journalctl -u autofs`

---

## Task 20 — Complete Failure Scenario

Simulation: root password is lost AND SELinux prevents a service from working correctly after files were moved.

1. Describe the complete `rd.break` procedure with `enforcing=0` in `/tmp/full_recovery.txt`
2. After resetting the password, explain why `touch /.autorelabel` is mandatory
3. Use `grubby` to add `enforcing=0` temporarily, reboot, then restore `enforcing=1`
4. Verify SELinux mode after reboot with `getenforce` and `sestatus`

---

*RHCSA EX200 Mock Exam — RHEL 10 — 2026*
