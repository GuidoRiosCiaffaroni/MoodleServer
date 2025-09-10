#!/usr/bin/

echo ">>> Actualizando paquetes..."
apt-get update -y
apt-get upgrade -y

echo ">>> Instalando Apache2..."
apt-get install -y apache2

sudo apt autoremove -y
