#!/bin/bash
# ===========================================================
# Script de instalación + ejemplos de uso (cuando aplica)
# Ubuntu 22.04 / 24.04 LTS
# Uso:
#   sudo ./04_install_app.sh           # solo instala
#   sudo ./04_install_app.sh --demo    # instala + corre ejemplos no interactivos
# ============================================================


DEMO=0
if [[ "${1:-}" == "--demo" ]]; then DEMO=1; fi

# --- Verificar privilegios ---
if [ "$(id -u)" -ne 0 ]; then
  echo "[ERROR] Este script debe ejecutarse como root o con sudo."
  exit 1
fi

log() { echo -e "\n>>> $*"; }

run_demo() {
  if [[ $DEMO -eq 1 ]]; then eval "$1"; fi
}

log "Actualizando lista de paquetes..."
apt update -y

# ---------- UTILIDADES DE USUARIO ----------
log "Instalando utilidades de usuario…"

# apg — Generador de contraseñas seguras.
apt install -y apg
run_demo "echo '# apg ejemplo:'; apg -m 16 -x 16 -n 3 -M SNCL"

# atop — Monitor avanzado de rendimiento.
apt install -y atop
run_demo "echo '# atop versión:'; atop -V || true"

# bmon — Monitor de ancho de banda en consola.
apt install -y bmon
run_demo "echo '# bmon ayuda (primeras líneas):'; bmon -h | head -n 10"

# byobu — Capa mejorada sobre tmux/screen.
apt install -y byobu
run_demo "echo '# byobu ayuda:'; byobu -h | head -n 12"

# ccze — Colorea logs en la terminal.
apt install -y ccze
run_demo "echo '# ccze coloreando /var/log/dpkg.log (si existe):'; test -f /var/log/dpkg.log && tail -n 20 /var/log/dpkg.log | ccze -A || true"

# cmatrix — Animación tipo Matrix (decorativo).
apt install -y cmatrix
run_demo "echo '# cmatrix demo (1s)…'; timeout 1 cmatrix || true"

# console-setup / console-setup-linux — Configuración de consola/teclado.
apt install -y console-setup console-setup-linux
run_demo "echo '# Ver consola/teclado actual:'; localectl status || true"

# cron / cron-daemon-common — Programación de tareas.
apt install -y cron cron-daemon-common
run_demo "echo '# Crear cron de ejemplo (echo timestamp cada minuto a /tmp/cron_demo.log)…'; echo '* * * * * root date >> /tmp/cron_demo.log' >/etc/cron.d/demo_cron; chmod 644 /etc/cron.d/demo_cron; systemctl reload cron || service cron reload || true"

# gawk — Procesamiento de texto (AWK).
apt install -y gawk
run_demo "echo '# gawk sumatoria 1..5:'; seq 5 | gawk '{s+=\$1} END{print s}'"

# gettext-base — i18n de mensajes.
apt install -y gettext-base
run_demo "echo '# envsubst ejemplo:'; VAR=Ubuntu echo 'Hola ${VAR}' | envsubst"

# hollywood — Escenas estilo “hacker movie” (demo visual).
apt install -y hollywood
run_demo "echo '# hollywood (1s)…'; timeout 1 hollywood || true"

# htop — Monitor interactivo de procesos.
apt install -y htop
run_demo "echo '# htop versión:'; htop --version | head -n 1"

# iproute2 — Herramientas modernas de red (ip, ss…).
apt install -y iproute2
run_demo "echo '# ip link y ss -tuna breve:'; ip -brief link; ss -tuna | head -n 5 || true"

# jp2a — JPEG a ASCII en consola.
apt install -y jp2a
run_demo "echo '# jp2a ayuda:'; jp2a --help | head -n 8"

# kbd / keyboard-configuration — Utilidades de teclado.
apt install -y kbd keyboard-configuration
run_demo "echo '# showkey (no-interactivo, solo ayuda):'; showkey --help | head -n 6 || true"

# moreutils — Herramientas extra (sponge, ts…).
apt install -y moreutils
run_demo "echo '# sponge ejemplo (quita buffering):'; printf 'A\nB\n' | sponge /tmp/sponge_demo.txt; cat /tmp/sponge_demo.txt"

# pastebinit — Subir texto a pastebin desde terminal.
apt install -y pastebinit
run_demo "echo '# pastebinit ejemplo (dry):'; echo 'demo paste' | pastebinit -b http://paste.ubuntu.com -i - || true"

# plocate — Búsqueda de archivos, rápido (mlocate moderno).
apt install -y plocate
run_demo "echo '# plocate kernel | head:'; updatedb || true; plocate -l 5 vmlinuz || true"

# run-one — Evitar instancias duplicadas.
apt install -y run-one
run_demo "echo '# run-one ejemplo (sleep 1):'; run-one -n demo_sleep bash -c 'sleep 1' && echo OK"

# speedometer — Velocidad de red/disco en texto.
apt install -y speedometer
run_demo "echo '# speedometer ayuda:'; speedometer -h | head -n 10"

# tmux — Multiplexor de terminal.
apt install -y tmux
run_demo "echo '# tmux versión:'; tmux -V"

# tree — Árbol de directorios.
apt install -y tree
run_demo "echo '# tree /etc (primeros 20):'; tree -L 1 /etc | head -n 20"

