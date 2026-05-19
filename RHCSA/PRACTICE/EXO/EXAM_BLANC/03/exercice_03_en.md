# 🔴 RHCSA Mock Exam — #03
**Duration: 2h30 | RHEL 10 | SELinux enforcing | No external documentation**

> ⚠️ Every configuration must survive a `reboot`.
> ⚠️ SELinux must remain in `enforcing` mode.

---

## Task 01 — System Users and Environment

Create the group `webadmin` (GID `6000`) and the group `dba` (GID `6001`).
Create:
- `tom`: UID `4001`, bash, secondary groups `webadmin` and `dba`, password `T0mPwd#`
- `sara`: UID `4002`, bash, secondary group `webadmin`, password `T0mPwd#`
- `batch`: system account, shell `/sbin/nologin`, home `/var/lib/batch`

Ensure that any new file created by `tom` belongs to the `dba` group by default (using `newgrp` is not a persistent solution — find the correct method).

---

## Task 02 — Secured SSH Configuration

On the SSH server:
1. Forbid direct `root` login via SSH
2. Allow only users `tom` and `sara` to connect
3. Change the SSH port to **2200** (remember SELinux and firewalld)
4. Disable password authentication (key only)

Verify that `sshd` restarts without error. Generate a key for `sara` and test the connection.

---

## Task 03 — find: Search and Processing

1. Find all system files belonging to a **non-existent user** (no owner) → `/tmp/orphans.txt`
2. Find all `.conf` files in `/etc/` modified in the **last 48 hours**
3. Find the **5 largest files** in `/var/` (hint: combine `find` and `sort`)
4. Find all executable files in `/usr/local/bin/` and copy them to `/tmp/local_bins/` with `-exec`
5. Find files with the **SGID** bit set on the entire system → `/tmp/sgid_files.txt`

---

## Task 04 — Differential Archiving and Restoration

1. Create a full archive of `/etc/` in `/backup/etc_full.tar.xz`
2. Try to append the `/etc/httpd/` directory to the existing archive (option `--append`, but note: `.tar.xz` does not support appending — explain why and create a new archive)
3. Test the integrity of the archive
4. Extract only `/etc/httpd/conf/httpd.conf` into `/tmp/restore/`
5. Compare the restored file to the original with `diff`

---

## Task 05 — LVM: Reduction and Management

On `/dev/sdb`:
1. Create a PV, VG `vg_test`, two LVs: `lv_a` (2G, ext4) and `lv_b` (2G, ext4)
2. Mount `lv_a` on `/mnt/lva` and `lv_b` on `/mnt/lvb` (persistent via fstab)
3. Fill `lv_a` with a 100M file: `dd if=/dev/urandom of=/mnt/lva/bigfile bs=1M count=100`
4. **Attempt** to reduce `lv_a` to 1G (note: XFS does not support reduction — use ext4 and follow the correct procedure: `e2fsck`, `resize2fs`, `lvreduce`)
5. Verify data is intact after reduction

---

## Task 06 — NFS Network Filesystem

1. Configure the machine as both NFS server and client (loopback)
2. Export `/srv/share/ro` as **read-only** and `/srv/share/rw` as **read-write**
3. Mount `/srv/share/ro` on `/mnt/nfs_ro` with option `ro` in `/etc/fstab`
4. Mount `/srv/share/rw` on `/mnt/nfs_rw` with option `rw` in `/etc/fstab`
5. Verify writing to `/mnt/nfs_ro` is impossible and to `/mnt/nfs_rw` works

---

## Task 07 — SELinux: Full Troubleshooting

Create a `nginx` service serving from `/data/nginx/html/`.
Intentionally, do **not** fix the SELinux context at first.
Start nginx, observe the access failure.
Follow the complete procedure:
1. `setenforce 0` — verify nginx works in permissive
2. `setenforce 1` — reproduce the failure
3. `ausearch` then `sealert` to identify the problem
4. Fix with `semanage fcontext` + `restorecon`
5. Verify nginx works in enforcing

---

## Task 08 — Systemd: Complex Units

1. Create a `monitor.service` of type `forking` that launches `/usr/local/bin/monitor.sh` in the background (the script does `while true; do date >> /var/log/monitor.log; sleep 5; done`)
2. Create a `cleanup.service` that depends on `monitor.service` (`After=` and `Requires=`)
3. Create `cleanup.timer` that triggers `cleanup.service` every hour
4. Verify dependencies with `systemctl list-dependencies cleanup.service`

---

## Task 09 — Systemd tmpfiles + journald

1. Create via `tmpfiles.d`: directory `/run/webapp` (permissions `0755`, owner `tom`), file `/run/webapp/status` (empty, permissions `0644`), automatic cleanup after **7 days**
2. Configure `journald` to limit log size to **200M** (`SystemMaxUse`)
3. Configure retention to **4 weeks** (`MaxRetentionSec`)
4. Verify with `journalctl --disk-usage`

