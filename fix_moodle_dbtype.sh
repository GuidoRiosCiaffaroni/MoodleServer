#!/bin/sh

#

set -eu

# Ruta de config.php (ajústala si es distinta)
CONFIG_PHP="/var/www/html/moodle/config.php"

# Verificar que existe config.php
if [ ! -f "$CONFIG_PHP" ]; then
  echo "[ERROR] No se encontró $CONFIG_PHP"
  exit 1
fi

# Hacer backup
cp "$CONFIG_PHP" "${CONFIG_PHP}.bak.$(date +%Y%m%d-%H%M%S)"

# Reemplazar mysqli -> mariadb en $CFG->dbtype
sed -i "s/\(\$CFG->dbtype\s*=\s*\)'mysqli'/\1'mariadb'/" "$CONFIG_PHP"

echo "✅ Se cambió \$CFG->dbtype a 'mariadb' en $CONFIG_PHP"

