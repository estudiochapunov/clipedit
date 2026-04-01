# ClipEdit - Clipboard Editor for Linux

CLI tool to edit the clipboard and convert between formats.

## Features

- ✨ **Unified command**: `clipedit` replaces all previous functions
- 📋 **Auto-detection**: Detects clipboard format (HTML, RTF, text, images)
- 🔄 **Flexible conversion**: Any → Markdown, HTML, text, PDF
- 🖼️ **Image support**: Extracts images from clipboard and embeds them
- 🔗 **Source tracking**: Adds source URL when available
- ⌨️ **Dynamic editor**: Uses system default editor
- 📦 **Compatible**: MATE, GNOME, KDE, XFCE, etc.

## Installation

```bash
git clone https://github.com/estudiochapunov/clipedit.git
cd clipedit
chmod +x install.sh
./install.sh
```

## Dependencies

Install manually:
```bash
sudo apt install xclip xdg-utils pandoc wkhtmltopdf
```

| Package | Description |
|---------|-------------|
| `xclip` | Clipboard access |
| `xdg-mime` | Detect default editor (xdg-utils) |
| `pandoc` | Format conversion |
| `wkhtmltopdf` | HTML → PDF (optional) |

## Usage

### Main command

```bash
clipedit [FLAGS]
```

### Flags

| Flag | Description | Example |
|------|-------------|---------|
| `-f, --from` | Input format (auto, html, rtf, md, text, image) | `-f html` |
| `-t, --to` | Output format (markdown, html, text, pdf) | `-t markdown` |
| `-e, --editor` | Editor to use (default: system) | `-e vim` |
| `-o, --output` | Output file | `-o ~/doc.md` |
| `-s, --source` | Include source URL if exists | `-s` |
| `-h, --help` | Show help | |

### Examples

```bash
# Open clipboard in editor (auto-detect format)
clipedit

# Convert clipboard to Markdown
clipedit -t markdown

# Force conversion: HTML → Markdown
clipedit -f html -t markdown

# Convert to HTML with source URL
clipedit -t html -s

# Open with specific editor
clipedit -e nvim

# Save to specific file
clipedit -o ~/documento.md

# Convert to PDF (requires wkhtmltopdf)
clipedit -t pdf

# Combine: specific editor + file + source
clipedit -e vim -o ~/notas.txt -s
```

### Backward-compatible aliases

```bash
clip-edit-text    # clipedit -f text -e
clip-edit-html    # clipedit -f html -e  
clip2md           # clipedit -t markdown
clip-to-markdown  # clipedit -t markdown
```

## Understanding TARGETS

### What is TARGETS?

X11 clipboard doesn't just hold text - it can contain **multiple formats** at the same time. The command `xclip -t TARGETS -o` shows what formats are available.

### Common clipboard formats

| TARGET | Type | Typical origin |
|--------|------|----------------|
| `text/html` | HTML | Browsers, LibreOffice |
| `text/rtf` | RTF | LibreOffice, Word |
| `text/plain` | Text | Terminal, any app |
| `text/markdown` | Markdown | Text editors |
| `image/png` | Image | Screenshots |
| `image/jpeg` | Image | Copied photos |
| `chromium/x-source-url` | URL | Chrome/Chromium (web origin) |

### Why is it useful?

ClipEdit uses TARGETS to:
1. **Auto-detect** content format
2. **Extract images** from clipboard
3. **Include origin URL** when copying from a browser

### How to see it

```bash
# See all available formats
xclip -selection clipboard -t TARGETS -o

# See content in specific format
xclip -selection clipboard -t text/html -o
xclip -selection clipboard -t image/png -o > image.png
```

### Source URL (Chromium)

When copying from Chrome/Chromium, clipboard includes `chromium/x-source-url` with the page URL. You can include it with `-s` flag:

```
Source: https://example.com/article
---
Copied content...
```

## Keyboard shortcuts (MATE)

| Shortcut | Function |
|----------|----------|
| `Win+C` | clipedit (open in editor) |
| `Win+Shift+C` | clipedit -t markdown |
| `Win+Ctrl+C` | clipedit -t html |

Configure in MATE: System → Preferences → Hardware → Keyboard Shortcuts

## Uninstallation

```bash
./UNINSTALL.sh
```

Or manually:
```bash
rm ~/bin/clipedit ~/bin/clip-wrapper
dconf write /org/mate/marco/global-keybindings/custom-keybindings "[]"
# Remove functions from ~/.bashrc (search for "clipedit" or "ClipEdit")
```

## FAQ

**Q: Does it work in GNOME/KDE/XFCE?**  
A: Yes, uses `xdg-mime` to detect default editor.

**Q: Can I use a different editor?**  
A: Yes, with `-e EDITOR` (e.g., `-e vim`, `-e emacs30`).

**Q: What if I don't have pandoc?**  
A: Conversion won't work, but clipboard editing will.

**Q: What if I don't have wkhtmltopdf?**  
A: PDF conversion will save as HTML instead.

## License

MIT License - You can use, modify and distribute freely.

## Author

estudiochapunov - https://github.com/estudiochapunov