---

## Task 10 — Shell Script: Loops and Conditions

Write `/usr/local/bin/batch_users.sh`:
- Reads a file passed as `$1` (format: `username:password:group` per line)
- For each line:
  - Creates the group if it does not exist
  - Creates the user with the given password
  - If the user already exists, prints `SKIP: <user> already exists`
- Displays a final summary: `X users created, Y skipped`
- Return code `0` if all created, `1` if at least one skipped

Test with a file containing 3 entries including one duplicate.

---

## Task 11 — grep and Advanced Regex

1. In `/etc/passwd`, find all lines where the UID is between 1000 and 9999 (regex)
2. In `/var/log/secure`, find all failed login attempts with `grep -E`
3. Count the number of failed attempts per user (combine `grep`, `awk`, `sort`, `uniq -c`)
4. In `/etc/services`, find all services using the `tcp` protocol on ports 1 to 1024
5. Create a report in `/tmp/security_report.txt` with results from points 2 and 3

---

## Task 12 — Processes: Zombies and Management

1. Identify all current zombie processes with `ps`
2. Explain in `/tmp/zombie_explain.txt` why a process becomes a zombie and how to kill it
3. Launch 3 instances of `sleep 3600` in the background
4. Kill them all in a single command with `killall`
5. Verify with `ps` and `jobs` that none remain

---

## Task 13 — Tuning and Performance

1. Identify the active tuned profile
2. Create a custom profile `rhcsa-custom` in `/etc/tuned/rhcsa-custom/`:
   - Inherits from `throughput-performance`
   - Sets `vm.swappiness = 10` via `[sysctl]`
3. Apply this profile
4. Verify with `sysctl vm.swappiness`
5. Make `vm.swappiness = 10` persistent via `/etc/sysctl.d/` independently of tuned

---

## Task 14 — Firewalld: Zones and Advanced Rules

1. Display the default zone and all available zones
2. Create a **rich rule** to accept SSH traffic only from `192.168.0.0/24`
3. Completely block the address `10.0.0.99` with a rich rule
4. Open port `3306/tcp` (MySQL) in the `internal` zone
5. Make all rules persistent and verify with `firewall-cmd --list-all`

---

## Task 15 — RPM Package Management + DNF

1. Install `httpd` if absent, then list all files installed by this package
2. Download the `httpd` RPM **without installing** it into `/tmp/rpms/`
3. Inspect the downloaded RPM: version, dependencies, pre/post-install scripts
4. Uninstall `httpd` and reinstall it from the local RPM with `rpm`
5. Verify installation integrity with `rpm -V httpd`

---

## Task 16 — Flatpak: Complete Management

1. Check the installed flatpak version
2. Add the Flathub system remote
3. List installed Flatpak applications (system + user)
4. Search for `org.libreoffice.LibreOffice` and display its details (size, version, description)
5. Document the installation command (without installing) and the removal command in `/tmp/flatpak_commands.txt`

---

## Task 17 — Advanced Scheduling

1. Create an `at` job that runs tomorrow at **08:00** and sends the result of `uptime` to `/tmp/uptime_report.txt`
2. Configure a cron for `sara`: run `find /home/sara -name "*.tmp" -delete` every **Monday at 04:30**
3. Create a systemd timer `log_rotate.timer` that triggers `log_rotate.service` on the **1st of each month at 03:00**
4. The service must run `logrotate -f /etc/logrotate.conf`

---

## Task 18 — Network: DNS and Name Resolution

1. Configure the hostname `rhcsa-srv3.prod.local`
2. Add to `/etc/hosts`: `192.168.0.10 db.prod.local` and `192.168.0.11 app.prod.local`
3. Configure `nmcli` to use DNS `192.168.0.1` and `8.8.8.8` on the main interface
4. Verify resolution with `nslookup db.prod.local` and `dig app.prod.local`
5. Identify the file that defines the resolution order (DNS vs /etc/hosts) and explain it in `/tmp/dns_order.txt`

---

## Task 19 — autofs: On-Demand Mounting

1. Configure autofs with an **indirect map** to mount NFS exports from task 06
2. The mount must be under `/mnt/nfs/` accessible by name (`ro`, `rw`)
3. Configure a **direct map** to mount `/srv/share/rw` directly on `/direct/data`
4. Verify that mounts appear in `mount` after access and disappear after timeout

---

## Task 20 — GRUB Access and Recovery

1. Configure GRUB to wait **5 seconds** at the boot menu (`GRUB_TIMEOUT`)
2. Apply the modification with `grub2-mkconfig`
3. Add the argument `mem=2G` to the default kernel with `grubby` (simulating memory restriction)
4. Verify then **immediately remove** this argument to not affect the system
5. Describe in `/tmp/grub_recovery.txt` the difference between `rd.break`, `init=/bin/bash` and `systemd.unit=rescue.target`

---

*RHCSA EX200 Mock Exam — RHEL 10 — 2026*
