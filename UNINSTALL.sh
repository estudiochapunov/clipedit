#!/bin/bash
# ClipEdit - Script de desinstalación
# https://github.com/estudiochapunov/clipedit

echo "=== ClipEdit Uninstall ==="

# 1. Eliminar wrapper
echo "1. Eliminando wrapper..."
rm -f ~/bin/clip-wrapper
echo "   ✅ ~/bin/clip-wrapper eliminado"

# 2. Eliminar atajos
echo "2. Eliminando atajos de teclado..."
dconf write /org/mate/marco/global-keybindings/custom-keybindings "[]"
echo "   ✅ Atajos eliminados"

# 3. Advertencia sobre ~/.bashrc
echo "3. Funciones en ~/.bashrc"
echo "   ⚠️ Las funciones siguen en ~/.bashrc"
echo "   Para eliminarlas manualmente, editá ~/.bashrc y borrá desde:"
echo "   '# --- Clipboard Editor (ClipEdit) ---'"
echo "   hasta 'export PATH=\"\$HOME/bin:\$PATH\"'"
echo ""
echo "=== DESINSTALACIÓN COMPLETA ==="
echo "Para reinstall, ejecutá ./install.sh de nuevo"