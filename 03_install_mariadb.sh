#!/usr/bin/
#

echo ">>> Actualizando paquetes..."
apt-get update -y
apt-get upgrade -y

echo ">>> Instalando MariaDB Server y Client..."
apt-get install -y mariadb-server
#apt-get install -y mariadb-client

echo ">>> Habilitando y arrancando MariaDB..."
#systemctl enable mariadb
#systemctl start mariadb


sudo apt autoremove -y
