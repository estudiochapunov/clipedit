# ClipEdit - Clipboard Editor para Linux

Herramienta CLI unificada para editar el portapapeles y convertir entre formatos.

## Features

- ✨ **Comando unificado**: `clipedit` reemplaza todas las funciones anteriores
- 📋 **Detección automática**: Detecta formato del portapapeles (HTML, RTF, texto, imágenes)
- 🔄 **Conversión flexible**: Cualquiera → Markdown, HTML, texto, PDF
- 🖼️ **Soporte de imágenes**: Extrae imágenes del portapapeles y las incrusta
- 🔗 **Source tracking**: Agrega URL de origen cuando está disponible
- ⌨️ **Editor dinámico**: Usa el editor del sistema por defecto
- 📦 **Compatible**: MATE, GNOME, KDE, XFCE, etc.

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
sudo apt install xclip xdg-utils pandoc wkhtmltopdf
```

| Paquete | Descripción |
|---------|-------------|
| `xclip` | Acceso al portapapeles |
| `xdg-mime` | Detectar editor default (parte de xdg-utils) |
| `pandoc` | Conversión entre formatos |
| `wkhtmltopdf` | Conversión HTML → PDF (opcional) |

## Uso

### Comando principal

```bash
clipedit [BANDERAS]
```

### Banderas

| Bandera | Descripción | Ejemplo |
|---------|-------------|---------|
| `-f, --from` | Formato de entrada (auto, html, rtf, md, text, image) | `-f html` |
| `-t, --to` | Formato de salida (markdown, html, text, pdf) | `-t markdown` |
| `-e, --editor` | Editor a usar (default: sistema) | `-e vim` |
| `-o, --output` | Archivo de salida | `-o ~/doc.md` |
| `-s, --source` | Incluir URL de origen si existe | `-s` |
| `-h, --help` | Mostrar ayuda | |

### Ejemplos de uso

```bash
# Abrir portapapeles en editor (detectar formato)
clipedit

# Convertir portapapeles a Markdown
clipedit -t markdown

# Forzar conversión: HTML → Markdown
clipedit -f html -t markdown

# Convertir a HTML con source URL
clipedit -t html -s

# Abrir con editor específico
clipedit -e nvim

# Guardar en archivo específico
clipedit -o ~/documento.md

# Convertir a PDF (requiere wkhtmltopdf)
clipedit -t pdf

# Combinar: editor específico + archivo + source
clipedit -e vim -o ~/notas.txt -s
```

### Alias retrocompatibles

```bash
# Funciones anteriores (todavía funcionan)
clip-edit-text          # clipedit -t text -e
clip-edit-html          # clipedit -t html -e  
clip2md                 # clipedit -t markdown
clip-to-markdown        # clipedit -t markdown
```

## Entendiendo TARGETS

### ¿Qué es TARGETS?

El portapapeles de X11 no solo contiene texto - puede contener **múltiples formatos** al mismo tiempo. El comando `xclip -t TARGETS -o` muestra qué formatos están disponibles.

### Formatos comunes del portapapeles

| TARGET | Tipo | Origen típico |
|--------|------|----------------|
| `text/html` | HTML | Navegadores, LibreOffice |
| `text/rtf` | RTF | LibreOffice, Word |
| `text/plain` | Texto | Terminal, cualquier app |
| `text/markdown` | Markdown | Editores de texto |
| `image/png` | Imagen | Capturas de pantalla |
| `image/jpeg` | Imagen | Fotos copiadas |
| `chromium/x-source-url` | URL | Chrome/Chromium (origen web) |

### Por qué es útil

ClipEdit usa TARGETS para:
1. **Detectar automáticamente** el formato del contenido
2. **Extraer imágenes** del portapapeles
3. **Incluir la URL de origen** cuando copiás de un navegador

### Cómo verlo

```bash
# Ver todos los formatos disponibles
xclip -selection clipboard -t TARGETS -o

# Ver contenido en formato específico
xclip -selection clipboard -t text/html -o
xclip -selection clipboard -t image/png -o > imagen.png
```

### Source URL (Chromium)

Cuando copiás desde Chrome/Chromium, el portapapeles incluye `chromium/x-source-url` con la URL de la página. Podés incluirla con la bandera `-s`:

```
Source: https://example.com/article
---
Contenido copiado...
```

## Atajos de teclado (MATE)

| Atajo | Función |
|-------|---------|
| `Win+C` | clipedit (abrir en editor) |
| `Win+Shift+C` | clipedit -t markdown |
| `Win+Ctrl+C` | clipedit -t html |

Para configurar en MATE: System → Preferences → Hardware → Keyboard Shortcuts

## Desinstalación

```bash
./UNINSTALL.sh
```

O manualmente:
```bash
rm ~/bin/clipedit ~/bin/clip-wrapper
dconf write /org/mate/marco/global-keybindings/custom-keybindings "[]"
# Eliminar funciones de ~/.bashrc (buscar "clipedit" o "ClipEdit")
```

## FAQ

**P: ¿Funciona en GNOME/KDE/XFCE?**  
R: Sí, usa `xdg-mime` para detectar el editor default.

**P: ¿Puedo usar otro editor?**  
R: Sí, con `-e EDITOR` (ej: `-e vim`, `-e emacs30`).

**P: ¿Qué pasa si no tengo pandoc?**  
R: La conversión no funcionará, pero editar portapapeles sí.

**P: ¿Y si no tengo wkhtmltopdf?**  
R: La conversión a PDF guardará HTML en su lugar.

## Licencia

MIT License - Puedes usar, modificar y distribuir libremente.

## Autor

estudiochapunov - https://github.com/estudiochapunov