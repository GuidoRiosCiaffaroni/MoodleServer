#!/bin/sh

set -eu

# ===== CONFIGURACIÓN =====
DB_NAME="moodle"
DB_USER="moodleuser"
DB_PASS="123"  # Asegúrate de que coincida con tu config.php
DB_HOST="localhost"
# =========================

# 1. Verificar si se ejecuta como root
if [ "$(id -u)" -ne 0 ]; then
  echo "[ERROR] Este script debe ejecutarse como root (usa sudo)." 1>&2
  exit 1
fi

echo ">>> Solucionando error de acceso a la base de datos para Moodle..."

# 2. Ejecutar comandos SQL para corregir usuario y permisos
mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '${DB_USER}'@'${DB_HOST}' IDENTIFIED BY '${DB_PASS}';
ALTER USER '${DB_USER}'@'${DB_HOST}' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'${DB_HOST}';
FLUSH PRIVILEGES;
EOF

echo ">>> ¡Permisos de MySQL corregidos con éxito!"

# 3. Comprobación del archivo config.php
CONFIG_FILE="/var/www/html/moodle/config.php"
if [ -f "$CONFIG_FILE" ]; then
  echo ">>> Verificando archivo config.php..."
  # Asegurar permisos correctos del archivo de configuración
  chown www-data:www-data "$CONFIG_FILE"
  chmod 640 "$CONFIG_FILE"
  echo ">>> Permisos de config.php restablecidos a 640 para www-data."
else
  echo "[AVISO] No se encontró config.php en $CONFIG_FILE. Si estás instalando Moodle, asegúrate de generarlo."
fi

echo ">>> Proceso finalizado. Recarga tu navegador web en Moodle."