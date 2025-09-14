#!/usr/bin/

# Instalacion de php

echo ">>> Actualizando paquetes..."
apt-get update -y
apt-get upgrade -y

echo ">>> Instalando Apache2..."
apt-get install -y apache2

echo ">>> Instalando PHP núcleo..."
apt-get install -y php
apt-get install -y php-cli
apt-get install -y php-common

echo ">>> Instalando extensiones PHP requeridas por Moodle..."
apt-get install -y php-mysql
apt-get install -y php-curl
apt-get install -y php-gd
apt-get install -y php-intl
apt-get install -y php-mbstring
apt-get install -y php-xml
apt-get install -y php-zip
apt-get install -y php-soap
apt-get install -y php-bcmath
apt-get install -y php-ldap
apt-get install -y php-readline
apt-get install -y php-opcache
apt-get install -y php-json
# php-xmlrpc se omite en Ubuntu recientes

echo ">>> Instalando Redis (opcional para caché de Moodle)..."
apt-get install -y php-redis
apt-get install -y redis-server

echo ">>> Instalando herramientas adicionales..."
apt-get install -y git
apt-get install -y unzip
apt-get install -y graphviz
apt-get install -y aspell
apt-get install -y ghostscript
apt-get install -y cron


sudo apt autoremove -y
