#!/bin/bash
# ClipEdit - Script de instalación
# https://github.com/estudiochapunov/clipedit

set -e

echo "=== ClipEdit Installation ==="

# 1. Verificar dependencias
echo "1. Verificando dependencias..."
MISSING=()
for cmd in xclip xdg-mime perl; do
    if ! command -v $cmd &>/dev/null; then
        MISSING+=("$cmd")
    fi
done

if ! command -v pandoc &>/dev/null; then
    echo "   ⚠️ pandoc no encontrado (para conversión)"
fi

if ! command -v wkhtmltopdf &>/dev/null; then
    echo "   ⚠️ wkhtmltopdf no encontrado (para PDF)"
fi

if [ ${#MISSING[@]} -gt 0 ]; then
    echo "   ❌ Faltan dependencias: ${MISSING[*]}"
    echo "   Instalalas con: sudo apt install xclip xdg-utils perl pandoc wkhtmltopdf"
    exit 1
fi
echo "   ✅ Dependencias ok"

# 2. Agregar ~/bin al PATH
echo "2. Configurando PATH..."
if ! grep -q 'export PATH="\$HOME/bin:\$PATH"' ~/.bashrc 2>/dev/null; then
    echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
fi

# Crear directorio ~/bin si no existe
mkdir -p ~/bin

# 3. Instalar clipedit como symlink al repo
echo "3. Instalando clipedit..."
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
chmod +x "$SCRIPT_DIR/clipedit"
rm -f ~/bin/clipedit
ln -s "$SCRIPT_DIR/clipedit" ~/bin/clipedit
echo "   ✅ clipedit en ~/bin/clipedit -> $SCRIPT_DIR/clipedit"

# 4. Crear wrapper para atajos (compatibilidad)
echo "4. Creando wrapper..."
cat > ~/bin/clip-wrapper << 'WRAPPER'
#!/bin/bash
shift
CMD="$1"
shift
case "$CMD" in
    text)   ~/bin/clipedit -f text "$@" ;;
    html)   ~/bin/clipedit -f html "$@" ;;
    2md)    ~/bin/clipedit -t markdown "$@" ;;
    *)      ~/bin/clipedit "$@" ;;
esac
WRAPPER
chmod +x ~/bin/clip-wrapper

# 5. Alias retrocompatibles en ~/.bashrc
echo "5. Agregando alias retrocompatibles..."
if ! grep -q "# --- ClipEdit Aliases ---" ~/.bashrc 2>/dev/null; then
    cat >> ~/.bashrc << 'ALIAS'

# --- ClipEdit Aliases (retrocompatibles) ---
clip-edit-text() { ~/bin/clipedit -f text; }
clip-edit-html() { ~/bin/clipedit -f html; }
clip2md() { ~/bin/clipedit -t markdown; }
clip-to-markdown() { ~/bin/clipedit -t markdown; }
ALIAS
fi

# 6. Configurar atajos (MATE/GTK)
echo "6. Configurando atajos de teclado..."
dconf write /org/mate/marco/global-keybindings/custom-keybindings "[
  {'name': 'clipedit-edit', 'key': '<Super>c', 'command': '~/bin/clipedit', 'binding': '<Super>c'},
  {'name': 'clipedit-md', 'key': '<Super><Shift>c', 'command': '~/bin/clipedit -t markdown', 'binding': '<Super><Shift>c'},
  {'name': 'clipedit-html', 'key': '<Super><Control>c', 'command': '~/bin/clipedit -t html', 'binding': '<Super><Control>c'}
]"

echo ""
echo "=== INSTALACIÓN COMPLETA ==="
echo ""
echo "Para usar, iniciá una nueva terminal o ejecutá:"
echo "  source ~/.bashrc"
echo ""
echo "Nuevo comando unificado:"
echo "  clipedit                        # abrir en editor"
echo "  clipedit -t markdown            # convertir a Markdown"
echo "  clipedit -t html -s             # convertir a HTML con source"
echo ""
echo "Alias retrocompatibles:"
echo "  clip-edit-text, clip-edit-html, clip2md, clip-to-markdown"
echo ""
echo "Atajos: Win+C, Win+Shift+C, Win+Ctrl+C"
