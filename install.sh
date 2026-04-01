#!/bin/bash
# ClipEdit - Script de instalación
# https://github.com/estudiochapunov/clipedit

set -e

echo "=== ClipEdit Installation ==="

# 1. Verificar dependencias
echo "1. Verificando dependencias..."
MISSING=()
for cmd in xclip pandoc xdg-mime; do
    if ! command -v $cmd &>/dev/null; then
        MISSING+=("$cmd")
    fi
done

if [ ${#MISSING[@]} -gt 0 ]; then
    echo "   ❌ Faltan dependencias: ${MISSING[*]}"
    echo "   Instalalas con: sudo apt install xclip pandoc xdg-utils"
    exit 1
fi
echo "   ✅ Dependencias ok"

# 2. Agregar funciones al ~/.bashrc
echo "2. Agregando funciones a ~/.bashrc..."

# Verificar si ya están agregadas
if grep -q "clip-edit-text()" ~/.bashrc 2>/dev/null; then
    echo "   ⚠️ Funciones ya existen en ~/.bashrc"
else
    cat >> ~/.bashrc << 'FUNCS'

# --- Clipboard Editor (ClipEdit) ---
# Editor dinámico basado en el editor del sistema
get_default_editor() {
    if [[ -n "$EDITOR" ]]; then
        echo "$EDITOR"
        return 0
    fi
    local xed_default
    xed_default=$(xdg-mime query default text/plain 2>/dev/null)
    if [[ -n "$xed_default" ]]; then
        echo "${xed_default%.desktop}"
        return 0
    fi
    echo "xdg-open"
    return 0
}

clip-edit-text() {
    local editor output_file temp_file
    editor=""
    output_file=""
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -e|--editor) editor="$2"; shift 2 ;;
            -o|--output) output_file="$2"; shift 2 ;;
            -h|--help)
                echo "Uso: clip-edit-text [-e EDITOR] [-o ARCHIVO]"
                return 0
                ;;
            *) shift ;;
        esac
    done
    
    temp_file=$(mktemp /tmp/clip-XXXXXX.txt)
    xclip -selection clipboard -o > "$temp_file"
    
    if [[ -z "$editor" ]]; then
        editor=$(get_default_editor)
    fi
    
    "$editor" "$temp_file"
    
    if [[ -z "$output_file" ]]; then
        echo "📋 Archivo: $temp_file"
        echo "¿Copiar al clipboard? (s/n)"
        read -r resp
        if [[ "$resp" == "s" || "$resp" == "S" ]]; then
            xclip -selection clipboard -i < "$temp_file"
            echo "✅ Copiado"
        fi
        rm -f "$temp_file"
    else
        echo "📄 Guardado: $temp_file"
    fi
}

clip-edit-html() {
    local editor output_file temp_file
    editor=""
    output_file=""
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -e|--editor) editor="$2"; shift 2 ;;
            -o|--output) output_file="$2"; shift 2 ;;
            *) shift ;;
        esac
    done
    
    temp_file=$(mktemp /tmp/clip-XXXXXX.html)
    xclip -selection clipboard -t text/html -o > "$temp_file" 2>/dev/null || \
    xclip -selection clipboard -o > "$temp_file"
    
    if [[ -z "$editor" ]]; then
        editor=$(get_default_editor)
    fi
    
    "$editor" "$temp_file"
    
    if [[ -z "$output_file" ]]; then
        echo "📋 Archivo: $temp_file"
        echo "¿Copiar al clipboard? (s/n)"
        read -r resp
        if [[ "$resp" == "s" || "$resp" == "S" ]]; then
            xclip -selection clipboard -i < "$temp_file"
            echo "✅ Copiado"
        fi
        rm -f "$temp_file"
    else
        echo "📄 Guardado: $temp_file"
    fi
}

clip-to-markdown() { clip2md "$@"; }

clip2md() {
    local output_file temp_file targets
    
    output_file=""
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -o|--output) output_file="$2"; shift 2 ;;
            -h|--help)
                echo "Uso: clip2md [-o ARCHIVO]"; return 0 ;;
            *) shift ;;
        esac
    done
    
    temp_file=$(mktemp /tmp/clip-XXXXXX.md)
    targets=$(xclip -selection clipboard -t TARGETS -o 2>/dev/null)
    
    if echo "$targets" | grep -qw "text/html"; then
        echo "→ HTML detectado"
        xclip -selection clipboard -t text/html -o | pandoc -f html -t markdown > "$temp_file"
    elif echo "$targets" | grep -qw "text/rtf"; then
        echo "→ RTF detectado"
        xclip -selection clipboard -t text/rtf -o | pandoc -f rtf -t markdown > "$temp_file"
    else
        echo "→ Texto plano"
        xclip -selection clipboard -o > "$temp_file"
    fi
    
    xclip -selection clipboard -i < "$temp_file"
    [[ -z "$output_file" ]] && rm -f "$temp_file" || echo "📄 $temp_file"
    echo "✅ Convertido a Markdown"
}

export PATH="$HOME/bin:$PATH"
FUNCS
    echo "   ✅ Funciones agregadas a ~/.bashrc"
fi

# 3. Agregar ~/bin al PATH
echo "3. Configurando PATH..."
if ! grep -q 'export PATH="\$HOME/bin:\$PATH"' ~/.bashrc 2>/dev/null; then
    echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
fi
echo "   ✅ PATH configurado"

# 4. Crear wrapper script
echo "4. Creando wrapper..."
mkdir -p ~/bin
cat > ~/bin/clip-wrapper << 'WRAPPER'
#!/bin/bash
shift
CMD="$1"
shift
case "$CMD" in
    text) bash -ic "source ~/.bashrc 2>/dev/null; clip-edit-text $*" ;;
    html) bash -ic "source ~/.bashrc 2>/dev/null; clip-edit-html $*" ;;
    2md|markdown) bash -ic "source ~/.bashrc 2>/dev/null; clip2md $*" ;;
    *) echo "Uso: clip-wrapper text|html|2md [-e EDITOR] [-o FILE]" ;;
esac
WRAPPER
chmod +x ~/bin/clip-wrapper
echo "   ✅ Wrapper en ~/bin/clip-wrapper"

# 5. Configurar atajos (MATE/GTK)
echo "5. Configurando atajos de teclado..."
dconf write /org/mate/marco/global-keybindings/custom-keybindings "[
  {'name': 'clip-text', 'key': '<Super>c', 'command': '$HOME/bin/clip-wrapper text', 'binding': '<Super>c'},
  {'name': 'clip-html', 'key': '<Super><Shift>c', 'command': '$HOME/bin/clip-wrapper html', 'binding': '<Super><Shift>c'},
  {'name': 'clip-2md', 'key': '<Super><Control>c', 'command': '$HOME/bin/clip-wrapper 2md', 'binding': '<Super><Control>c'}
]"
echo "   ✅ Atajos configurados"

echo ""
echo "=== INSTALACIÓN COMPLETA ==="
echo ""
echo "Para usar, iniciá una nueva terminal o ejecutá:"
echo "  source ~/.bashrc"
echo ""
echo "Funciones disponibles:"
echo "  clip-edit-text [-e EDITOR] [-o ARCHIVO]"
echo "  clip-edit-html  [-e EDITOR] [-o ARCHIVO]"
echo "  clip2md         [-o ARCHIVO]"
echo ""
echo "Atajos (Win+C, Win+Shift+C, Win+Ctrl+C)"