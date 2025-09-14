#!/usr/bin/env

#

# --- Detectar versión de PHP automáticamente ---
PHP_VERSION=$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;')
INI_APACHE="/etc/php/${PHP_VERSION}/apache2/php.ini"
INI_CLI="/etc/php/${PHP_VERSION}/cli/php.ini"

# --- Verificar privilegios ---
if [ "$(id -u)" -ne 0 ]; then
  echo "[ERROR] Ejecuta como root o con sudo."
  exit 1
fi

# --- Función para modificar parámetros en php.ini ---
update_ini() {
  FILE="$1"
  echo ">>> Ajustando configuración en $FILE"

  sed -i 's/^;\?max_execution_time = .*/max_execution_time = 300/' "$FILE"
  sed -i 's/^;\?max_input_vars = .*/max_input_vars = 5000/' "$FILE"
  sed -i 's/^;\?post_max_size = .*/post_max_size = 100M/' "$FILE"
  sed -i 's/^;\?upload_max_filesize = .*/upload_max_filesize = 100M/' "$FILE"
  sed -i 's/^;\?memory_limit = .*/memory_limit = 512M/' "$FILE"

  # --- Descomentar extensiones requeridas ---
  sed -i 's/^;\?extension=curl/extension=curl/' "$FILE"
  sed -i 's/^;\?extension=gd/extension=gd/' "$FILE"
  sed -i 's/^;\?extension=intl/extension=intl/' "$FILE"
  sed -i 's/^;\?extension=mbstring/extension=mbstring/' "$FILE"
  sed -i 's/^;\?extension=soap/extension=soap/' "$FILE"
  sed -i 's/^;\?extension=xml/extension=xml/' "$FILE"
  sed -i 's/^;\?extension=zip/extension=zip/' "$FILE"
  sed -i 's/^;\?extension=opcache/extension=opcache/' "$FILE"
  sed -i 's/^;\?extension=ldap/extension=ldap/' "$FILE"
}

# --- Función para habilitar extensiones con phpenmod ---
enable_extensions() {
  echo ">>> Habilitando extensiones PHP necesarias..."
  phpenmod curl || true
  phpenmod gd || true
  phpenmod intl || true
  phpenmod mbstring || true
  phpenmod soap || true
  phpenmod xml || true
  phpenmod zip || true
  phpenmod opcache || true
  phpenmod ldap || true   # opcional
}

update_ini "$INI_APACHE"
update_ini "$INI_CLI"
enable_extensions

echo ">>> Reiniciando Apache..."
systemctl restart apache2

echo ">>> Configuración de PHP ajustada para Moodle ✅"
echo ""
echo "Parámetros aplicados:"
echo "  max_execution_time = 300"
echo "  max_input_vars = 5000"
echo "  post_max_size = 100M"
echo "  upload_max_filesize = 100M"
echo "  memory_limit = 512M"
echo ""
echo "Extensiones descomentadas y habilitadas:"
echo "  curl, gd, intl, mbstring, soap, xml, zip, opcache, ldap (opcional)"
