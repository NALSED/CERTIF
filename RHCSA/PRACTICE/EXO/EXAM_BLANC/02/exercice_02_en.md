# 🔴 RHCSA Mock Exam — #02
**Duration: 2h30 | RHEL 10 | SELinux enforcing | No external documentation**

> ⚠️ Every configuration must survive a `reboot`.
> ⚠️ SELinux must remain in `enforcing` mode.

---

## Task 01 — Users, Groups and Password Policies

Create the group `devteam` with GID `5000`.
Create:
- `dev1`: UID `3001`, bash, primary group `devteam`, password `Dev@2026`
- `dev2`: UID `3002`, bash, primary group `devteam`, password `Dev@2026`
- `svc_app`: UID `3003`, shell `/sbin/nologin`, no home directory, system account

Policies:
- `dev1`: password must be changed every **60 days**, minimum **5 days** between changes, warning **10 days** before
- `dev2`: account expires on **2026-12-31**

---

## Task 02 — SSH Key-Based Access

Generate an `ed25519` key pair for `dev1` (no passphrase, comment `dev1@lab`).
Copy the public key into `~dev1/.ssh/authorized_keys` with correct permissions.
Verify that `ssh dev1@localhost` works without a password.

---

## Task 03 — Permissions and ACLs

Create `/projects/devteam/`:
- Owner `root`, group `devteam`
- Permissions: `rwxrws---` with sgid
- `dev1` can read, write and execute
- `dev2` can read and execute but not write
- `svc_app` has no access

Use ACLs (`setfacl`) for fine-grained control. Verify with `getfacl`.

---

## Task 04 — Advanced find

1. Find all files owned by group `devteam` under `/` → `/tmp/devteam_files.txt` (stderr suppressed)
2. Find all symbolic links in `/etc/` and display their target with `-printf "%p -> %l\n"`
3. Find files in `/var/log/` **not modified for more than 30 days** and larger than **1M**
4. Find all files with exact permissions `644` in `/home/`
5. Run `chmod 600` on all files found in task 4 using `-exec`

---

## Task 05 — Redirections and Text Processing

1. List `/etc/passwd` sorted by UID (field 3) in descending order → `/tmp/passwd_sorted.txt`
2. Extract only usernames whose shell is `/bin/bash` from `/etc/passwd` using `awk`
3. Replace all occurrences of `bash` with `sh` in a copy `/tmp/passwd_copy.txt` using `sed` (without modifying the original)
4. Count the number of lines, words and characters in `/etc/passwd` in a single command, redirect to `/tmp/passwd_stats.txt`

---

## Task 06 — Storage: Partitions and Swap

On `/dev/sdb`:
1. Create a GPT table
2. Partition 1: **3 GiB** (xfs type)
3. Partition 2: **1 GiB** (swap type)
4. Format each partition according to its type
5. Mount partition 1 on `/mnt/part1` via UUID in `/etc/fstab`
6. Activate swap via UUID in `/etc/fstab`

---

## Task 07 — LVM + Logical Snapshot

On `/dev/sdc`:
1. Create a PV, VG `vg_dev`, LV `lv_code` of **3 GiB** in ext4 mounted on `/mnt/code`
2. Create a test file `/mnt/code/testfile.txt` with content `VERSION 1`
3. Create a snapshot `lv_code_snap` of **500 MiB**
4. Modify `/mnt/code/testfile.txt` with `VERSION 2`
5. Unmount `lv_code`, run `lvconvert --merge` to restore the snapshot, remount and verify the file contains `VERSION 1`

---

## Task 08 — SELinux: Full Diagnostic

Create the directory `/opt/webapp/` and place `index.html` there with content `APP OK`.
Without modifying the Apache config, only change `DocumentRoot` to `/opt/webapp/`.
Start Apache. It will fail due to SELinux.
Diagnose with `ausearch` and/or `sealert`, fix the context, verify with `curl http://localhost`.

---

## Task 09 — SELinux: Boolean + Port

1. Persistently enable the boolean allowing `httpd` to read files in user home directories
2. Configure `httpd` to listen on port **8080**
3. Add this port in SELinux (`http_port_t`) and in firewalld
4. Verify with `curl http://localhost:8080`

---

## Task 10 — Systemd: Override an Existing Service

