# shellcheck shell=bash

readonly KITTY_THEME_FILE="${CONFIG_HOME}/kitty/theme.conf"

write_kitty_theme() {
    cat >"${KITTY_THEME_FILE}" <<EOF
font_family      family="${FONTS[mono]}"
background_opacity $(terminal_opacity)
background ${COLOURS[bg]}
foreground ${COLOURS[fg]}
selection_background ${COLOURS[accent]}
selection_foreground ${COLOURS[onAccent]}
cursor ${COLOURS[accent]}
cursor_text_color background
url_color ${COLOURS[accentSoft]}
EOF
    terminal_palette | while IFS=$'\t' read -r index colour; do
        printf 'color%s %s\n' "${index}" "${colour}"
    done >>"${KITTY_THEME_FILE}"
}

apply_kitty() {
    mkdir -p "$(dirname "${KITTY_THEME_FILE}")"
    write_kitty_theme
    pkill -USR1 -x kitty >/dev/null 2>&1 || true
}
