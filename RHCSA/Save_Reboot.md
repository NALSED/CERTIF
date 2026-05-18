1) tuned => /etc/sysctl.d
2) Log => mkdir -p /var/log/journal ou /etc/systemd/journald.conf éditer Storage=persistent
3) changement de gub2 boot => grub2-mkconfig -o /boot/grub2/grub.cfg et fichier de configuration /etc/default/grub equivaut à appuyer sur `e` quand on est au menu de démarage priviligier grubby
4) hostname => hostnamectl set-hostname
5) Configuration firewall persistante => --permanent
6) SELinux -P pour rendre permananet les boolean
