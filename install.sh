#!/usr/bin/env bash
set -euo pipefail

# --- Corrección inicial de saltos de línea y permisos ---
# (esto evita errores tipo '\r' o CRLF de Windows)
apt-get update -y
apt-get install -y dos2unix
dos2unix install.sh
chmod +x install.sh

# Si el script no se está ejecutando con bash, relanzarlo
if [ -z "${BASH_VERSION:-}" ]; then
   echo ">>> Relanzando con bash..."
   exec bash ./install.sh
fi

# --- Verificar privilegios ---
if [ "$(id -u)" -ne 0 ]; then
   echo "[ERROR] Este script debe ejecutarse como root o con sudo."
   exit 1
fi

echo ">>> Actualizando paquetes..."
apt-get update -y
apt-get upgrade -y

echo ">>> Instalando Apache2..."
apt-get install -y apache2

echo ">>> Instalando MariaDB..."
apt-get install -y mariadb-server
apt-get install -y mariadb-client

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

echo ">>> Instalando phpMyAdmin..."
DEBIAN_FRONTEND=noninteractive apt-get install -y phpmyadmin

echo ">>> Habilitando módulos de Apache..."
a2enmod rewrite
a2enmod ssl
systemctl restart apache2

echo ">>> Instalación completada ✅"
echo ""
echo ">>> Recuerda configurar MariaDB para Moodle:"
echo "    CREATE DATABASE moodle DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
echo "    CREATE USER 'moodleuser'@'localhost' IDENTIFIED BY 'TuClaveSegura';"
echo "    GRANT ALL PRIVILEGES ON moodle.* TO 'moodleuser'@'localhost';"
echo "    FLUSH PRIVILEGES;"
echo ""
echo ">>> Para clonar Moodle ejecuta:"
echo "    cd /var/www/html"
echo "    git clone -b MOODLE_404_STABLE git://git.moodle.org/moodle.git moodle"
echo "    chown -R www-data:www-data /var/www/html/moodle"
echo "    chmod -R 755 /var/www/html/moodle"
echo ""
echo ">>> Acceso a phpMyAdmin:"
echo "    http://TU_SERVIDOR/phpmyadmin"
echo ""
echo ">>> No olvides configurar cron para Moodle:"
echo "    * * * * * www-data /usr/bin/php /var/www/html/moodle/admin/cli/cron.php >/dev/null 2>&1"

sudo apt autoremove -y
