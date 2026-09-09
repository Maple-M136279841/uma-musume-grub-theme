#!/bin/bash
# install.sh — Instala el tema Uma Musume para GRUB2 en Kali Linux
# Uso: sudo ./install.sh

set -e

THEME_NAME="uma-musume"
GRUB_THEMES_DIR="/boot/grub/themes"
TARGET_DIR="$GRUB_THEMES_DIR/$THEME_NAME"
GRUB_DEFAULT="/etc/default/grub"
BACKUP_FILE="/etc/default/grub.bak.$(date +%Y%m%d%H%M%S)"

# Directorio del script (para copiar theme/ relativo a donde vive install.sh)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_THEME_DIR="$SCRIPT_DIR/theme"

if [[ $EUID -ne 0 ]]; then
   echo "Este script necesita permisos root. Ejecuta: sudo ./install.sh"
   exit 1
fi

if [[ ! -d "$SOURCE_THEME_DIR" ]]; then
    echo "Error: no se encontró la carpeta 'theme/' junto a este script ($SOURCE_THEME_DIR)."
    exit 1
fi

echo "==> Haciendo backup de $GRUB_DEFAULT en $BACKUP_FILE"
cp "$GRUB_DEFAULT" "$BACKUP_FILE"

echo "==> Copiando tema a $TARGET_DIR"
mkdir -p "$GRUB_THEMES_DIR"
rm -rf "$TARGET_DIR"
cp -r "$SOURCE_THEME_DIR" "$TARGET_DIR"

echo "==> Configurando GRUB_THEME en $GRUB_DEFAULT"
if grep -q "^GRUB_THEME=" "$GRUB_DEFAULT"; then
    sed -i "s|^GRUB_THEME=.*|GRUB_THEME=\"$TARGET_DIR/theme.txt\"|" "$GRUB_DEFAULT"
else
    echo "GRUB_THEME=\"$TARGET_DIR/theme.txt\"" >> "$GRUB_DEFAULT"
fi

# Asegurar resolución gráfica compatible (opcional pero recomendable)
if grep -q "^GRUB_GFXMODE=" "$GRUB_DEFAULT"; then
    sed -i "s|^GRUB_GFXMODE=.*|GRUB_GFXMODE=1920x1080|" "$GRUB_DEFAULT"
else
    echo "GRUB_GFXMODE=1920x1080" >> "$GRUB_DEFAULT"
fi

if grep -q "^GRUB_GFXPAYLOAD_LINUX=" "$GRUB_DEFAULT"; then
    sed -i "s|^GRUB_GFXPAYLOAD_LINUX=.*|GRUB_GFXPAYLOAD_LINUX=keep|" "$GRUB_DEFAULT"
else
    echo "GRUB_GFXPAYLOAD_LINUX=keep" >> "$GRUB_DEFAULT"
fi

echo "==> Regenerando grub.cfg (update-grub)"
update-grub

echo ""
echo "✅ Tema instalado correctamente."
echo "   Backup del grub original: $BACKUP_FILE"
echo "   Reinicia para verlo en acción."
