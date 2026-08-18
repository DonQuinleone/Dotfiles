# shellcheck shell=bash

readonly GHOSTTY_THEME_FILE="${CONFIG_HOME}/ghostty/theme.conf"

write_ghostty_theme() {
    cat >"${GHOSTTY_THEME_FILE}" <<EOF
font-family = "${FONTS[mono]}"
background-opacity = $(terminal_opacity)
background = $(bare_hex "${COLOURS[bg]}")
foreground = $(bare_hex "${COLOURS[fg]}")
selection-background = $(bare_hex "${COLOURS[accent]}")
selection-foreground = $(bare_hex "${COLOURS[onAccent]}")
cursor-color = $(bare_hex "${COLOURS[accent]}")
EOF
}

apply_ghostty() {
    mkdir -p "$(dirname "${GHOSTTY_THEME_FILE}")"
    write_ghostty_theme
    pkill -USR2 -x ghostty >/dev/null 2>&1 || true
}
