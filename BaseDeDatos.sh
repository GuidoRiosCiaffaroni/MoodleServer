#!/usr/bin/

#

# --- Configuración (cámbiala según tu necesidad) ---
DB_HOST="localhost"
DB_NAME="moodle"
DB_USER="moodleuser"
DB_PASS="123"
DB_PREFIX="mdl_"
DB_PORT="3306"
DB_SOCKET=""

MOODLE_DIR="/var/www/html/moodle"

# --- Verificar root ---
if [ "$(id -u)" -ne 0 ]; then
  echo "[ERROR] Ejecuta este script como root (sudo)."
  exit 1
fi

# --- Crear base de datos y usuario ---
echo ">>> Creando base de datos y usuario en MySQL/MariaDB..."
mysql -u root <<MYSQL_SCRIPT
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '${DB_USER}'@'${DB_HOST}' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'${DB_HOST}';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

# --- Crear config.php ---
echo ">>> Generando archivo config.php en $MOODLE_DIR"
cat > "${MOODLE_DIR}/config.php" <<EOF
<?php
unset(\$CFG);
global \$CFG;
\$CFG = new stdClass();

\$CFG->dbtype    = 'mysqli';
\$CFG->dblibrary = 'native';
\$CFG->dbhost    = '${DB_HOST}';
\$CFG->dbname    = '${DB_NAME}';
\$CFG->dbuser    = '${DB_USER}';
\$CFG->dbpass    = '${DB_PASS}';
\$CFG->prefix    = '${DB_PREFIX}';
\$CFG->dboptions = array(
  'dbpersist' => 0,
  'dbport' => '${DB_PORT}',
  'dbsocket' => '${DB_SOCKET}',
  'dbcollation' => 'utf8mb4_unicode_ci',
);

\$CFG->wwwroot   = 'http://localhost/moodle';
\$CFG->dataroot  = '/var/moodledata';
\$CFG->admin     = 'admin';

\$CFG->directorypermissions = 0777;

require_once(__DIR__ . '/lib/setup.php');
EOF

chown www-data:www-data "${MOODLE_DIR}/config.php"
chmod 640 "${MOODLE_DIR}/config.php"

echo ">>> Configuración de Moodle lista ✅"
echo ""
echo "Base de datos: $DB_NAME"
echo "Usuario:       $DB_USER"
echo "Contraseña:    $DB_PASS"
echo "Archivo:       ${MOODLE_DIR}/config.php"
