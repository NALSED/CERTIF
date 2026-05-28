# RHCSA Mock Exam — #02
**Duration: 2h30 | RHEL 10 | SELinux enforcing | No external documentation**

> Every configuration must survive a reboot.
> SELinux must remain in enforcing mode.

---

## Task 01 — Users, Groups and Password Policies

Create a group `devteam` with GID `5000`. Create user `dev1` with UID `3001`, bash shell, primary group `devteam` and password `Dev@2026`. Create user `dev2` with UID `3002`, same configuration. Create a system account `svc_app` with UID `3003`, shell `/sbin/nologin` and no home directory. Configure `dev1` so that the password must be changed every 60 days with a minimum of 5 days between changes and a warning 10 days before expiration. Set `dev2`'s account to expire on 2026-12-31.

---

## Task 02 — SSH Key-Based Access

Generate an ed25519 key pair for `dev1` without a passphrase, using the comment `dev1@lab`. Place the public key in `~dev1/.ssh/authorized_keys` with correct permissions. Verify that `ssh dev1@localhost` works without a password.

---

## Task 03 — Permissions and ACLs

Create `/projects/devteam/` owned by `root` with group `devteam` and permissions `rwxrws---` (sgid enabled). Use ACLs to grant `dev1` read, write and execute access, `dev2` read and execute access only, and no access to `svc_app`. Verify with `getfacl`.

---

## Task 04 — find

Find all files owned by group `devteam` under `/` and write the result to `/tmp/devteam_files.txt` (suppress stderr). Find all symbolic links in `/etc/` and display their target. Find files in `/var/log/` not modified for more than 30 days and larger than 1M. Find all files with exact permissions `644` in `/home/` and change them to `600` using `-exec`.

---

## Task 05 — Text Processing

List `/etc/passwd` sorted by UID in descending order and redirect to `/tmp/passwd_sorted.txt`. Extract only usernames whose shell is `/bin/bash` using `awk`. Replace all occurrences of `bash` with `sh` in a copy of the file at `/tmp/passwd_copy.txt` using `sed` without modifying the original. Count lines, words and characters in `/etc/passwd` in a single command and redirect to `/tmp/passwd_stats.txt`.

---

## Task 06 — Partitions and Swap

On `/dev/sdb`, create a GPT table, a 3 GiB xfs partition and a 1 GiB swap partition. Format each partition accordingly. Mount the first partition on `/mnt/part1` via UUID in `/etc/fstab` and activate swap via UUID in `/etc/fstab`.

---

## Task 07 — LVM Snapshot

On `/dev/sdc`, create a PV, a VG `vg_dev` and a LV `lv_code` of 3 GiB formatted as ext4 and mounted on `/mnt/code`. Create a test file `/mnt/code/testfile.txt` with the content `VERSION 1`. Create a 500 MiB snapshot named `lv_code_snap`. Modify the file to contain `VERSION 2`. Unmount `lv_code`, merge the snapshot with `lvconvert --merge`, remount and verify the file contains `VERSION 1`.

---

## Task 08 — SELinux: Full Diagnostic

Create `/opt/webapp/` and place an `index.html` file there with content `APP OK`. Change Apache's `DocumentRoot` to `/opt/webapp/` and start the service. It will fail due to SELinux. Diagnose the issue using `ausearch` or `sealert`, fix the context and verify with `curl http://localhost`.

---

## Task 09 — SELinux: Boolean and Port

Persistently enable the boolean that allows `httpd` to read files in user home directories. Configure `httpd` to listen on port 8080. Allow this port in SELinux and in firewalld. Verify with `curl http://localhost:8080`.

---

## Task 10 — Systemd: Service Override

Without modifying the original unit file of `sshd.service`, create an override that forces automatic restart on failure with a 15-second delay and limits restarts to 3 in 60 seconds. Verify with `systemctl cat sshd.service`.

---

## Task 11 — Journald

Configure `journald` so that logs persist after a reboot. Display logs from the current boot for the `sshd` service only. Display logs of priority `err` and above from the last 2 hours. Configure `rsyslog` to send all `authpriv` messages at level `warning` and above to `/var/log/auth_warn.log`.

---

## Task 12 — Processes and Priority

Launch `dd if=/dev/zero of=/dev/null` in the background with a nice value of 10. Find its PID, change its priority to -5 with `renice`, then terminate it with SIGTERM. Apply the tuned profile `throughput-performance` persistently.

---

## Task 13 — Scheduling

Create a timer `backup_home.timer` that triggers `backup_home.service` every day at 02:00. The service must archive `/home/` to `/backup/home_$(date +%Y%m%d).tar.gz`. Enable `Persistent=true` to catch up on missed executions. Add an anacron entry to run `/usr/local/bin/weekly_report.sh` every week (create the script with `echo "weekly report"` inside).

---

## Task 14 — Shell Script

Write `/usr/local/bin/disk_alert.sh` that iterates over all mount points. If any filesystem exceeds 80% usage, write `ALERT: /mount/point is at XX%` to `/var/log/disk_alert.log`. If no threshold is exceeded, write `OK - $(date)` to the log. Exit with code 0 if OK, code 1 if at least one alert. Schedule the script to run every hour for `root` via cron.

---

## Task 15 — Network

Using `nmcli`, configure a second network connection on interface `enp0s8` (or the second available interface) with static IP `10.0.0.10/24`, no gateway and DNS `10.0.0.1`. Add a static entry `10.0.0.1 internal.lab.local` to `/etc/hosts`. Verify with `ip a` and `ping internal.lab.local`.

---

## Task 16 — NFS Client

Export `/srv/exports/data` and `/srv/exports/homes` via NFS. Mount `/srv/exports/data` persistently on `/mnt/nfs_data` in `/etc/fstab` with options `nfs4,_netdev`. Configure autofs to automatically mount `/srv/exports/homes` under `/mnt/homes/` using a wildcard.

---

## Task 17 — RPM and DNF

Identify which package installed `/usr/bin/find` and list all its configuration files. Verify the package integrity with `rpm -V`. Find which package provides the `seinfo` command using `dnf`, install it and list the loaded SELinux modules with `seinfo -t | head -20`.

---

## Task 18 — Flatpak

For user `dev1`, add the Flathub remote in user mode with the name `flathub-user`. List all available remotes. Search for `org.inkscape.Inkscape` and display its information without installing it. Remove the `flathub-user` remote. Document the difference between a `--system` and `--user` remote in `/tmp/flatpak_diff.txt`.

---

## Task 19 — Hard and Symbolic Links

Create `/data/original.txt` containing `ORIGINAL CONTENT`. Create a hard link `/data/hardlink.txt` and a symbolic link `/data/symlink.txt` pointing to this file. Delete `/data/original.txt` and observe the behavior of each link. Find all files sharing the same inode as `/data/hardlink.txt` and write your observations to `/tmp/links_obs.txt`.

---

## Task 20 — System Troubleshooting

Configure the system to boot into `multi-user.target` by default. Use `grubby` to remove the `quiet` argument from the default kernel. Display the last 20 lines of the boot journal with `journalctl -b`. Identify and mask a service of your choice, justifying your decision in `/tmp/mask_justif.txt`.

---

*RHCSA EX200 Mock Exam — RHEL 10 — 2026*
