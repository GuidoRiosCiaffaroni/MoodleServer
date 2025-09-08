#!/bin/bash
# ==========================================
# Script de instalación de dependencias Moodle en Ubuntu
# Instalación paquete por paquete (una línea cada uno)
# Probado en Ubuntu Server 22.04 / 24.04 LTS
# ==========================================

# --- Verificar privilegios ---
if [ "$(id -u)" -ne 0 ]; then
   echo "[ERROR] Este script debe ejecutarse como root o con sudo."
   exit 1
fi

echo ">>> Actualizando paquetes..."
apt update -y
apt upgrade -y

echo ">>> Instalando Apache2..."
apt install -y apache2

echo ">>> Instalando MariaDB..."
apt install -y mariadb-server
apt install -y mariadb-client

echo ">>> Instalando PHP núcleo..."
apt install -y php
apt install -y php-cli
apt install -y php-common

echo ">>> Instalando extensiones PHP requeridas por Moodle..."
apt install -y php-mysql
apt install -y php-xmlrpc
apt install -y php-curl
apt install -y php-gd
apt install -y php-intl
apt install -y php-mbstring
apt install -y php-xml
apt install -y php-zip
apt install -y php-soap
apt install -y php-bcmath
apt install -y php-ldap
apt install -y php-readline
apt install -y php-opcache
apt install -y php-json
apt install -y php-tokenizer

echo ">>> Instalando Redis (opcional para caché de Moodle)..."
apt install -y php-redis
apt install -y redis-server

echo ">>> Instalando herramientas adicionales..."
apt install -y git
apt install -y unzip
apt install -y graphviz
apt install -y aspell
apt install -y ghostscript
apt install -y cron

echo ">>> Habilitando módulos de Apache..."
a2enmod rewrite
a2enmod ssl
systemctl restart apache2

echo ">>> Instalación completada ✅"
echo ">>> Recuerda crear la base de datos para Moodle en MariaDB:"
echo "    CREATE DATABASE moodle DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
echo "    CREATE USER 'moodleuser'@'localhost' IDENTIFIED BY 'TuClaveSegura';"
echo "    GRANT ALL PRIVILEGES ON moodle.* TO 'moodleuser'@'localhost';"
echo "    FLUSH PRIVILEGES;"

echo ">>> Para clonar Moodle ejecuta:"
echo "    cd /var/www/html"
echo "    git clone -b MOODLE_404_STABLE git://git.moodle.org/moodle.git moodle"
echo "    chown -R www-data:www-data /var/www/html/moodle"
echo "    chmod -R 755 /var/www/html/moodle"

echo ">>> No olvides configurar cron para Moodle:"
echo "    * * * * * www-data /usr/bin/php /var/www/html/moodle/admin/cli/cron.php >/dev/null 2>&1"
