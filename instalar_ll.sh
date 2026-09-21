#!/bin/bash

ARCHIVO="$HOME/.bashrc"

if grep -q "^alias ll=" "$ARCHIVO"; then
    echo "El alias ll ya existe."
else
    echo "" >> "$ARCHIVO"
    echo "alias ll='ls -alF'" >> "$ARCHIVO"
    echo "Alias ll agregado correctamente."
fi

echo "Recargando configuración..."
source "$ARCHIVO"

echo "Prueba ejecutando: ll"
