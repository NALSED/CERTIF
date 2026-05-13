# Manager les bases d'un serveur http

---

1) Installer le service
````
dnf install -y httpd
````

2) Status
````
systemctl enable --now http
systemctl status httpd
````

3) `[INFO]` fichier de configuration
````
cd /etc/httpd/conf/httpd.conf
````

4) Autorisation firewalld
````
firwall-cmd --list-services

firwall-cmd --add-services=http
firwall-cmd --add-services=https

firewal-cmd --reload
````

5) Editer le fichier `/var/www/html/index.html`
````
vim /var/www/html/index.html
````

6) test
````
curl http://localhost
````
