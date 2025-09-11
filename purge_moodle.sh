#!/usr/bin/
# =======================
#  CONFIGURACIÓN
# =======================

# Ruta donde está el código de Moodle
MOODLE_DIR="/var/www/html/moodle"

# Ruta de moodledata (fuera de /var/www por seguridad)
MOODLEDATA_DIR="/var/moodledata"

# Archivo de configuración de Apache usado por Moodle
APACHE_SITE="moodle.conf"   # /etc/apache2/sites-available/moodle.conf

# Archivo cron de Moodle (ajusta si lo pusiste en otra ruta)
CRON_FILE="/etc/cron.d/moodle"

# Base de datos y usuario de Moodle
DB_HOST="localhost"
DB_NAME="moodle"
DB_USER="moodleuser"

# Contraseña de root de MySQL/MariaDB
# ⚠️ Ajusta esta línea con tu clave de root antes de ejecutar
export DB_ROOT_PASS='TuClaveRoot'

# Respaldos antes de borrar (yes/no)
BACKUP_BEFORE_DELETE="yes"
BACKUP_DIR="/root/moodle_backups"

# =======================
#  FUNCIONES AUXILIARES
# =======================

# Verifica que se ejecute como root
need_root() {
  if [[ "$(id -u)" -ne 0 ]]; then
    echo "[ERROR] Ejecuta como root (sudo)." >&2
    exit 1
  fi
}

# Confirmación interactiva antes de borrar
confirm() {
  read -r -p "¿Seguro que quieres BORRAR Moodle (archivos, moodledata, DB ${DB_NAME}, usuario ${DB_USER})? [yes/N]: " ans
  [[ "${ans:-}" == "yes" ]]
}

# Mostrar mensajes con formato
msg() { echo -e "\n==> $*"; }

# Ejecutar comandos MySQL con la clave de root
mysql_exec() {
  if [[ -n "$DB_ROOT_PASS" ]]; then
    mysql --protocol=TCP -h "$DB_HOST" -u root -p"$DB_ROOT_PASS" -e "$1"
  else
    echo "[ADVERTENCIA] No definiste DB_ROOT_PASS. Se pedirá la contraseña de MySQL/MariaDB."
    mysql --protocol=TCP -h "$DB_HOST" -u root -p -e "$1"
  fi
}

# Respaldar código, moodledata y la base de datos
backup_if_needed() {
  if [[ "$BACKUP_BEFORE_DELETE" == "yes" ]]; then
    mkdir -p "$BACKUP_DIR"
    TS="$(date +%Y%m%d-%H%M%S)"

    [[ -d "$MOODLE_DIR" ]] && {
      msg "Respaldando código Moodle..."
      tar -czf "${BACKUP_DIR}/moodle_code_${TS}.tar.gz" -C "$(dirname "$MOODLE_DIR")" "$(basename "$MOODLE_DIR")"
    }

    [[ -d "$MOODLEDATA_DIR" ]] && {
      msg "Respaldando moodledata..."
      tar -czf "${BACKUP_DIR}/moodledata_${TS}.tar.gz" -C "$(dirname "$MOODLEDATA_DIR")" "$(basename "$MOODLEDATA_DIR")"
    }

    if command -v mysqldump >/dev/null 2>&1; then
      msg "Respaldando base de datos ${DB_NAME}..."
      mysqldump -h "$DB_HOST" -u root -p"$DB_ROOT_PASS" "$DB_NAME" > "${BACKUP_DIR}/db_${DB_NAME}_${TS}.sql" || true
    fi

    msg "Respaldos guardados en ${BACKUP_DIR}"
  fi
}

# Eliminar configuración de Apache
purge_apache() {
  if [[ -f "/etc/apache2/sites-available/${APACHE_SITE}" ]]; then
    msg "Deshabilitando sitio Apache ${APACHE_SITE}..."
    a2dissite "${APACHE_SITE}" || true
    rm -f "/etc/apache2/sites-available/${APACHE_SITE}"
  fi
  rm -f "/etc/apache2/sites-enabled/${APACHE_SITE}"
  systemctl reload apache2 || true
}

# Eliminar cron jobs relacionados con Moodle
purge_cron() {
  if [[ -f "$CRON_FILE" ]]; then
    msg "Eliminando cron de Moodle..."
    rm -f "$CRON_FILE"
    systemctl reload cron 2>/dev/null || true
  fi
  if command -v crontab >/dev/null 2>&1; then
    crontab -u www-data -l 2>/dev/null | grep -v "moodle/admin/cli/cron.php" | crontab -u www-data - 2>/dev/null || true
  fi
}

# Eliminar archivos y carpetas
purge_files() {
  [[ -d "$MOODLE_DIR" ]] && { msg "Eliminando código Moodle..."; rm -rf "$MOODLE_DIR"; }
  [[ -d "$MOODLEDATA_DIR" ]] && { msg "Eliminando moodledata..."; rm -rf "$MOODLEDATA_DIR"; }
}

# Eliminar base de datos y usuario
purge_db() {
  msg "Eliminando base de datos y usuario..."
  mysql_exec "DROP DATABASE IF EXISTS \`${DB_NAME}\`;"
  mysql_exec "DROP USER IF EXISTS '${DB_USER}'@'${DB_HOST}';"
  mysql_exec "DROP USER IF EXISTS '${DB_USER}'@'%';"
  mysql_exec "FLUSH PRIVILEGES;"
}

# =======================
#  MAIN
# =======================

need_root
confirm || { echo "Cancelado."; exit 0; }

backup_if_needed
purge_cron
purge_apache
purge_files
purge_db

msg "Purgado de Moodle COMPLETADO ✅"
