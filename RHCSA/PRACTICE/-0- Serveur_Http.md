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
