# shellcheck shell=bash

apply_quickshell() {
    mkdir -p "${THEME_JSON_DIR}"
    jq --arg wallpaper "${THEME_WALLPAPER}" \
        '.wallpaper = $wallpaper' \
        "${THEME_SOURCE}" >"${ACTIVE_JSON}"
}
