# RHCSA Mock Exam — #02
**Duration: 2h30 | RHEL 10 | SELinux enforcing | No external documentation**

---

## Task 01 — Users and Groups

Create a group `devteam` with GID `5000`. Create users `dev1` (UID `3001`, bash, primary group `devteam`, password `Dev@2026`) and `dev2` (UID `3002`, same setup). Create a system account `svc_app` (UID `3003`, no interactive shell, no home directory). Set `dev1`'s password to expire every 60 days with a 5-day minimum between changes and a 10-day warning. Set `dev2`'s account to expire on 2026-12-31.

---

## Task 02 — SSH Key Access

Generate an ed25519 key pair for `dev1` (no passphrase, comment `dev1@lab`) and configure passwordless SSH to localhost.

---

## Task 03 — Permissions and ACLs

Create `/projects/devteam/` owned by `root:devteam` with sgid and permissions `rwxrws---`. Grant `dev1` full access, `dev2` read and execute only, and no access to `svc_app` using ACLs.

---

## Task 04 — find

Find all files owned by group `devteam` under `/` and save to `/tmp/devteam_files.txt`. Find symlinks in `/etc/` and display their targets. Find files in `/var/log/` older than 30 days and larger than 1M. Find files with exact permissions `644` in `/home/` and change them to `600`.

---

## Task 05 — Text Processing

Sort `/etc/passwd` by UID descending into `/tmp/passwd_sorted.txt`. Extract usernames with `/bin/bash` shell using `awk`. Replace `bash` with `sh` in a copy at `/tmp/passwd_copy.txt` using `sed`. Count lines, words and characters of `/etc/passwd` into `/tmp/passwd_stats.txt`.

---

## Task 06 — Partitions and Swap

On `/dev/sdb`, create a GPT table with a 3 GiB xfs partition mounted on `/mnt/part1` and a 1 GiB swap partition, both persistent via UUID in `/etc/fstab`.

---

## Task 07 — LVM Snapshot

On `/dev/sdc`, create VG `vg_dev` and LV `lv_code` (3 GiB, ext4, mounted on `/mnt/code`). Create a file with content `VERSION 1`. Snapshot it, modify the file to `VERSION 2`, then restore the snapshot and verify the file reads `VERSION 1`.

---

## Task 08 — Apache and SELinux

Serve content from `/opt/webapp/` (containing `index.html` with `APP OK`) using Apache. Do not modify the default SELinux context before starting — diagnose and fix the resulting failure.

---

## Task 09 — SELinux Boolean and Port

Allow `httpd` to read user home directories. Configure `httpd` to listen on port `8080`.

---

## Task 10 — Systemd Override

Without touching the original unit file, override `sshd.service` to restart automatically on failure after 15 seconds, with a maximum of 3 restarts in 60 seconds.

---

## Task 11 — Journald

Make journal logs persistent across reboots. Configure `rsyslog` to send `authpriv.warning` and above to `/var/log/auth_warn.log`.

---

## Task 12 — Process Priority

Launch `dd if=/dev/zero of=/dev/null` in the background with nice value `10`, change its priority to `-5`, then terminate it cleanly. Apply the `throughput-performance` tuned profile persistently.

---

## Task 13 — Scheduling

Create a timer `backup_home.timer` that archives `/home/` daily at 02:00, with `Persistent=true`. Add an anacron entry to run `/usr/local/bin/weekly_report.sh` every week.

---

## Task 14 — Shell Script

Write `/usr/local/bin/disk_alert.sh` that logs `ALERT: /mount is at XX%` to `/var/log/disk_alert.log` for any filesystem exceeding 80% usage, or `OK - date` otherwise. Schedule it hourly for root via cron.

---

## Task 15 — Network

Add a second connection on `enp0s8` with static IP `10.0.0.10/24`, no gateway, DNS `10.0.0.1`. Add `10.0.0.1 internal.lab.local` to `/etc/hosts`.

---

## Task 16 — NFS Client

Export `/srv/exports/data` and `/srv/exports/homes`. Mount `data` persistently on `/mnt/nfs_data` with options `nfs4,_netdev`. Configure autofs to mount `homes` on demand under `/mnt/homes/`.

---

## Task 17 — RPM and DNF

Identify the package that owns `/usr/bin/find` and verify its integrity. Find and install the package that provides the `seinfo` command.

---

## Task 18 — Flatpak

For user `dev1`, add Flathub in user mode as `flathub-user`. Document the difference between `--system` and `--user` remotes in `/tmp/flatpak_diff.txt`. Remove the remote afterwards.

---

## Task 19 — Hard and Symbolic Links

Create `/data/original.txt` with content `ORIGINAL CONTENT`. Create a hard link and a symbolic link to it. Delete the original and observe the behavior of each. Write your observations to `/tmp/links_obs.txt`.

---

## Task 20 — System Troubleshooting

Set the system to boot into `multi-user.target` by default. Mask a service of your choice and justify in `/tmp/mask_justif.txt`.

---

*RHCSA EX200 Mock Exam — RHEL 10 — 2026*
