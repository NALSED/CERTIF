# RHCSA Mock Exam — #03
**Duration: 2h30 | RHEL 10 | SELinux enforcing | No external documentation**

---

## Task 01 — Users and Groups

Create groups `webadmin` (GID `6000`) and `dba` (GID `6001`). Create user `tom` (UID `4001`, bash, secondary groups `webadmin` and `dba`, password `T0mPwd#`) and `sara` (UID `4002`, bash, secondary group `webadmin`, same password). Create a system account `batch` with no interactive shell and home `/var/lib/batch`. Ensure new files created by `tom` automatically belong to the `dba` group.

---

## Task 02 — SSH Hardening

Disable root login via SSH. Restrict SSH access to `tom` and `sara` only. Move SSH to port `2200`. Disable password authentication. Generate a key for `sara` and verify the connection works.

---

## Task 03 — find

Find all files with no owner on the system and save to `/tmp/orphans.txt`. Find `.conf` files in `/etc/` modified in the last 48 hours. Find the 5 largest files in `/var/`. Find executable files in `/usr/local/bin/` and copy them to `/tmp/local_bins/`. Find all SGID files on the system and save to `/tmp/sgid_files.txt`.

---

## Task 04 — Archiving

Create a full archive of `/etc/` in `/backup/etc_full.tar.xz`. Explain why appending to a `.tar.xz` is not supported. Extract `/etc/httpd/conf/httpd.conf` into `/tmp/restore/` and compare it to the original.

---

## Task 05 — LVM

On `/dev/sdb`, create VG `vg_test` with two LVs: `lv_a` (2G, ext4) and `lv_b` (2G, ext4), mounted persistently. Fill `lv_a` with a 100M file. Reduce `lv_a` to 1G and verify data is intact.

---

## Task 06 — NFS

Configure the machine as both NFS server and client. Export `/srv/share/ro` read-only and `/srv/share/rw` read-write. Mount both persistently with appropriate options.

---

## Task 07 — SELinux Troubleshooting

Configure nginx to serve from `/data/nginx/html/`. Start it without fixing the SELinux context first, diagnose the failure, then fix it properly.

---

## Task 08 — Systemd Units

Create `monitor.service` (type `forking`) running `/usr/local/bin/monitor.sh` in the background. Create `cleanup.service` depending on it. Create `cleanup.timer` triggering `cleanup.service` hourly.

---

## Task 09 — tmpfiles and journald

Create `/run/webapp/` (mode `0755`, owner `tom`) and `/run/webapp/status` via `tmpfiles.d` with 7-day cleanup. Limit journal storage to 200M and retention to 4 weeks.

---

## Task 10 — Shell Script

Write `/usr/local/bin/batch_users.sh` that reads a file (`username:password:group` per line) and creates each user and group. Print `SKIP: <user> already exists` for duplicates. Print a final summary and exit 1 if any user was skipped.

---

## Task 11 — grep and Regex

Find users in `/etc/passwd` with UID between 1000 and 9999. Count failed login attempts per user from `/var/log/secure`. Write results to `/tmp/security_report.txt`.

---

## Task 12 — Process Management

Explain zombie processes in `/tmp/zombie_explain.txt`. Launch 3 instances of `sleep 3600` and kill them all in a single command.

---

## Task 13 — Tuning

Create a custom tuned profile `rhcsa-custom` inheriting `throughput-performance` with `vm.swappiness=10`. Apply it. Also set `vm.swappiness=10` persistently via `/etc/sysctl.d/`.

---

## Task 14 — Firewalld

Allow SSH only from `192.168.0.0/24` using a rich rule. Block `10.0.0.99` completely. Open `3306/tcp` in the `internal` zone. Make all rules persistent.

---

## Task 15 — RPM

Install `httpd`, download its RPM to `/tmp/rpms/` without installing, inspect it, then uninstall and reinstall from the local RPM.

---

## Task 16 — Flatpak

Add the Flathub system remote. Search for `org.libreoffice.LibreOffice` and document its install and removal commands in `/tmp/flatpak_commands.txt` without installing it.

---

## Task 17 — Scheduling

Schedule `uptime` to run tomorrow at 08:00 via `at` and write output to `/tmp/uptime_report.txt`. Create a cron for `sara` to delete `*.tmp` files every Monday at 04:30. Create a systemd timer `log_rotate.timer` running `logrotate -f /etc/logrotate.conf` on the 1st of every month at 03:00.

---

## Task 18 — DNS and Hostname

Set hostname to `rhcsa-srv3.prod.local`. Add `db.prod.local` and `app.prod.local` entries to `/etc/hosts`. Configure DNS via `nmcli`. Explain the resolution order in `/tmp/dns_order.txt`.

---

## Task 19 — autofs

Configure autofs with an indirect map to mount the NFS exports from Task 06 under `/mnt/nfs/`. Add a direct map mounting `/srv/share/rw` on `/direct/data`.

---

## Task 20 — GRUB

Set GRUB timeout to 5 seconds. Add kernel argument `mem=2G` with `grubby`, verify it, then remove it immediately. Explain the differences between `rd.break`, `init=/bin/bash` and `systemd.unit=rescue.target` in `/tmp/grub_recovery.txt`.

---

*RHCSA EX200 Mock Exam — RHEL 10 — 2026*
