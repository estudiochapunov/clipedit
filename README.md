# ClipEdit - Clipboard Editor for Linux

CLI tool to edit the clipboard and convert between formats.

## Features

- ✨ **Unified command**: `clipedit` replaces all previous functions
- 📋 **Auto-detection**: Detects clipboard format (HTML, RTF, text, images)
- 🔎 **Clipboard inspection**: `--targets` and `--peek` for quick diagnostics
- 🔄 **Flexible conversion**: Any → Markdown, HTML, text, PDF
- 🖼️ **Image support**: Extracts images from clipboard and embeds them
- 🔗 **Source tracking**: Adds source URL when available
- 🧹 **Cleanup filters**: Fixes copied AI code, terminal prompts, Markdown fences and WhatsApp message headers
- ⌨️ **Dynamic editor**: Uses system default editor
- 📦 **Compatible**: MATE, GNOME, KDE, XFCE, etc.

## Installation

```bash
git clone https://github.com/estudiochapunov/clipedit.git
cd clipedit
chmod +x install.sh
./install.sh
```

The installer creates a symlink instead of copying the script:

```bash
~/bin/clipedit -> /path/to/your/clipedit/clipedit
```

This keeps a single versioned source of truth. Edits committed in the Git repo
are immediately available through the global `clipedit` command.

## Dependencies

Install manually:
```bash
sudo apt install xclip xdg-utils perl pandoc wkhtmltopdf
```

| Package | Description |
|---------|-------------|
| `xclip` | Clipboard access |
| `xdg-mime` | Detect default editor (xdg-utils) |
| `perl` | WhatsApp header parser for `--strip-wa-msgs` |
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
| `--targets` | List available clipboard formats | |
| `--peek` | Show clipboard diagnostics and a short preview | |
| `--target TARGET` | Extract a raw X11 clipboard target | `--target text/html` |
| `--plain` | Convert to plain text and copy without opening an editor | |
| `--copy-only` | Convert and copy without opening an editor | |
| `--no-edit` | Alias for `--copy-only` | |
| `--save-temp` | Keep temporary files for inspection | |
| `--no-emoji` | Use sober ClipEdit messages without emojis; clipboard content is not changed | |
| `--strip-line-numbers` | Remove line numbers copied from AI chats, diffs or code viewers | |
| `--join-lines SPEC` | Join line ranges into one line (`all`, `u3,7;9,14`, `3,7;9,14`) | |
| `--stdout` | Print final output without touching the editor or clipboard | |
| `--trim` | Remove leading/trailing blank lines and trailing spaces | |
| `--dedent` | Remove common indentation | |
| `--strip-code-fence` | Remove Markdown code fences | |
| `--strip-prompts` | Remove copied shell prompts | |
| `--strip-wa-msgs` | Remove WhatsApp sender/date/time headers from copied or exported messages | |
| `--wa-keep FIELDS` | Preserve WhatsApp metadata fields (`name`, `date`, `time`, `datetime`, `all`) | `--wa-keep name,date` |
| `--wa-place PLACE` | Place preserved WhatsApp metadata at `prefix` or `suffix` | `--wa-place suffix` |
| `--squeeze-blank-lines` | Collapse repeated blank lines | |
| `--slug` | Convert text to a lowercase URL/file slug | |
| `--filename-safe` | Convert text to a filesystem-safe name | |
| `--wrap-code-fence LANG` | Wrap content in a Markdown code fence | |
| `--dry-run` | Show effective plan and final output without writing to clipboard or opening editor | |
| `--grep PATTERN` | Keep only lines matching an extended regex | |
| `--grep-v PATTERN` | Drop lines matching an extended regex | |
| `--version` | Show ClipEdit version | |
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

# Inspect clipboard formats without changing anything
clipedit --targets

# Show detected type, source URL, size and a short preview
clipedit --peek

# Show version and repository
clipedit --version

# Copy plain text directly
clipedit --plain

# Convert to Markdown and copy directly, without opening the editor
clipedit -t markdown --copy-only

# Same behavior, alternate spelling
clipedit -t markdown --no-edit

# Keep the generated temporary file
clipedit -t markdown --save-temp

# Sober output, without emojis
clipedit --peek --no-emoji

# Remove copied line numbers and copy plain text
clipedit --strip-line-numbers --plain

# Join every line into one line
clipedit --join-lines all --plain

# Join only selected ranges, preserving the other lines
clipedit --join-lines 'u3,7;9,14' --plain

# Fix copied AI code: strip line numbers, then join lines 2 through 4
clipedit --strip-line-numbers --join-lines u2,4 --plain

# Print final output to terminal without changing clipboard
clipedit --strip-code-fence --dedent --stdout

# Remove shell prompts from copied terminal snippets
clipedit --strip-prompts --plain

# Remove WhatsApp sender/date/time headers from copied messages
clipedit --strip-wa-msgs --plain

# Trim, dedent, and collapse repeated blank lines
clipedit --trim --dedent --squeeze-blank-lines --plain

# Convert clipboard text to slug
clipedit --slug

# Convert clipboard text to a filename-safe string
clipedit --filename-safe

# Wrap clipboard content as fenced bash code
clipedit --wrap-code-fence bash --plain

# Preview the exact transformation without touching clipboard
clipedit --strip-prompts --grep '^git ' --dry-run

