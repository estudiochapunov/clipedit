#!/bin/bash
# ClipEdit - Script de desinstalación
# https://github.com/estudiochapunov/clipedit

echo "=== ClipEdit Uninstall ==="

# 1. Eliminar scripts
echo "1. Eliminando scripts..."
rm -f ~/bin/clipedit ~/bin/clip-wrapper
echo "   ✅ ~/bin/clipedit eliminado"
echo "   ✅ ~/bin/clip-wrapper eliminado"

# 2. Eliminar atajos
echo "2. Eliminando atajos de teclado..."
dconf write /org/mate/marco/global-keybindings/custom-keybindings "[]"
echo "   ✅ Atajos eliminados"

# 3. Alias en ~/.bashrc
echo "3. Alias en ~/.bashrc"
echo "   ⚠️ Los alias y funciones siguen en ~/.bashrc"
echo "   Para eliminarlos manualmente, buscá:"
echo "   - '# --- ClipEdit Aliases ---'"
echo "   - 'clip-edit-text()', 'clip-edit-html()', 'clip2md()'"
echo ""
echo "=== DESINSTALACIÓN COMPLETA ==="
echo "Para reinstall, ejecutá ./install.sh de nuevo"