# ClipEdit - Clipboard Editor para Linux

Herramienta CLI para editar el portapapeles con el editor predeterminado del sistema y convertir HTML/RTF a Markdown automáticamente.

## Features

- ✨ **Editor dinámico**: Usa el editor de texto predeterminado del sistema
- 📋 **Soporte múltiplo**: Texto plano, HTML, RTF
- 🔄 **Detección automática**: Detecta el formato del portapapeles y convierte a Markdown
- ⌨️ **Atajos configurables**: Win+C, Win+Shift+C, Win+Ctrl+C (en MATE)
- 🖥️ **Compatible**: MATE, GNOME, KDE, XFCE, etc.

## Instalación

```bash
git clone https://github.com/estudiochapunov/clipedit.git
cd clipedit
chmod +x install.sh
./install.sh
```

## Dependencias

El script de instalación verifica automáticamente. Para instalar manualmente:

```bash
sudo apt install xclip xdg-utils pandoc
```

| Paquete | Descripción |
|---------|-------------|
| `xclip` | Acceso al portapapeles |
| `xdg-mime` | Detectar editor default (parte de xdg-utils) |
| `pandoc` | Conversión HTML/RTF→Markdown |

## Uso

### Funciones disponibles

```bash
# Abrir portapapeles (texto plano) en el editor del sistema
clip-edit-text

# Con editor específico
clip-edit-text -e vim
clip-edit-text -e nvim
clip-edit-text -e emacs30

# Con archivo específico
clip-edit-text -o ~/documento.txt

# Combinado
clip-edit-text -e vim -o ~/notas.txt
```

```bash
# Abrir portapapeles (HTML) en el editor
clip-edit-html

# Con editor específico
clip-edit-html -e code

# Con archivo específico
clip-edit-html -o ~/pagina.html
```

```bash
# Convertir portapapeles (HTML/RTF) a Markdown y copiar al portapapeles
clip2md

# Guardar en archivo en lugar de portapapeles
clip2md -o ~/documento.md
```

### Atajos de teclado (MATE)

| Atajo | Función |
|-------|---------|
| `Win+C` | clip-edit-text |
| `Win+Shift+C` | clip-edit-html |
| `Win+Ctrl+C` | clip2md |

Para configurar en MATE: System → Preferences → Hardware → Keyboard Shortcuts

## Desinstalación

```bash
./UNINSTALL.sh
```

O manualmente:
```bash
rm ~/bin/clip-wrapper
dconf write /org/mate/marco/global-keybindings/custom-keybindings "[]"
# Eliminar las funciones de ~/.bashrc (buscar "# --- Clipboard Editor")
```

## FAQ

**P: ¿Funciona en GNOME?**  
R: Sí, usa `xdg-mime` para detectar el editor default.

**P: ¿Puedo usar otro editor?**  
R: Sí, con la bandera `-e` o `-e EDITOR`.

**P: ¿Qué pasa si no tengo pandoc?**  
R: `clip2md` no funcionará, pero `clip-edit-text` y `clip-edit-html` sí.

## Licencia

MIT License - Puedes usar, modificar y distribuir libremente.

## Autor

estudiochapunov - https://github.com/estudiochapunov