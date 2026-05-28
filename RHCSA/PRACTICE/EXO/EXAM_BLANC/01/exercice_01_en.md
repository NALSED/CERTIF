# RHCSA Mock Exam — #01
**Duration: 2h30 | RHEL 10 | SELinux enforcing | No external documentation**

> Every configuration must survive a reboot.
> SELinux must remain in enforcing mode throughout the exam.

---

## Task 01 — Users and Groups

Create a group `ops` with GID `3100`.
Create the following users:
- `anna`: UID `1900`, shell `/bin/bash`, secondary group `ops`, password `R3dHat!`
- `leo`: UID `1901`, shell `/bin/bash`, secondary group `ops`, password `R3dHat!`
- `ghost`: shell `/sbin/nologin`, locked account

`anna`'s password must expire in 45 days, with a warning 5 days before and the account disabled 7 days after expiration.

---

## Task 02 — Sudo

Configure `leo` so that he can run `useradd`, `usermod`, `userdel` and `passwd` as root without a password, but he must never be able to change `root`'s password. Use a dedicated file in `/etc/sudoers.d/`.

---

## Task 03 — Permissions

Create `/data/ops/` owned by `root` with group `ops`. The owner and group must have full access, others must have no permissions. Enable the sgid bit so that new files inherit the `ops` group, and enable the sticky bit so that only the file owner can delete their own files. Set `anna`'s default umask to `0027` persistently.

---

## Task 04 — find

Find all files owned by `anna` on the entire system and write the result to `/tmp/find_anna.txt` (suppress errors). Find all files with the SUID bit set in `/usr/bin/` and write the result to `/tmp/find_suid.txt`. Find all files in `/etc/` modified in the last 72 hours and display only the filename without path. Find all files in `/var/log/` larger than 10M and display their size and path. Find all empty directories under `/tmp/` and delete them in a single command.

---

## Task 05 — Archiving

Create `/backup/` if it does not exist. Archive `/etc/ssh/` and `/etc/chrony.conf` into `/backup/conf_backup.tar.gz` preserving permissions and SELinux contexts. Verify the archive contents without extracting. Extract only `sshd_config` into `/tmp/restore/`.

---

## Task 06 — LVM

On `/dev/sdb`, create a 8 GiB partition, a PV, a VG named `vg_prod` and a LV named `lv_data` of 4 GiB. Format it as xfs and mount it persistently on `/mnt/data` via UUID in `/etc/fstab`.

---

## Task 07 — LVM Extension

Without unmounting `/mnt/data`, add `/dev/sdc` as a new PV, extend `vg_prod`, then extend `lv_data` by 2 GiB and resize the filesystem immediately. Verify with `df -hT`.

---

## Task 08 — Swap

Create a 512 MiB swap partition on `/dev/sdb`. Activate it and make it persistent in `/etc/fstab` via UUID. Verify with `swapon --show`.

---

## Task 09 — SELinux: File Context

Install `httpd`. Create `/webroot/` with an `index.html` file containing `RHCSA OK`. Change `DocumentRoot` in the Apache configuration to `/webroot/`. Apply the correct SELinux context on `/webroot/` persistently. Open the `http` port in firewalld (permanent). Enable and start `httpd` and verify with `curl http://localhost`.

---

## Task 10 — SELinux: Non-Standard Port

Configure `sshd` to also listen on port 2222 in addition to port 22. Allow this port in both SELinux and firewalld. Verify that `sshd` starts without errors and that the port is open.

---

## Task 11 — SELinux: Boolean

Identify and persistently enable the SELinux boolean that allows `httpd` to send network requests to a backend. Document the command used in `/tmp/selinux_bool.txt`.

---

## Task 12 — Systemd: Custom Service

Create a systemd service `hello.service` that runs `/usr/local/bin/hello.sh` (a script that appends the current date to `/var/log/hello.log`), starts after `network.target`, automatically restarts on failure with a 10-second delay, and is enabled at boot.

---

## Task 13 — Systemd Timer

Create a systemd timer `clean_tmp.timer` that triggers `clean_tmp.service` every 30 minutes. The service must delete files in `/tmp/` older than 5 days. Enable the timer at boot.

---

## Task 14 — Systemd tmpfiles

Create a `tmpfiles.d` configuration that at boot creates the directory `/run/myapp/` owned by `anna` with permissions `0750`, creates the file `/run/myapp/pid` owned by `anna`, and cleans files in `/run/myapp/` unused for more than 10 days. Apply the configuration immediately without rebooting.

---

## Task 15 — Scheduling

Schedule a cron job for user `anna` that runs `df -h >> /home/anna/disk.log` every day at 23:45. Schedule an `at` job to run `sync && echo done >> /tmp/at_done.txt` in 2 hours. List pending `at` jobs.

---

## Task 16 — Shell Script

Write `/usr/local/bin/user_report.sh` that takes a group name as `$1`. If no argument is given, display usage and exit with code 2. If the group does not exist, display `ERROR: group not found` and exit with code 1. If the group exists, display for each member: `USERNAME | UID | HOME | SHELL` and exit with code 0. Test with group `ops` and with a non-existent group.

---

## Task 17 — Static Network

Configure a static IP on the main interface: `192.168.0.100/24`, gateway `192.168.0.1`, DNS `1.1.1.1` and `8.8.8.8`, hostname `rhcsa-node1.lab.local`. The connection must be active at boot. Verify with `ip a` and `hostnamectl`.

---

## Task 18 — NFS + autofs

Install `nfs-utils` and `autofs`. Export `/srv/nfs/share` via NFS with read/write access. Enable `nfs-server` and open the required services in firewalld. Configure autofs to automatically mount this share on `/mnt/auto/share` on access.

---

## Task 19 — Flatpak

Ensure `flatpak` is installed. Add the Flathub remote (`https://dl.flathub.org/repo/flathub.flatpakrepo`) in system mode with the name `flathub`. Search for `org.gnome.Calculator` without installing it. Document the commands used in `/tmp/flatpak_setup.txt`.

---

## Task 20 — GRUB / rd.break

Describe the complete procedure to reset the root password via `rd.break` and write the steps to `/tmp/rdbreak_procedure.txt`. Add the kernel argument `quiet` persistently using `grubby` and verify it is applied.

---

*RHCSA EX200 Mock Exam — RHEL 10 — 2026*
