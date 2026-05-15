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

# 5. Démarre nginx
systemctl start nginx

# !!! Si httpd déjà actif !!! sinon conflit port 80
systemctl stop httpd

# Permission pare-feu
firewall-cmd --add-service=http

# 7. Teste → doit échouer (403 ou contenu vide)
curl http://localhost/index.html
````

