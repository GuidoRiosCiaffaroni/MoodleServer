#!/usr/bin/

echo ">>> Actualizando paquetes..."
apt-get update -y
apt-get upgrade -y

echo ">>> Instalando Apache2..."
apt-get install -y apache2

echo ">>> Habilitando módulos de Apache..."
a2enmod rewrite
a2enmod ssl
systemctl restart apache2
service apache2 restart

sudo apt autoremove -y
