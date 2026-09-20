#!/bin/sh

set -eu

# ===== CONFIG =====
MOODLE_DIR="/var/www/html/moodle"
MOODLEDATA_DIR="/var/moodledata"

DB_HOST="localhost"
DB_NAME="moodle"
DB_USER="moodleuser"
DB_PORT="3306"
DB_ROOT_PASS="${DB_ROOT_PASS:-TuClaveRoot}"   # Clave root de MySQL para poder borrar la BD

BACKUP="yes"                                  # "yes" o "no"
BACKUP_DIR="/root/moodle_backups"
# ==================

# Root check
if [ "$(id -u)" -ne 0 ]; then
  echo "[ERROR] Ejecuta como root (sudo)." 1>&2
  exit 1
fi

# Confirmación
printf "¡ADVERTENCIA! ¿Borrar Moodle por completo (archivos, moodledata, DB %s, usuario %s)? [yes/N]: " "$DB_NAME" "$DB_USER"
read ans || ans=""
[ "${ans:-}" = "yes" ] || { echo "Cancelado."; exit 0; }

TS="$(date +%Y%m%d-%H%M%S)"

# Backups
if [ "$BACKUP" = "yes" ]; then
  mkdir -p "$BACKUP_DIR"
  [ -d "$MOODLE_DIR" ]      && tar -czf "${BACKUP_DIR}/moodle_code_${TS}.tar.gz"     -C "$(dirname "$MOODLE_DIR")"      "$(basename "$MOODLE_DIR")"
  [ -d "$MOODLEDATA_DIR" ] && tar -czf "${BACKUP_DIR}/moodledata_${TS}.tar.gz"     -C "$(dirname "$MOODLEDATA_DIR")" "$(basename "$MOODLEDATA_DIR")"
  if command -v mysqldump >/dev/null 2>&1; then
    mysqldump -h "$DB_HOST" -P "$DB_PORT" -u root -p"$DB_ROOT_PASS" "$DB_NAME" > "${BACKUP_DIR}/db_${DB_NAME}_${TS}.sql" || true
  fi
fi

# Eliminar cron
CRON_FILE="/etc/cron.d/moodle"
[ -f "$CRON_FILE" ] && rm -f "$CRON_FILE"
if command -v crontab >/dev/null 2>&1; then
  ( crontab -u www-data -l 2>/dev/null | grep -v "moodle/admin/cli/cron.php" ) | crontab -u www-data - 2>/dev/null || true
fi

# Borrar archivos de Moodle y Data
[ -d "$MOODLE_DIR" ]      && rm -rf "$MOODLE_DIR"
[ -d "$MOODLEDATA_DIR" ] && rm -rf "$MOODLEDATA_DIR"

# Borrar Base de Datos y Usuarios en MySQL/MariaDB
echo ">>> Eliminando base de datos y usuarios..."
mysql -h "$DB_HOST" -P "$DB_PORT" -u root -p"$DB_ROOT_PASS" -e "
  DROP DATABASE IF EXISTS \`${DB_NAME}\`;
  DROP USER IF EXISTS '${DB_USER}'@'${DB_HOST}';
  DROP USER IF EXISTS '${DB_USER}'@'%';
  FLUSH PRIVILEGES;
" || true

echo ">>> Purgado de Moodle COMPLETADO con éxito ✅"