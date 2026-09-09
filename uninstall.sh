#!/bin/bash
# uninstall.sh — Revierte el tema Uma Musume y restaura el GRUB por defecto
# Uso: sudo ./uninstall.sh [ruta_al_backup]

set -e

THEME_NAME="uma-musume"
GRUB_THEMES_DIR="/boot/grub/themes"
TARGET_DIR="$GRUB_THEMES_DIR/$THEME_NAME"
GRUB_DEFAULT="/etc/default/grub"

if [[ $EUID -ne 0 ]]; then
   echo "Este script necesita permisos root. Ejecuta: sudo ./uninstall.sh"
   exit 1
fi

BACKUP_FILE="$1"

if [[ -z "$BACKUP_FILE" ]]; then
    # Busca el backup más reciente automáticamente
    BACKUP_FILE=$(ls -t /etc/default/grub.bak.* 2>/dev/null | head -n1 || true)
fi

if [[ -n "$BACKUP_FILE" && -f "$BACKUP_FILE" ]]; then
    echo "==> Restaurando $GRUB_DEFAULT desde $BACKUP_FILE"
    cp "$BACKUP_FILE" "$GRUB_DEFAULT"
else
    echo "==> No se encontró backup automático, quitando solo la línea GRUB_THEME manualmente"
    sed -i '/^GRUB_THEME=/d' "$GRUB_DEFAULT"
fi

echo "==> Eliminando carpeta del tema: $TARGET_DIR"
rm -rf "$TARGET_DIR"

echo "==> Regenerando grub.cfg (update-grub)"
update-grub

echo ""
echo "✅ Tema desinstalado, GRUB restaurado a su configuración anterior."
