- Cet exercice à pour but de montrer, sur un service non bloquant pour le systeme, comment diagnistiquer un probléme de contexte avec `SELinux` et comment le résoudre.

**Mise en place BUG**
````
# 1. Installe nginx si pas déjà fait
dnf install -y nginx

# 2. Crée un fichier dans /tmp (mauvais contexte)
echo "test selinux" > /tmp/index.html

# 3. Copie-le dans un dossier custom (hors /var/www/html)
mkdir /web
cp /tmp/index.html /web/index.html

# 4. Configure nginx pour servir /web
echo 'server { listen 80; root /web; }' > /etc/nginx/conf.d/test.conf

# 5. Commenter ligne dans la configuration de nginx
vim /etc/nginx/nginx.conf

#    server {
#        listen       80;
#        listen       [::]:80;
#        server_name  _;
#        root         /usr/share/nginx/html;

        # Load configuration files for the default server block.
#       include /etc/nginx/default.d/*.conf;
#    }

# 6. Démarre nginx
systemctl start nginx

# !!! Si httpd déjà actif !!! sinon conflit port 80
systemctl stop httpd

# 7. Permission pare-feu
firewall-cmd --add-service=http

# 8. Tester => doit échouer (403 ou contenu vide)
curl http://localhost/index.html

<html>
<head><title>403 Forbidden</title></head>
<body>
<center><h1>403 Forbidden</h1></center>
<hr><center>nginx/1.26.3</center>
</body>
</html>
````

