# RHCSA Mock Exam — #03
**Duration: 2h30 | RHEL 10 | SELinux enforcing | No external documentation**

> Every configuration must survive a reboot.
> SELinux must remain in enforcing mode.

---

## Task 01 — Users and Groups

Create groups `webadmin` (GID `6000`) and `dba` (GID `6001`). Create user `tom` with UID `4001`, bash shell, secondary groups `webadmin` and `dba`, password `T0mPwd#`. Create user `sara` with UID `4002`, bash shell, secondary group `webadmin`, same password. Create a system account `batch` with shell `/sbin/nologin` and home `/var/lib/batch`. Ensure that any new file created by `tom` automatically belongs to the `dba` group without using `newgrp`.

---

## Task 02 — SSH Configuration

On the SSH server, disable direct root login and restrict access to users `tom` and `sara` only. Change the SSH listening port to 2200. Disable password authentication and allow key-based authentication only. Remember to update both SELinux and firewalld accordingly. Generate a key for `sara` and test the connection.

---

## Task 03 — find

Find all files on the system with no owner (belonging to a non-existent user) and write the result to `/tmp/orphans.txt`. Find all `.conf` files in `/etc/` modified in the last 48 hours. Find the 5 largest files in `/var/`. Find all executable files in `/usr/local/bin/` and copy them to `/tmp/local_bins/` using `-exec`. Find all files with the SGID bit set on the entire system and write the result to `/tmp/sgid_files.txt`.

---

## Task 04 — Archiving

Create a full archive of `/etc/` in `/backup/etc_full.tar.xz`. Explain why appending to a `.tar.xz` archive is not supported and create a new archive instead. Verify the archive integrity. Extract only `/etc/httpd/conf/httpd.conf` into `/tmp/restore/` and compare it with the original using `diff`.

---

## Task 05 — LVM

On `/dev/sdb`, create a PV, a VG `vg_test` and two LVs: `lv_a` (2G, ext4) and `lv_b` (2G, ext4). Mount both persistently via `/etc/fstab`. Fill `lv_a` with a 100M file using `dd`. Reduce `lv_a` to 1G following the correct ext4 procedure (`e2fsck`, `resize2fs`, `lvreduce`). Verify that data is intact after the reduction.

---

## Task 06 — NFS

Configure the machine as both NFS server and client. Export `/srv/share/ro` as read-only and `/srv/share/rw` as read-write. Mount both shares persistently in `/etc/fstab` with the appropriate options. Verify that writing to the read-only mount fails and writing to the read-write mount succeeds.

---

## Task 07 — SELinux Troubleshooting

Create an nginx service serving content from `/data/nginx/html/`. Do not fix the SELinux context initially. Start nginx and observe the failure. Set SELinux to permissive mode and verify nginx works. Switch back to enforcing mode, diagnose with `ausearch` and `sealert`, fix with `semanage fcontext` and `restorecon`, and verify nginx works in enforcing mode.

---

## Task 08 — Systemd Units

Create a `monitor.service` of type `forking` that runs `/usr/local/bin/monitor.sh` in the background (the script appends the date to `/var/log/monitor.log` every 5 seconds). Create a `cleanup.service` that depends on `monitor.service`. Create `cleanup.timer` to trigger `cleanup.service` every hour. Verify dependencies with `systemctl list-dependencies`.

---

## Task 09 — tmpfiles and journald

Create a `tmpfiles.d` configuration that creates directory `/run/webapp` with permissions `0755` owned by `tom`, and file `/run/webapp/status` empty with permissions `0644`, with automatic cleanup after 7 days. Configure `journald` to limit log storage to 200M and retention to 4 weeks. Verify with `journalctl --disk-usage`.

---

## Task 10 — Shell Script

Write `/usr/local/bin/batch_users.sh` that reads a file passed as `$1` with the format `username:password:group` per line. For each line, create the group if it does not exist, then create the user with the given password. If the user already exists, print `SKIP: <user> already exists`. Display a final summary showing how many users were created and how many were skipped. Exit with code 0 if all were created, code 1 if at least one was skipped. Test with a file containing 3 entries including one duplicate.

---

## Task 11 — grep and Regex

In `/etc/passwd`, find all lines where the UID is between 1000 and 9999 using a regex. In `/var/log/secure`, find all failed login attempts and count them per user. In `/etc/services`, find all services using the tcp protocol on ports 1 to 1024. Write a security report in `/tmp/security_report.txt` with the failed login results.

---

## Task 12 — Process Management

Identify all zombie processes with `ps` and explain in `/tmp/zombie_explain.txt` why a process becomes a zombie and how to deal with it. Launch 3 instances of `sleep 3600` in the background and kill them all in a single command. Verify none remain.

---

## Task 13 — Tuning

Identify the active tuned profile. Create a custom profile `rhcsa-custom` in `/etc/tuned/rhcsa-custom/` that inherits from `throughput-performance` and sets `vm.swappiness = 10` via the `[sysctl]` section. Apply this profile and verify with `sysctl vm.swappiness`. Also make `vm.swappiness = 10` persistent via `/etc/sysctl.d/` independently of tuned.

---

## Task 14 — Firewalld

Create a rich rule to accept SSH traffic only from `192.168.0.0/24`. Block the address `10.0.0.99` completely with a rich rule. Open port `3306/tcp` in the `internal` zone. Make all rules persistent and verify with `firewall-cmd --list-all`.

---

## Task 15 — RPM and DNF

Install `httpd` if absent and list all files installed by this package. Download the `httpd` RPM without installing it to `/tmp/rpms/`. Inspect it for version, dependencies and install scripts. Uninstall `httpd` and reinstall it from the local RPM using `rpm`. Verify with `rpm -V httpd`.

---

## Task 16 — Flatpak

Verify the installed flatpak version. Add the Flathub system remote. List installed Flatpak applications. Search for `org.libreoffice.LibreOffice` and display its details. Document the install and removal commands (without installing) in `/tmp/flatpak_commands.txt`.

---

## Task 17 — Scheduling

Schedule an `at` job to run `uptime` tomorrow at 08:00 and write the output to `/tmp/uptime_report.txt`. Configure a cron job for `sara` to delete `*.tmp` files in her home directory every Monday at 04:30. Create a systemd timer `log_rotate.timer` that triggers `log_rotate.service` on the 1st of every month at 03:00 to run `logrotate -f /etc/logrotate.conf`.

---

## Task 18 — DNS and Name Resolution

Configure the hostname `rhcsa-srv3.prod.local`. Add entries `192.168.0.10 db.prod.local` and `192.168.0.11 app.prod.local` to `/etc/hosts`. Configure DNS `192.168.0.1` and `8.8.8.8` on the main interface using `nmcli`. Identify the file that controls resolution order and explain it in `/tmp/dns_order.txt`.

---

## Task 19 — autofs

Configure autofs with an indirect map to mount the NFS exports from Task 06 under `/mnt/nfs/` accessible by name. Configure a direct map to mount `/srv/share/rw` on `/direct/data`. Verify that mounts appear after access and disappear after the timeout.

---

## Task 20 — GRUB and Recovery

Configure GRUB to wait 5 seconds at the boot menu and apply the change with `grub2-mkconfig`. Add the argument `mem=2G` to the default kernel using `grubby`, verify it, then immediately remove it. Describe in `/tmp/grub_recovery.txt` the differences between `rd.break`, `init=/bin/bash` and `systemd.unit=rescue.target`.

---

*RHCSA EX200 Mock Exam — RHEL 10 — 2026*
