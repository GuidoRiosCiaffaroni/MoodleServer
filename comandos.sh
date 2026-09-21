#!/bin/bash

# Verificar si el alias ya existe
if grep -q "alias ll=" ~/.bashrc; then
    echo "El alias ll ya está configurado."
else
    echo "" >> ~/.bashrc
    echo "# Alias ll" >> ~/.bashrc
    echo "alias ll='ls -alF'" >> ~/.bashrc
    echo "Alias ll agregado a ~/.bashrc"
fi

# Recargar configuración
source ~/.bashrc

echo "Configuración finalizada."


cat > /etc/profile.d/ll_alias.sh << 'EOF'
alias ll='ls -alF'
EOF

chmod 644 /etc/profile.d/ll_alias.sh

echo "Alias ll instalado para todos los usuarios."