# shellcheck shell=bash

readonly GHOSTTY_THEME_FILE="${CONFIG_HOME}/ghostty/theme.conf"

# A pale background has no headroom. At the translucency a dark
# theme wears comfortably the wallpaper bleeds through it, and
# the terminal washes out to near white with the picture still
# legible behind the text.
readonly GHOSTTY_DARK_OPACITY=0.8
readonly GHOSTTY_LIGHT_OPACITY=0.97

ghostty_opacity() {
    if theme_is_dark; then
        printf '%s\n' "${GHOSTTY_DARK_OPACITY}"
        return
    fi
    printf '%s\n' "${GHOSTTY_LIGHT_OPACITY}"
}

write_ghostty_theme() {
    cat >"${GHOSTTY_THEME_FILE}" <<EOF
font-family = "${FONTS[mono]}"
background-opacity = $(ghostty_opacity)
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
