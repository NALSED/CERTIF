# RHCSA Mock Exam — #04
**Duration: 2h30 | RHEL 10 | SELinux enforcing | No external documentation**

> Copy the correction script `exam04_check.sh` to **server1** and run it as root from **server1**.
> The script connects to server2 via SSH to verify remote tasks — passwordless root SSH from server1 to server2 is required.

---

## Task 01 — Users
`🖥 server2`

Create group `auditors` (GID `7000`). Create users `audit1` and `audit2` (UID `5001`/`5002`, bash, primary group `auditors`, home `/audit/auditX`, password `Aud!t2026`). Create user `readonly` with no interactive shell, home `/dev/null` and no supplementary groups. Configure `/etc/skel` to provide all new users with `alias ll='ls -alh'` in `.bashrc` and a `scripts/` directory.

---

## Task 02 — Sudo
`🖥 server2`

Allow `audit1` to run any command in `/usr/sbin/` without a password. Allow `audit2` to run `journalctl` and `ausearch` only, without a password. Prevent `audit2` from using `su` or `sudo` regardless of group membership.

---

## Task 03 — find
`🖥 server1`

Find files in `/etc/` with execute permission set for others. Find files in `/home/` not accessed in over 30 days. Find `.log` files larger than 5M in `/var/log/` and display their size. Find files in `/tmp/` whose name contains a space. Find all files belonging to `audit1` or `audit2` in a single command.

---

## Task 04 — Text Processing
`🖥 server1`

List the 10 most CPU-intensive processes, extract PID and %CPU into `/tmp/top_cpu.txt`. Strip comments and blank lines from `/etc/passwd` into `/tmp/passwd_clean.txt` using `sed`. Count users with a valid login shell. Display `/etc/hostname` in uppercase using `tr`.

---

## Task 05 — LVM: pvmove
`🖥 server1`

On `/dev/sdb`, create VG `vg_thin` and LV `lv_main` (6 GiB, xfs, mounted on `/mnt/main`). Add `/dev/sdc` to the VG, move all extents from `/dev/sdb` to `/dev/sdc` without unmounting, then remove `/dev/sdb` from the VG.

---

## Task 06 — Filesystem Labels
`🖥 server1`

Create an ext4 partition on `/dev/sdd` labeled `DATAPART` and an xfs partition labeled `XFSPART`. Mount both persistently using `LABEL=` syntax in `/etc/fstab`.

---

## Task 07 — vsftpd and SELinux
`🖥 server2`

Install and configure `vsftpd` to serve `/srv/ftp/data/` on port `2121`. Enable the appropriate SELinux boolean for home directory access.

---

## Task 08 — Systemd Conditions
`🖥 server1`

Create `watchdog.service` that writes an alert to `/var/log/watchdog.log` if `/var/run/app.pid` does not exist. The service must not start unless `/etc/watchdog.conf` exists. Create that file with `enabled=yes`.

---

## Task 09 — rsyslog and logrotate
`🖥 server1`

Send all messages at level `crit` and above to `/var/log/critical.log`. Configure logrotate for daily rotation, 7-day retention and compression. Generate a test message with `logger` and verify it appears in the log.

---

## Task 10 — Shell Script
`🖥 server1`

Write `/usr/local/bin/sysreport.sh` generating a report in `/tmp/sysreport_$(date +%Y%m%d).txt` with hostname, disk usage, top 5 memory processes, logged-in user count and status of `sshd`, `firewalld` and `chronyd`. Exit 1 if any service is not active.

---

## Task 11 — Processes
`🖥 server2`

Identify the most memory-intensive process. Change the nice value of an `sshd` process to `-5`. Terminate the `audit2` session using `loginctl`.

---

## Task 12 — Chrony
`🖥 server1` and `🖥 server2`

Add `0.fr.pool.ntp.org` as an NTP source and force an immediate sync. Set the timezone to `Europe/Paris`.

---

## Task 13 — Flatpak
`🖥 server1`

Add the Flathub system remote. Display permissions for an installed Flatpak app. Document how to restrict network access with `--no-share=network` in `/tmp/flatpak_perms.txt`.

---

## Task 14 — Firewalld Zones
`🖥 server2`

Assign the main interface to the `trusted` zone and a second interface to the `public` zone. In `public`, allow SSH and HTTPS only. Make persistent.

---

## Task 15 — RPM
`🖥 server1`

List all installed packages starting with `python` with their version. Find which package provides `/usr/bin/python3`. Export a full inventory of installed packages to `/tmp/pkg_inventory.txt`.

---

## Task 16 — SUID and Links
`🖥 server1`

Find all SUID binaries in `/usr/bin/` and `/usr/sbin/`. Explain the security risk in `/tmp/suid_risk.txt`. Create a hard link from `/etc/hosts` to `/tmp/hosts_backup`.

---

## Task 17 — Scheduling
`🖥 server1`

Schedule `rpm -Va > /tmp/rpm_verify.txt` to run in 10 minutes via `at`. Create a system cron in `/etc/cron.d/` to run `sync` every 5 minutes as root. Create `rpm_check.timer` to run an RPM integrity check every Sunday at 01:00 and log to `/var/log/rpm_check.log`.

---

## Task 18 — NFS Mount Options
`🖥 server2` — NFS server | `🖥 server1` — client

On server2, export `/srv/nfs/soft` and `/srv/nfs/hard`. On server1, mount `soft` with `soft,timeo=30` and `hard` with `hard,intr`. Explain the difference in `/tmp/nfs_options.txt`.

---

## Task 19 — autofs Direct Map
`🖥 server1` — autofs client (mounts from server2)

Mount `/srv/nfs/hard` (exported by server2) on `/mnt/direct_hard` via autofs direct map with a 120-second timeout.

---

## Task 20 — Recovery
`🖥 server1`

Describe the full `rd.break` + `enforcing=0` recovery procedure in `/tmp/full_recovery.txt`. Explain why `touch /.autorelabel` is required. Verify SELinux mode after reboot.

---

*RHCSA EX200 Mock Exam — RHEL 10 — 2026*
