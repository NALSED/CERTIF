# 🔴 RHCSA Mock Exam — #01
**Duration: 2h30 | RHEL 10 | SELinux enforcing | No external documentation**

> ⚠️ Every configuration must survive a `reboot`.
> ⚠️ SELinux must remain in `enforcing` mode throughout the exam.

---

## Task 01 — Users and Groups

Create a group `ops` with GID `3100`.
Create the following users:
- `anna`: UID `1900`, shell `/bin/bash`, secondary group `ops`, password `R3dHat!`
- `leo`: UID `1901`, shell `/bin/bash`, secondary group `ops`, password `R3dHat!`
- `ghost`: shell `/sbin/nologin`, locked account

`anna`'s password must expire in **45 days**, with a warning **5 days** before. The account must be disabled **7 days** after expiration.

---

## Task 02 — Granular Sudo

Configure `leo` so that he can execute `useradd`, `usermod`, `userdel` and `passwd` as root **without password**, but he must **never** be able to change `root`'s password.
Use a dedicated file in `/etc/sudoers.d/`. Validate the syntax before saving.

---

## Task 03 — Advanced Permissions

Create `/data/ops/`:
- Owner: `root`, group: `ops`
- Permissions: `rwx` for owner and group, no rights for others
- **sgid** active: every file created in this directory inherits the `ops` group
- **sticky bit** active: only the file owner can delete their own files

Set the default `umask` for `anna` to `0027` persistently.

---

## Task 04 — find Command

1. Find all files owned by `anna` on the entire system → `/tmp/find_anna.txt` (errors suppressed)
2. Find all files with the **SUID** bit in `/usr/bin/` → `/tmp/find_suid.txt`
3. Find all files in `/etc/` modified in the **last 72 hours**, display only the filename without path
4. Find all files in `/var/log/` larger than **10M** and display their size + path
5. Find all empty directories under `/tmp/` and delete them in a single command

---

## Task 05 — Archiving

Create `/backup/` if it does not exist.
Archive `/etc/ssh/` and `/etc/chrony.conf` into `/backup/conf_backup.tar.gz` preserving permissions and SELinux contexts.
Verify the contents without extracting. Extract only the `sshd_config` file into `/tmp/restore/`.

---

## Task 06 — Full LVM

On `/dev/sdb`:
1. Create a GPT table and an **8 GiB** partition
2. Create a PV, a VG `vg_prod`, a LV `lv_data` of **4 GiB**
3. Format as `xfs`, mount on `/mnt/data` via UUID in `/etc/fstab`
4. Verify the mount survives a reboot

---

## Task 07 — Live LVM Extension

Without unmounting `/mnt/data`:
1. Add `/dev/sdc` as a new PV and extend `vg_prod`
2. Extend `lv_data` by **+2 GiB**
3. Resize the filesystem immediately
4. Verify with `df -hT`

---

## Task 08 — Swap

Create a swap partition of **512 MiB** on `/dev/sdb` (2nd partition).
Activate it and make it persistent in `/etc/fstab`.
Verify with `swapon --show` and `free -h`.

---

## Task 09 — SELinux: File Context

Install `httpd`. Create `/webroot/` with an `index.html` file containing `RHCSA OK`.
Change `DocumentRoot` in the Apache config to point to `/webroot/`.
Apply the correct SELinux context on `/webroot/` **persistently**.
Open the `http` port in firewalld zone `public` (permanent).
Enable and start `httpd`. Test with `curl http://localhost`.

---

## Task 10 — SELinux: Non-Standard Port

Configure `sshd` to also listen on port **2222** in addition to port 22.
Allow this port in both SELinux **and** firewalld.
Verify that `sshd` starts without errors and the port is open with `ss -tlnp`.

---

## Task 11 — SELinux: Boolean

The `httpd` service must be able to send network requests to a backend (proxy).
Identify the corresponding SELinux boolean, enable it **persistently**.
Document the command used in `/tmp/selinux_bool.txt`.

---

## Task 12 — Systemd: Custom Service

Create a systemd service `hello.service` that:
- Executes `/usr/local/bin/hello.sh` (script that writes the date to `/var/log/hello.log`)
- Starts after `network.target`
- Automatically restarts on failure (delay 10s)
- Is enabled at boot

Create the script, make it executable, enable and start the service.

---

## Task 13 — Systemd Timer

Create a systemd timer `clean_tmp.timer` that triggers `clean_tmp.service` every **30 minutes**.
The service executes: deletion of files in `/tmp/` older than 5 days.
Enable the timer at boot. Verify with `systemctl list-timers`.

---

## Task 14 — Systemd tmpfiles

Create a `tmpfiles.d` configuration that at boot:
- Creates the directory `/run/myapp/` owned by `anna` with permissions `0750`
- Creates the file `/run/myapp/pid` owned by `anna`
- Cleans files in `/run/myapp/` unused for more than **10 days**

Apply immediately without rebooting.

---

## Task 15 — cron + at Scheduling

1. Schedule via `cron` for user `anna`: run `df -h >> /home/anna/disk.log` every day at **23:45**
2. Schedule with `at` an execution **in 2 hours** of the command `sync && echo done >> /tmp/at_done.txt`
3. List pending `at` jobs

---

## Task 16 — Shell Script

Write `/usr/local/bin/user_report.sh`:
- Takes a group name as `$1`
- If no argument → display usage and exit with code `2`
- If group does not exist → display `ERROR: group not found` and exit with code `1`
- If group exists → for each member display: `USERNAME | UID | HOME | SHELL`
- Exit with code `0`

Test with `ops` and with a non-existent group.

---

## Task 17 — Static Network

Configure a static IP on the main interface:
- IP: `192.168.0.100/24`
- Gateway: `192.168.0.1`
- DNS: `1.1.1.1,8.8.8.8`
- Hostname: `rhcsa-node1.lab.local`
- Connection active at boot

Verify with `ip a`, `hostnamectl`, `ping 192.168.0.1`.

---

## Task 18 — NFS + autofs

On the machine (loopback mode):
1. Install `nfs-utils` and `autofs`
2. Export `/srv/nfs/share` via NFS (read/write, for everyone)
3. Enable `nfs-server` and open services in firewalld
4. Configure `autofs` to automatically mount this share at `/mnt/auto/share` on access

---

## Task 19 — Flatpak

1. Check if `flatpak` is installed, install it if needed
2. Add the Flathub remote (`https://dl.flathub.org/repo/flathub.flatpakrepo`) in **system** mode with the name `flathub`
3. List available remotes
4. Search for the application `org.gnome.Calculator` without installing it
5. Document the commands in `/tmp/flatpak_setup.txt`

---

## Task 20 — GRUB / rd.break Troubleshooting

1. Describe the complete procedure to reset the root password via `rd.break` (write steps in `/tmp/rdbreak_procedure.txt`)
2. Add the kernel argument `quiet` persistently with `grubby`
3. Verify the argument is applied with `grubby --info=DEFAULT`

---

*RHCSA EX200 Mock Exam — RHEL 10 — 2026*
