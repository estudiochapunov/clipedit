#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Load function definitions without running main "$@".
# This keeps filter tests independent from X11 clipboard state.
source <(sed '$d' "$ROOT_DIR/clipedit")

tests_run=0

fail() {
    local name="$1"
    local expected="$2"
    local actual="$3"

    printf 'not ok - %s\n' "$name" >&2
    printf 'expected:\n%s\n' "$expected" >&2
    printf 'actual:\n%s\n' "$actual" >&2
    exit 1
}

assert_eq() {
    local name="$1"
    local expected="$2"
    local actual="$3"

    tests_run=$((tests_run + 1))
    if [[ "$actual" != "$expected" ]]; then
        fail "$name" "$expected" "$actual"
    fi
    printf 'ok - %s\n' "$name"
}

run_filter() {
    local input="$1"
    shift

    printf '%s\n' "$input" | "$@"
}

assert_eq \
    "strip-line-numbers removes chat/code line prefixes" \
    $'echo uno\n&& echo dos\nlinea normal' \
    "$(run_filter $'1 | echo uno\n2 + && echo dos\n3: linea normal' strip_line_numbers_filter)"

assert_eq \
    "join-lines all joins nonblank lines with spaces" \
    "uno dos tres" \
    "$(run_filter $'uno\n\n dos \ntres' join_lines_filter all)"

assert_eq \
    "join-lines selected ranges preserves outside lines" \
    $'uno dos tres\ncuatro\ncinco seis' \
    "$(run_filter $'uno\ndos\ntres\ncuatro\ncinco\nseis' join_lines_filter 'u1,3;5,6')"

assert_eq \
    "trim removes blank edges and trailing spaces" \
    $'uno\ndos' \
    "$(run_filter $'\n\nuno  \ndos\t\n\n' trim_filter)"

assert_eq \
    "dedent removes common indentation" \
    $'uno\n  dos' \
    "$(run_filter $'    uno\n      dos' dedent_filter)"

assert_eq \
    "strip-code-fence removes markdown fences" \
    $'echo hola\necho chau' \
    "$(run_filter $'```bash\necho hola\necho chau\n```' strip_code_fence_filter)"

assert_eq \
    "strip-prompts removes copied shell prompts" \
    $'echo uno\necho dos\necho tres' \
    "$(run_filter $'user@host:~/work$ echo uno\n$ echo dos\n> echo tres' strip_prompts_filter)"

assert_eq \
    "strip-wa-msgs removes WhatsApp headers by default" \
    $'Mensaje de prueba\nHello\nGreat\n[nota sin fecha]: no tocar' \
    "$(run_filter $'[Sample User 12/04/2026 17:03:23]: Mensaje de prueba\n[15.11.16, 16:13:29] Person A: Hello\n1/15/25, 10:35 AM - Person B: Great\n[nota sin fecha]: no tocar' strip_wa_msgs_filter)"

assert_eq \
    "strip-wa-msgs can preserve all metadata as prefix" \
    $'[Sample User 12/04/2026 17:03:23] Mensaje de prueba\n[Person A 15.11.16 16:13:29] Hello\n[Person B 1/15/25 10:35 AM] Great' \
    "$(run_filter $'[Sample User 12/04/2026 17:03:23]: Mensaje de prueba\n[15.11.16, 16:13:29] Person A: Hello\n1/15/25, 10:35 AM - Person B: Great' strip_wa_msgs_filter all prefix)"

assert_eq \
    "strip-wa-msgs can preserve datetime as suffix" \
    $'Mensaje de prueba [12/04/2026 17:03:23]\nHello [15.11.16 16:13:29]\nGreat [1/15/25 10:35 AM]' \
    "$(run_filter $'[Sample User 12/04/2026 17:03:23]: Mensaje de prueba\n[15.11.16, 16:13:29] Person A: Hello\n1/15/25, 10:35 AM - Person B: Great' strip_wa_msgs_filter datetime suffix)"

assert_eq \
    "squeeze-blank-lines collapses repeated blank lines" \
    $'uno\n\ndos\n\ntres' \
    "$(run_filter $'uno\n\n\ndos\n\n\n\ntres' squeeze_blank_lines_filter)"

assert_eq \
    "grep keeps matching lines" \
    $'ERROR uno\nWARN dos' \
    "$(run_filter $'INFO cero\nERROR uno\nWARN dos\nDEBUG tres' grep_filter 'ERROR|WARN')"

assert_eq \
    "grep-v drops matching lines" \
    $'INFO cero\nERROR uno' \
    "$(run_filter $'INFO cero\nDEBUG ruido\nERROR uno\nTRACE ruido' grep_v_filter 'DEBUG|TRACE')"

assert_eq \
    "slug normalizes title text" \
    "clipedit-limpieza-ia-2026" \
    "$(run_filter "ClipEdit limpieza IA 2026" slug_filter)"

assert_eq \
    "filename-safe normalizes unsafe file names" \
    "TP_2-Celula_Pro_Animalia.pdf" \
    "$(run_filter "TP 2/Celula: Pro Animalia?.pdf" filename_safe_filter)"

assert_eq \
    "wrap-code-fence wraps content with requested language" \
    $'```bash\necho hola\n\n```' \
    "$(run_filter "echo hola" wrap_code_fence_filter bash)"

assert_eq \
    "selection-label names clipboard" \
    "CLIPBOARD" \
    "$(selection_label clipboard)"

assert_eq \
    "selection-label names primary" \
    "PRIMARY" \
    "$(selection_label primary)"

assert_eq \
    "selection-label names both" \
    "CLIPBOARD y PRIMARY" \
    "$(selection_label both)"

reset_filter_options
filter_strip_line_numbers=true
filter_join_lines_spec="all"
filter_trim=true
filter_dedent=true
filter_strip_code_fence=true

assert_eq \
    "apply_text_filters composes filters in current order" \
    "echo uno && echo dos" \
    "$(apply_text_filters $'1 | ```bash\n2 | echo uno\n3 | && echo dos\n4 | ```')"

assert_eq \
    "build_filter_plan exposes same pipeline used by apply_text_filters" \
    $'  - strip-line-numbers\n  - strip-code-fence\n  - dedent\n  - join-lines:all\n  - trim' \
    "$(build_filter_plan; print_filter_plan)"

printf 'All %d filter tests passed.\n' "$tests_run"
