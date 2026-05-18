pour créer le probléme avec SELinux

- Changer le port d'écoute du serveur web
````
vim /etc/httpd/conf/httpd.conf
# Editer
Port 82
````

- Déplacer `/etc/hosts` vers `/var/ww/html`
````
mv /etc/hosts /var/ww/html
````