Without modifying the original unit file of `sshd.service`:
1. Create an override that forces automatic restart on failure with a delay of **15 seconds**
2. Limit the number of restarts to **3** in **60 seconds** (`StartLimitIntervalSec`, `StartLimitBurst`)
3. Verify with `systemctl cat sshd.service`

---

## Task 11 — Journald: Persistence and Filtering

1. Configure `journald` so that logs are **persistent** after reboot
2. Display only logs from the **current boot** from the `sshd` service
3. Display logs of **priority err and above** from the last 2 hours
4. Configure `rsyslog` to send all messages of facility `authpriv` at level `warning` and above to `/var/log/auth_warn.log`

---

## Task 12 — Processes and Priority

1. Launch `dd if=/dev/zero of=/dev/null` in the background with a `nice` value of **10**
2. Find its PID with `ps` and display its nice value
3. Change its priority to **-5** with `renice` (requires root)
4. Kill the process cleanly with `SIGTERM`, then verify it is dead
5. Apply the tuned profile `throughput-performance` persistently

---

## Task 13 — Scheduling: systemd timer + anacron

1. Create a timer `backup_home.timer` that triggers `backup_home.service` every day at **02:00**
2. The service archives `/home/` to `/backup/home_$(date +%Y%m%d).tar.gz`
3. Enable `Persistent=true` to catch up on missed executions
4. Add an `anacron` entry to run `/usr/local/bin/weekly_report.sh` every **week** (create the script with `echo "weekly report"` inside)

---

## Task 14 — Advanced Shell Script

Write `/usr/local/bin/disk_alert.sh`:
- Iterates over all mount points with `df`
- If a filesystem exceeds **80% usage** → writes to `/var/log/disk_alert.log`: `ALERT: /mount/point is at XX%`
- If no threshold exceeded → writes `OK - $(date)` to the log
- Exits with code `0` if OK, code `1` if at least one alert

Schedule this script via cron every hour for `root`.

---

## Task 15 — Network: Dual Interface and Routing

Configure a second network connection with `nmcli`:
- Interface `enp0s8` (or second available interface)
- Static IP: `10.0.0.10/24`
- No gateway on this interface
- DNS: `10.0.0.1`
- Add a static entry in `/etc/hosts`: `10.0.0.1 internal.lab.local`

Verify with `ip a` and `ping internal.lab.local`.

---

## Task 16 — NFS Client

On the server (localhost loopback):
1. Export `/srv/exports/data` and `/srv/exports/homes`
2. On the client (same machine), mount `/srv/exports/data` on `/mnt/nfs_data` **persistently** in `/etc/fstab` with options `nfs4,_netdev`
3. Configure autofs to automatically mount `/srv/exports/homes` under `/mnt/homes/` with the wildcard `*`

---

## Task 17 — RPM and DNF

1. Identify which package installed the file `/usr/bin/find`
2. List all configuration files installed by that package
3. Verify the integrity of that package with `rpm -V`
4. Search with `dnf` which package provides the `seinfo` command
5. Install that package and list loaded SELinux modules with `seinfo -t | head -20`

---

## Task 18 — Advanced Flatpak

1. Add the Flathub remote in **user** mode for `dev1` with the name `flathub-user`
2. List all available remotes (system + user)
3. Search for `org.inkscape.Inkscape` and display its information without installing
4. Remove the `flathub-user` remote added for `dev1`
5. Document the difference between a `--system` and `--user` remote in `/tmp/flatpak_diff.txt`

---

## Task 19 — Hard and Symbolic Links

1. Create `/data/original.txt` containing `ORIGINAL CONTENT`
2. Create a hard link `/data/hardlink.txt` to this file
3. Create a symbolic link `/data/symlink.txt` to `/data/original.txt`
4. Delete `/data/original.txt` and observe the behavior of each link
5. Find with `find` all files having the same inode as `/data/hardlink.txt`
6. Write your observations in `/tmp/links_obs.txt`

---

## Task 20 — System Troubleshooting

1. Configure the system to boot by default into `multi-user.target`
2. Use `grubby` to remove the `quiet` argument from the default kernel
3. Add the argument `systemd.log_level=debug` temporarily (not persistent)
4. Display the last 20 lines of the boot journal with `journalctl -b`
5. Identify and disable (mask) a useless service of your choice, justifying in `/tmp/mask_justif.txt`

---

*RHCSA EX200 Mock Exam — RHEL 10 — 2026*
