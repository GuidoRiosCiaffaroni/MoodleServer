#!/usr/bin/env bash

set -Eeuo pipefail

# ====== CONFIGURACIÓN ======
DB_HOST="localhost"
DB_NAME="moodle"
DB_USER="moodleuser"
DB_PASS="123"
DB_PORT="3306"
DB_SOCKET=""

BACKUP_DIR="/var/backups/mysql"
DAYS_TO_KEEP=7

# ====== PREPARACIÓN ======
mkdir -p "$BACKUP_DIR"

TS="$(date '+%Y%m%d-%H%M%S')"
OUT_SQL="${BACKUP_DIR}/${DB_NAME}-${TS}.sql"
OUT_GZ="${OUT_SQL}.gz"

# ====== RESPALDO ======
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

# Comprimir
gzip -9 "$OUT_SQL"

# Checksum para verificar integridad
sha256sum "$OUT_GZ" > "${OUT_GZ}.sha256"

# ====== ROTACIÓN ======
find "$BACKUP_DIR" -type f -name "${DB_NAME}-*.sql.gz" -mtime +"$DAYS_TO_KEEP" -delete
find "$BACKUP_DIR" -type f -name "${DB_NAME}-*.sha256" -mtime +"$DAYS_TO_KEEP" -delete

echo ">>> Respaldo completado "
echo "Archivo generado: $OUT_GZ"
