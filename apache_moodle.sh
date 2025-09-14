#!/usr/bin/env bash

#

set -euo pipefail

# --- Verificar privilegios ---
if [ "$(id -u)" -ne 0 ]; then
   echo "[ERROR] Este script debe ejecutarse como root o con sudo."
   exit 1
fi

# --- Variables ---
APACHE_CONF="/etc/apache2/sites-available/moodle.conf"
MOODLE_DIR="/var/www/html/moodle"
SERVER_NAME="tusitio.com"   # <- cámbialo por tu dominio o IP pública
SERVER_ADMIN="admin@tusitio.com"

echo ">>> Creando configuración de Apache para Moodle..."

cat > "$APACHE_CONF" <<EOF
<VirtualHost *:80>
    ServerAdmin ${SERVER_ADMIN}
    ServerName ${SERVER_NAME}
    ServerAlias www.${SERVER_NAME}

    DocumentRoot ${MOODLE_DIR}

    <Directory ${MOODLE_DIR}>
        Options +FollowSymlinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/moodle_error.log
    CustomLog \${APACHE_LOG_DIR}/moodle_access.log combined
</VirtualHost>
EOF

echo ">>> Deshabilitando sitio por defecto (000-default.conf)..."
a2dissite 000-default.conf || true

echo ">>> Habilitando configuración de Moodle..."
a2ensite moodle.conf

echo ">>> Activando módulos necesarios..."
a2enmod rewrite
a2enmod ssl

echo ">>> Probando configuración de Apache..."
apache2ctl configtest

echo ">>> Reiniciando Apache..."
systemctl reload apache2

echo ">>> Configuración completada ✅"
echo ""
echo "Ahora puedes acceder a Moodle en: http://${SERVER_NAME}/"