# xkb-data — Layouts de teclado para X.Org.
apt install -y xkb-data
run_demo "echo '# xkb layouts (grep latam):'; grep -R \"latam\" /usr/share/X11/xkb/symbols 2>/dev/null | head -n 3 || true"

# ---------- LIBRERÍAS Y DEPENDENCIAS ----------
log "Instalando librerías del sistema… (ejemplos = verificación/presencia)"

# Nota: muchas librerías no tienen binarios; se demuestra su presencia o módulos relacionados.

apt install -y libatm1t64         # Soporte ATM (Asynchronous Transfer Mode).
run_demo "echo '# libatm presente:'; ldconfig -p | grep -E 'libatm\\.so' || true"

apt install -y libbpf1            # eBPF userland.
run_demo "echo '# libbpf presente:'; ldconfig -p | grep -E 'libbpf\\.so' || true"

apt install -y libconfuse-common  # Archivos comunes para libconfuse.
apt install -y libconfuse2        # Parser de configs en C.
run_demo "echo '# libconfuse presente:'; ldconfig -p | grep -E 'libconfuse\\.so' || true"

apt install -y libevent-core-2.1-7t64  # Eventos async.
run_demo "echo '# libevent presente:'; ldconfig -p | grep -E 'libevent_core|libevent-2' || true"

apt install -y libfribidi0        # Bidi text (árabe/hebreo).
run_demo "echo '# libfribidi presente:'; ldconfig -p | grep -E 'libfribidi\\.so' || true"

apt install -y libio-pty-perl     # Perl: IO::Pty
run_demo "echo '# Perl IO::Pty versión:'; perl -MIO::Pty -e 'print \$IO::Pty::VERSION||\"ok\"' 2>/dev/null; echo"

apt install -y libipc-run-perl    # Perl: IPC::Run
run_demo "echo '# Perl IPC::Run versión:'; perl -MIPC::Run -e 'print \$IPC::Run::VERSION||\"ok\"' 2>/dev/null; echo"

apt install -y libmnl0            # Netlink mínima.
run_demo "echo '# libmnl presente:'; ldconfig -p | grep -E 'libmnl\\.so' || true"

apt install -y libncurses6        # Interfaces de texto.
run_demo "echo '# tput con ncurses:'; tput cols; tput lines"

apt install -y libnewt0.52        # Diálogos modo texto (newt).
run_demo "echo '# libnewt presente:'; ldconfig -p | grep -E 'libnewt\\.so' || true"

apt install -y libnl-3-200 libnl-genl-3-200 libnl-route-3-200  # Netlink base/genl/ruta.
run_demo "echo '# libnl presentes:'; ldconfig -p | grep -E 'libnl-(3|genl-3|route-3)\\.so' || true"

apt install -y libsigsegv2        # Manejo de SIGSEGV.
run_demo "echo '# libsigsegv presente:'; ldconfig -p | grep -E 'libsigsegv\\.so' || true"

apt install -y libslang2          # API texto/terminal.
run_demo "echo '# libslang presente:'; ldconfig -p | grep -E 'libslang\\.so' || true"

apt install -y libtime-duration-perl  # Perl: Time::Duration
run_demo "echo '# Perl Time::Duration:'; perl -MTime::Duration -e 'print Time::Duration::duration(125)' 2>/dev/null; echo"

apt install -y libtimedate-perl       # Perl: Date::Parse/Date::Format
run_demo "echo '# Perl Date::Parse str2time:'; perl -MDate::Parse -e 'print scalar localtime(str2time(\"2025-09-09 12:00\"))' 2>/dev/null; echo"

apt install -y liburing2          # IO con io_uring.
run_demo "echo '# liburing presente:'; ldconfig -p | grep -E 'liburing\\.so' || true"

apt install -y libutempter0       # Manejo de utmp/wtmp.
run_demo "echo '# libutempter presente:'; ldconfig -p | grep -E 'libutempter\\.so' || true"

apt install -y libxtables12       # Backend iptables.
run_demo "echo '# iptables-save | head:'; iptables-save | head -n 5 || true"

# ---------- PAQUETES PYTHON3 ----------
log "Instalando paquetes Python3… (import de ejemplo donde aplica)"

apt install -y python3-newt             # Enlace a newt (módulo 'snack' suele estar disponible).
run_demo "echo '# Python snack/newt import (si existe):'; python3 - <<'PY'\ntry:\n    import snack\n    print('snack OK')\nexcept Exception as e:\n    print('snack no disponible:', e)\nPY"

apt install -y python3-psutil           # Info de procesos/sistema.
apt install -y python3-typing-extensions
apt install -y python3-urwid            # UI consola (no interactivo en demo).
apt install -y python3-wcwidth          # Ancho Unicode.

sudo apt autoremove -y

run_demo "echo '# Python imports (psutil, typing_extensions, urwid, wcwidth):'; python3 - <<'PY'\nimport psutil, typing_extensions, urwid, wcwidth\nprint('cpu_count:', psutil.cpu_count())\nprint('width(á🙂):', wcwidth.wcswidth('á🙂'))\nprint('OK imports')\nPY"

log "Instalación finalizada."
if [[ $DEMO -eq 1 ]]; then
  log "Modo demo: se ejecutaron ejemplos no interactivos ✅"
else
  log "Para ver ejemplos de uso, ejecuta: sudo ./04_install_app.sh --demo"
fi
