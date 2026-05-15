### - Recherche du probleme dans /var/log/audit/audit.log
````
sealert -a /var/log/audit/audit.log
````

### - Sortie qui nous intéresse
````
*****  Plugin catchall (17.1 confidence) suggests   **************************

If you believe that nginx should be allowed read access on the index.html file by default.
Then you should report this as a bug.
You can generate a local policy module to allow this access.
Do
allow this access for now by executing:
# ausearch -c 'nginx' --raw | audit2allow -M my-nginx
# semodule -X 300 -i my-nginx.pp


Additional Information:
Source Context                system_u:system_r:httpd_t:s0
Target Context                unconfined_u:object_r:default_t:s0
Target Objects                index.html [ file ]
Source                        nginx
Source Path                   /usr/sbin/nginx
Port                          <Unknown>
Host                          <Unknown>
Source RPM Packages           nginx-core-1.26.3-1.el10.x86_64
Target RPM Packages
SELinux Policy RPM            selinux-policy-targeted-42.1.7-1.el10.noarch
Local Policy RPM              selinux-policy-targeted-42.1.7-1.el10.noarch
Selinux Enabled               True
Policy Type                   targeted
Enforcing Mode                Enforcing
Host Name                     rhcsaserver.example.com
Platform                      Linux rhcsaserver.example.com
                              6.12.0-124.8.1.el10_1.x86_64 #1 SMP
                              PREEMPT_DYNAMIC Fri Oct 17 13:03:58 EDT 2025
                              x86_64
Alert Count                   1
First Seen                    2026-05-15 14:24:59 +04
Last Seen                     2026-05-15 14:24:59 +04
Local ID                      c197d075-a39a-4108-93c6-e17c5e1d3571

Raw Audit Messages
type=AVC msg=audit(1778840699.908:411): avc:  denied  { read } for  pid=5667 comm="nginx" name="index.html" dev="dm-0" ino=1312000 scontext=system_u:system_r:httpd_t:s0 tcontext=unconfined_u:object_r:default_t:s0 tclass=file permissive=0


type=SYSCALL msg=audit(1778840699.908:411): arch=x86_64 syscall=openat success=no exit=EACCES a0=ffffff9c a1=564a9743987c a2=800 a3=0 items=0 ppid=5396 pid=5667 auid=4294967295 uid=980 gid=978 euid=980 suid=980 fsuid=980 egid=978 sgid=978 fsgid=978 tty=(none) ses=4294967295 comm=nginx exe=/usr/sbin/nginx subj=system_u:system_r:httpd_t:s0 key=(null)ARCH=x86_64 SYSCALL=openat AUID=unset UID=nginx GID=nginx EUID=nginx SUID=nginx FSUID=nginx EGID=nginx SGID=nginx FSGID=nginx

Hash: nginx,httpd_t,default_t,file,read
````

### - La partie qui explique le probléme
### On voit ici que le contexte actuel du processus (Source) est différent du contexte actuel du fichier (Target)
````
Additional Information:
Source Context                system_u:system_r:httpd_t:s0       <=== Contexte Actuel du processus
Target Context                unconfined_u:object_r:default_t:s0 <=== Contexte actuel du fichier
Target Objects                index.html [ file ]                <=== Fichier problématique
Source                        nginx
Source Path                   /usr/sbin/nginx
Port                          <Unknown>
Host                          <Unknown>
Source RPM Packages           nginx-core-1.26.3-1.el10.x86_64
Target RPM Packages
SELinux Policy RPM            selinux-policy-targeted-42.1.7-1.el10.noarch
Local Policy RPM              selinux-policy-targeted-42.1.7-1.el10.noarch
Selinux Enabled               True
Policy Type                   targeted
Enforcing Mode                Enforcing
````


## - Changer la partie problématique avec `semanage fcontext` 

### 1) Comparer contexte qui bloque et celui qui marche pour le service
````
# Dossier problématique
ls -Zd /web
# Sortie
unconfined_u:object_r:default_t:s0 /web

# dossier qui fonctionne pour nginx
ls -Zd /usr/share/nginx/html
# Sortie system_u:object_r:httpd_sys_content_t:s0 /usr/share/nginx/html
````

### 2) Changer le contexte de /web/index.html
````
semanage fcontext -a -t httpd_sys_content_t "/web(/.*)?"
````

### 3) Appliquer les changements
````
restorcon -Rv /web/
# Sortie
Relabeled /web from unconfined_u:object_r:default_t:s0 to unconfined_u:object_r:httpd_sys_content_t:s0
Relabeled /web/index.html from unconfined_u:object_r:default_t:s0 to unconfined_u:object_r:httpd_sys_content_t:s0
````


### TEST nginx
````
curl http://localhost/index.html
# Sortie
test selinux
````
