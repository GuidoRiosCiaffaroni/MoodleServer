#!/usr/bin/env bash

set -Eeuo pipefail

# ====== CONFIGURACIÓN BASE DE DATOS ======
DB_HOST="localhost"
DB_NAME="moodle"
DB_USER="moodleuser"
DB_PASS="123"
DB_PORT="3306"

# ====== CONFIGURACIÓN DIRECTORIOS ======
MOODLEDATA="/var/www/moodledata"
MOODLE_DIR="/var/www/html/moodle"

# ====== CONFIGURACIÓN GENERAL ======
BACKUP_DIR="/var/backups/moodle"
DAYS_TO_KEEP=7
TS="$(date '+%Y%m%d-%H%M%S')"

# Crear carpeta de backup si no existe
mkdir -p "$BACKUP_DIR"

# ====== RESPALDO DE BASE DE DATOS ======
OUT_SQL="${BACKUP_DIR}/${DB_NAME}-${TS}.sql"
OUT_GZ="${OUT_SQL}.gz"

echo ">>> Respaldando base de datos '${DB_NAME}' en ${OUT_GZ}"

mysqldump \
  -h "$DB_HOST" \
  -P "$DB_PORT" \
  -u "$DB_USER" \
  -p"$DB_PASS" \
  --single-transaction \
  --quick \
  --routines \
  --triggers \
  --events \
  --default-character-set=utf8mb4 \
  "$DB_NAME" > "$OUT_SQL"

gzip -9 "$OUT_SQL"
sha256sum "$OUT_GZ" > "${OUT_GZ}.sha256"

# ====== RESPALDO DE DIRECTORIOS ======
echo ">>> Respaldando directorio moodledata..."
tar -czf "${BACKUP_DIR}/moodledata-${TS}.tar.gz" -C /var/www moodledata
sha256sum "${BACKUP_DIR}/moodledata-${TS}.tar.gz" > "${BACKUP_DIR}/moodledata-${TS}.tar.gz.sha256"

echo ">>> Respaldando directorio moodle..."
tar -czf "${BACKUP_DIR}/moodle-${TS}.tar.gz" -C /var/www/html moodle
sha256sum "${BACKUP_DIR}/moodle-${TS}.tar.gz" > "${BACKUP_DIR}/moodle-${TS}.tar.gz.sha256"

# ====== ROTACIÓN DE RESPALDOS ======
echo ">>> Rotando respaldos, manteniendo ${DAYS_TO_KEEP} días..."
find "$BACKUP_DIR" -type f -mtime +"$DAYS_TO_KEEP" -print -delete || true

# ====== FINAL ======
echo ">>> Respaldo COMPLETADO "
echo "Archivos generados en: $BACKUP_DIR"
