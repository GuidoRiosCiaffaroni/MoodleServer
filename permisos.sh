#!/usr/bin/
# --- Configurables ---
MOODLE_DIR="/var/www/html/moodle"   # carpeta del código de Moodle
DATA_DIR="/var/moodledata"          # ubicación recomendada para datos (fuera de /var/www)
# Si quieres forzar usar /var/www/moodledata, descomenta la siguiente línea:
# DATA_DIR="/var/www/moodledata"

WEB_USER="www-data"
WEB_GROUP="www-data"

# --- Verificaciones básicas ---
if [ "$(id -u)" -ne 0 ]; then
  echo "[ERROR] Ejecuta este script como root (sudo)." >&2
  exit 1
fi

id -u "$WEB_USER" >/dev/null 2>&1 || {
  echo "[ERROR] No existe el usuario $WEB_USER (¿Apache instalado?)." >&2
  exit 2
}

echo ">>> Creando directorio de datos: $DATA_DIR"
mkdir -p "$DATA_DIR"

echo ">>> Asignando propiedad a $WEB_USER:$WEB_GROUP"
chown -R "$WEB_USER:$WEB_GROUP" "$DATA_DIR"

echo ">>> Estableciendo permisos seguros"
# 770: sólo propietario y grupo pueden leer/escribir/ejecutar
chmod -R 770 "$DATA_DIR"

# --- ACL opcional para heredar permisos del grupo (útil cuando administras con tu usuario) ---
echo ">>> (Opcional) Configurando ACL para herencia de permisos (si 'acl' está disponible)"
if ! dpkg -s acl >/dev/null 2>&1; then
  apt-get update -y && apt-get install -y acl
fi
setfacl -R -m u:${WEB_USER}:rwx,g:${WEB_GROUP}:rwx "$DATA_DIR"
setfacl -dR -m u:${WEB_USER}:rwx,g:${WEB_GROUP}:rwx "$DATA_DIR"

# --- Ajustar permisos del código de Moodle (por si faltaba) ---
if [ -d "$MOODLE_DIR" ]; then
  echo ">>> Ajustando permisos del código: $MOODLE_DIR"
  chown -R "$WEB_USER:$WEB_GROUP" "$MOODLE_DIR"
  find "$MOODLE_DIR" -type d -exec chmod 755 {} \;
  find "$MOODLE_DIR" -type f -exec chmod 644 {} \;
fi

# --- Verificación rápida: ¿www-data puede escribir en el directorio de datos? ---
echo ">>> Verificando escritura como $WEB_USER en $DATA_DIR"
sudo -u "$WEB_USER" bash -c "touch '$DATA_DIR/.perm_test' && rm -f '$DATA_DIR/.perm_test'" \
  && echo 'OK: www-data puede escribir en el directorio de datos.' \
  || { echo 'ERROR: www-data NO puede escribir en el directorio de datos.'; exit 3; }

echo ">>> Listo ✅"
echo "Ahora, en el instalador de Moodle, usa este valor para 'Directorio de Datos':"
echo "  $DATA_DIR"
if [[ "$DATA_DIR" == /var/www/* ]]; then
  echo "ADVERTENCIA: Usar un directorio de datos dentro de /var/www no es recomendado por seguridad."
else
  echo "Recomendado y seguro: el directorio de datos está fuera de /var/www."
fi