# Keep only matching lines
clipedit --grep 'ERROR|WARN' --plain

# Drop matching lines
clipedit --grep-v 'DEBUG|TRACE' --plain

# Extract one raw clipboard target to stdout
clipedit --target text/html

# Save one raw clipboard target to a file
clipedit --target text/html -o ~/clip.html
```

### Editor workflow

When ClipEdit opens an editor, it works on a temporary file. To send edits back
to the clipboard:

1. Edit the content.
2. Save the same temporary file in the editor.
3. Close the editor.
4. Confirm the ClipEdit prompt to copy the saved temporary file to the clipboard.

Using "Save as" in another path does not change the temporary file that ClipEdit
will copy. ClipEdit reports whether it detected saved changes before asking:

```text
Cambios guardados detectados.
¿Copiar al clipboard el contenido guardado del archivo temporal? (s/n)
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
clipedit --targets

# See content in specific format
xclip -selection clipboard -t text/html -o
xclip -selection clipboard -t image/png -o > image.png
```

For a more readable diagnostic, use:

```bash
clipedit --peek
```

To extract a specific target without conversion:

```bash
clipedit --target text/html
clipedit --target chromium/x-source-url
clipedit --target image/png -o ~/clip.png
```

## Cleanup filters for AI chat output

AI chat apps sometimes copy code with line numbers, or wrap shell one-liners
across several visual lines. ClipEdit includes two explicit filters for that:

```bash
# Remove leading line numbers such as "12 |", "12:", "12 +", or "12 "
clipedit --strip-line-numbers --plain

# Join all lines into a single line
clipedit --join-lines all --plain

# Join selected ranges only. The leading "u" is optional.
clipedit --join-lines 'u3,7;9,14' --plain
clipedit --join-lines '3,7;9,14' --plain
```

For selected ranges, lines outside the ranges are preserved. Joined lines are
separated with one space.

Additional cleanup filters:

```bash
# Print cleaned result without changing clipboard
clipedit --strip-code-fence --dedent --stdout

# Turn copied shell sessions into reusable commands
clipedit --strip-prompts --plain

# Remove WhatsApp multi-message headers
clipedit --strip-wa-msgs --plain
clipedit --strip-wa-msgs --wa-keep name,date --stdout
clipedit --strip-wa-msgs --wa-keep datetime --wa-place suffix --stdout

# Normalize whitespace
clipedit --trim --squeeze-blank-lines --plain

# Convert title text to reusable names
clipedit --slug
clipedit --filename-safe

# Add or remove Markdown code fences
clipedit --strip-code-fence --plain
clipedit --wrap-code-fence bash --plain

# Keep or remove lines with extended regex patterns
clipedit --grep 'ERROR|WARN' --stdout
clipedit --grep-v 'DEBUG|TRACE' --stdout

# Inspect the effective plan plus final output
clipedit --strip-line-numbers --join-lines u1,3 --dry-run
```

## WhatsApp cleanup

When copying multiple WhatsApp messages or working with exported chats, WhatsApp
may prepend each message with sender and timestamp metadata. The exact format
depends on app, platform, and locale. ClipEdit handles common variants:

```text
[Gabriel 12/04/2026 17:03:23]: Mi mensaje
[15.11.16, 16:13:29] Person A: Hello
1/15/25, 10:35 AM - John: Great
```

To remove those headers:

```bash
clipedit --strip-wa-msgs --plain
clipedit --strip-wa-msgs --stdout
clipedit --strip-wa-msgs --dry-run
```

By default, `--strip-wa-msgs` removes all WhatsApp metadata and keeps only the
message body. If metadata is useful, preserve selected fields:

```bash
# Keep sender only
clipedit --strip-wa-msgs --wa-keep name --plain

# Keep sender and date before each message
clipedit --strip-wa-msgs --wa-keep name,date --plain

# Keep date/time after each message
clipedit --strip-wa-msgs --wa-keep datetime --wa-place suffix --stdout

# Keep sender, date and time
clipedit --strip-wa-msgs --wa-keep all --stdout
```

Preserved metadata is normalized into a compact tag:

```text
[Gabriel 12/04/2026 17:03:23] Mi mensaje
Mi mensaje [12/04/2026 17:03:23]
```

The filter is conservative: it only removes line-start headers that contain a
date and time pattern.

### Implementation notes

The WhatsApp parser is intentionally conservative and line-oriented. It handles
three common header families:

```text
[Name DD/MM/YYYY HH:MM:SS]: Message
[DD.MM.YY, HH:MM:SS] Name: Message
MM/DD/YY, HH:MM AM - Name: Message
```

It requires both date and time before stripping anything. Lines that do not
look like WhatsApp metadata are preserved unchanged, which makes the filter
safe to combine with `--dry-run`, `--stdout`, `--plain`, `--grep`,
`--strip-prompts`, `--trim` and the other text filters.

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

## Development Checks

Run syntax checks and the filter regression suite before refactoring or adding
flags:

```bash
bash -n clipedit
bash -n install.sh
./tests/run_filters.sh
```

`tests/run_filters.sh` loads ClipEdit functions without running `main`, so it
does not require clipboard access. It freezes the current text-filter contract
for cleanup, WhatsApp headers, grep filters, slugs, filename-safe output and
Markdown fences.

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
