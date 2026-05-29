# RHCSA Mock Exam — #01
**Duration: 2h30 | RHEL 10 | SELinux enforcing | No external documentation**

> Copy the correction script `exam01_check.sh` to **server1** and run it as root from **server1**.
> The script connects to server2 via SSH to verify remote tasks — passwordless root SSH from server1 to server2 is required.

---

## Task 01 — Users and Groups
`🖥 server1`

Create a group `ops` with GID `3100`. Create users `anna` (UID `1900`, bash, secondary group `ops`, password `R3dHat!`) and `leo` (UID `1901`, same config). Create user `ghost` with no interactive shell and a locked account. Set `anna`’s password to expire in 45 days with a 5-day warning and account disabled 7 days after expiration.

---

## Task 02 — Sudo
`🖥 server1`

Allow `leo` to run `useradd`, `usermod`, `userdel` and `passwd` as root without a password, except he must never be able to change `root`’s password. Use a file in `/etc/sudoers.d/`.

---

## Task 03 — Permissions
`🖥 server1`

Create `/data/ops/` owned by `root:ops`, with full access for owner and group, no access for others, sgid set, and sticky bit active. Set `anna`’s default umask to `0027` persistently.

---

## Task 04 — find
`🖥 server1`

Find all files owned by `anna` on the entire system and save to `/tmp/find_anna.txt`. Find all SUID files in `/usr/bin/` and save to `/tmp/find_suid.txt`. Find files in `/etc/` modified in the last 72 hours and display only filenames. Find files larger than 10M in `/var/log/` with their size and path. Delete all empty directories under `/tmp/` in a single command.

---

## Task 05 — Archiving
`🖥 server1`

Archive `/etc/ssh/` and `/etc/chrony.conf` into `/backup/conf_backup.tar.gz` preserving permissions and SELinux contexts. Extract only `sshd_config` into `/tmp/restore/`.

---

## Task 06 — LVM
`🖥 server1`

On `/dev/sdb`, create a PV, a VG `vg_prod` and a LV `lv_data` of 4 GiB formatted as xfs, mounted persistently on `/mnt/data`.

---

## Task 07 — LVM Extension
`🖥 server1`

Extend `vg_prod` using `/dev/sdc`, grow `lv_data` by 2 GiB and resize the filesystem online.

---

## Task 08 — Swap
`🖥 server1`

Create a 512 MiB swap partition on `/dev/sdb`, activate it and make it persistent via UUID.

---

## Task 09 — Apache and SELinux
`🖥 server1`

Install `httpd`. Serve content from `/webroot/` containing an `index.html` with `RHCSA OK`. Make it accessible on the standard http port.

---

## Task 10 — SSH Non-Standard Port
`🖥 server1`

Configure `sshd` to also listen on port `2222`.

---

## Task 11 — SELinux Boolean
`🖥 server1`

Allow `httpd` to send network requests to a backend. Document the boolean used in `/tmp/selinux_bool.txt`.

---

## Task 12 — Custom Service
`🖥 server1`

Create a service `hello.service` that runs `/usr/local/bin/hello.sh` (appends date to `/var/log/hello.log`), starts after `network.target`, restarts on failure with a 10s delay, and is enabled at boot.

---

## Task 13 — Systemd Timer
`🖥 server1`

Create a timer `clean_tmp.timer` that triggers `clean_tmp.service` every 30 minutes to delete files in `/tmp/` older than 5 days. Enable at boot.

---

## Task 14 — tmpfiles
`🖥 server1`

Create a `tmpfiles.d` configuration that creates `/run/myapp/` (owner `anna`, mode `0750`) and `/run/myapp/pid` at boot, and cleans files unused for more than 10 days. Apply immediately.

---

## Task 15 — Scheduling
`🖥 server1`

Schedule `df -h >> /home/anna/disk.log` for user `anna` every day at 23:45 via cron. Schedule `sync && echo done >> /tmp/at_done.txt` to run in 2 hours using `at`.

---

## Task 16 — Shell Script
`🖥 server1`

Write `/usr/local/bin/user_report.sh` that takes a group name as argument and prints `USERNAME | UID | HOME | SHELL` for each member. Handle missing arguments (exit 2) and non-existent groups (exit 1).

---

## Task 17 — Static Network
`🖥 server1`

Configure a static IP `192.168.0.100/24`, gateway `192.168.0.1`, DNS `1.1.1.1` and `8.8.8.8` on the main interface. Set the hostname to `rhcsa-node1.lab.local`.

---

## Task 18 — NFS and autofs
`🖥 server2` — export | `🖥 server1` — autofs client

On server2, export `/srv/nfs/share` via NFS with read/write access. On server1, configure autofs to mount it on demand at `/mnt/auto/share`.

---

## Task 19 — Flatpak
`🖥 server1`

Add the Flathub repository in system mode. Search for `org.gnome.Calculator` without installing it. Document the commands in `/tmp/flatpak_setup.txt`.

---

## Task 20 — Root Password Recovery
`🖥 server1`

Describe the full `rd.break` procedure to reset the root password and write the steps to `/tmp/rdbreak_procedure.txt`. Add the kernel argument `quiet` persistently.

---

*RHCSA EX200 Mock Exam — RHEL 10 — 2026*
