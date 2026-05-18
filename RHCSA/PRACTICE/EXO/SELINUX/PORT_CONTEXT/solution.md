- Solution

### -1- rechercher l'erreur
````
sealert -a /var/log/audit/audit.log
````

### - Sortie
````

SELinux is preventing /usr/sbin/httpd from name_bind access on the tcp_socket port 82.

*****  Plugin bind_ports (99.5 confidence) suggests   ************************

If you want to allow /usr/sbin/httpd to bind to network port 82
Then you need to modify the port type.
Do
# semanage port -a -t PORT_TYPE -p tcp 82
    where PORT_TYPE is one of the following: http_cache_port_t, http_port_t, jboss_management_port_t, jboss_messaging_port_t, ntop_port_t, puppet_port_t.

*****  Plugin catchall (1.49 confidence) suggests   **************************

If you believe that httpd should be allowed name_bind access on the port 82 tcp_socket by default.
Then you should report this as a bug.
You can generate a local policy module to allow this access.
Do
allow this access for now by executing:
# ausearch -c 'httpd' --raw | audit2allow -M my-httpd
# semodule -X 300 -i my-httpd.pp


Additional Information:
Source Context                system_u:system_r:httpd_t:s0
Target Context                system_u:object_r:reserved_port_t:s0
Target Objects                port 82 [ tcp_socket ]
Source                        httpd
Source Path                   /usr/sbin/httpd
Port                          82
Host                          <Unknown>
Source RPM Packages           httpd-core-2.4.63-4.el10.x86_64
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
Alert Count                   7
First Seen                    2026-05-18 11:19:21 +04
Last Seen                     2026-05-18 11:21:26 +04
Local ID                      077cb3b9-4155-4d6b-88f0-042642c05785

Raw Audit Messages
type=AVC msg=audit(1779088886.892:328): avc:  denied  { name_bind } for  pid=3590 comm="httpd" src=82 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:reserved_port_t:s0 tclass=tcp_socket permissive=0


type=SYSCALL msg=audit(1779088886.892:328): arch=x86_64 syscall=bind success=no exit=EACCES a0=3 a1=5621763e33c0 a2=10 a3=7ffc929e5cac items=0 ppid=1 pid=3590 auid=4294967295 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=(none) ses=4294967295 comm=httpd exe=/usr/sbin/httpd subj=system_u:system_r:httpd_t:s0 key=(null)ARCH=x86_64 SYSCALL=bind AUID=unset UID=root GID=root EUID=root SUID=root FSUID=root EGID=root SGID=root FSGID=root

Hash: httpd,httpd_t,reserved_port_t,tcp_socket,name_bind
````

### -2- Le probleme est au niveau du port, `sealert` donne la réponse :
````
# semanage port -a -t PORT_TYPE -p tcp 82
    where PORT_TYPE is one of the following: http_cache_port_t, http_port_t, jboss_management_port_t, jboss_messaging_port_t, ntop_port_t, puppet_port_t.

````

### -3- Fixer le probleme de port : 
````
semanage port -a -t http_port_t -p tcp 82
````

### -4- Redémarrer le service
````
systemctl restart httpd
````

### -5- Rendre `/var/www/html/hosts` visible
````
restorecon -Rv /var/www/html/
````

### - Sortie
````
Relabeled /var/www/html/hosts from unconfined_u:object_r:net_conf_t:s0 to unconfined_u:object_r:httpd_sys_content_t:s0
````


### -6- Curl
````
curl http://192.168.0.6:82/hosts
````

### Sortie
````
# Loopback entries; do not change.
# For historical reasons, localhost precedes localhost.localdomain:
# Réseau local
192.168.0.6 serveur.sednal.lan serveur
192.168.0.11 client.sednal.lan client

127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
# See hosts(5) for proper format and other examples:
# 192.168.1.10 foo.example.org foo
# 192.168.1.13 bar.example.org bar
````



⚠️ Penser à remettre hosts dans /etc avec le bon context ⚠️













