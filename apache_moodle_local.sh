#!/usr/bin/env bash
set -euo pipefail

# --- Verificar privilegios ---
if [ "$(id -u)" -ne 0 ]; then
  echo "[ERROR] Este script debe ejecutarse como root o con sudo."
  exit 1
fi

# --- Variables ---
APACHE_CONF="/etc/apache2/sites-available/moodle.conf"
MOODLE_DIR="/var/www/html/moodle"

# Modo de acceso:
# true  -> solo localhost (misma máquina)
# false -> LAN (red local)
LOCAL_ONLY=true

echo ">>> Creando configuración de Apache para Moodle..."

if [ "${LOCAL_ONLY}" = true ]; then
  ACCESS_BLOCK=$(cat <<'ACL'
    # Acceso solo desde la máquina local
    Require local
ACL
)
  SERVER_NAME="localhost"
  SERVER_ALIAS="127.0.0.1"
else
  ACCESS_BLOCK=$(cat <<'ACL'
    # Acceso desde LAN (IPs privadas típicas)
    Require ip 10.0.0.0/8
    Require ip 172.16.0.0/12
    Require ip 192.168.0.0/16
ACL
)
  # Puedes poner aquí un hostname de tu LAN si quieres
  SERVER_NAME="$(hostname -I | awk '{print $1}')"
  SERVER_ALIAS=""
fi

cat > "${APACHE_CONF}" <<EOF
<VirtualHost *:80>
    ServerAdmin admin@local
    ServerName ${SERVER_NAME}
    ServerAlias ${SERVER_ALIAS}

    DocumentRoot ${MOODLE_DIR}

    <Directory ${MOODLE_DIR}>
        Options +FollowSymlinks
        AllowOverride All
${ACCESS_BLOCK}
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/moodle_error.log
    CustomLog \${APACHE_LOG_DIR}/moodle_access.log combined
</VirtualHost>
EOF

echo ">>> Habilitando módulos necesarios..."
a2enmod rewrite >/dev/null

echo ">>> (Opcional) Deshabilitar el sitio por defecto si estorba..."
a2dissite 000-default.conf >/dev/null 2>&1 || true

echo ">>> Habilitando el sitio de Moodle..."
a2ensite moodle.conf >/dev/null

echo ">>> Probando configuración..."
apache2ctl configtest

echo ">>> Recargando Apache..."
systemctl reload apache2

echo ">>> Listo ✅"

if [ "${LOCAL_ONLY}" = true ]; then
  echo "Acceso local:   http://localhost/    (Moodle en ${MOODLE_DIR})"
else
  IP="$(hostname -I | awk '{print $1}')"
  echo "Acceso en LAN:  http://${IP}/        (desde equipos de tu red)"
  echo "Si quieres usar un nombre (p. ej. moodle.local), añade una entrada en /etc/hosts de los clientes:"
  echo "  ${IP}  moodle.local"
fi
