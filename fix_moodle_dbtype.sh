#!/usr/bin/env bash
set -euo pipefail

# === Configura aquí si tu ruta es distinta ===
MOODLE_DIR="/var/www/html/moodle"
CONFIG_PHP="${MOODLE_DIR}/config.php"

# --- Verificar root ---
if [ "$(id -u)" -ne 0 ]; then
  echo "[ERROR] Ejecuta este script como root (sudo)." >&2
  exit 1
fi

# --- Comprobaciones previas ---
if [ ! -f "$CONFIG_PHP" ]; then
  echo "[ERROR] No se encontró $CONFIG_PHP. Ajusta MOODLE_DIR si es necesario." >&2
  exit 2
fi

# Detectar versión de PHP y asegurar php-mysql (mysqli)
PHP_VER="$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;' 2>/dev/null || true)"
if [ -n "$PHP_VER" ]; then
  apt-get update -y
  apt-get install -y "php${PHP_VER}-mysql" || apt-get install -y php-mysql
  # habilitar extensiones por si acaso
  phpenmod mysqli 2>/dev/null || true
  phpenmod mysqlnd 2>/dev/null || true
else
  echo "[ADVERTENCIA] No pude detectar PHP con 'php -v'. Verifica tu instalación de PHP." >&2
fi

# --- Detectar si el servidor es MariaDB o MySQL ---
DB_INFO="$(mysql -V 2>/dev/null || true)"
if [[ "$DB_INFO" == *"MariaDB"* ]]; then
  TARGET_DBTYPE="mariadb"
else
  TARGET_DBTYPE="mysqli"
fi
echo ">>> Motor detectado: ${DB_INFO:-desconocido} -> dbtype objetivo: $TARGET_DBTYPE"

# --- Backup de config.php ---
TS="$(date +%Y%m%d-%H%M%S)"
cp -a "$CONFIG_PHP" "${CONFIG_PHP}.bak-${TS}"

# --- Cambiar $CFG->dbtype en config.php ---
# Reemplaza cualquier valor actual por el correcto
sed -i "s/^\(\s*\$CFG->dbtype\s*=\s*\).*;$/\1'${TARGET_DBTYPE}';/" "$CONFIG_PHP"

# Si por alguna razón la línea no existiera, la añadimos antes de require setup.php
grep -q "^\s*\$CFG->dbtype\s*=" "$CONFIG_PHP" || \
  sed -i "/require_once/s|^|\\$CFG->dbtype = '${TARGET_DBTYPE}';\n|" "$CONFIG_PHP"

# --- Mostrar el valor resultante ---
echo ">>> dbtype en config.php ahora es:"
grep -n "\$CFG->dbtype" "$CONFIG_PHP" || true

# --- Reiniciar Apache para asegurar carga de extensiones ---
systemctl restart apache2 || true

echo ">>> Listo ✅  Se ajustó \$CFG->dbtype a '${TARGET_DBTYPE}' y se aseguró php-mysql (mysqli)."
echo "Backup creado: ${CONFIG_PHP}.bak-${TS}"
