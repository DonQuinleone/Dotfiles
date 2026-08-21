# shellcheck shell=bash

apply_quickshell() {
    mkdir -p "${STATE_DIR}"
    local staged="${ACTIVE_JSON}.new"
    jq --arg wallpaper "${THEME_WALLPAPER}" \
        --argjson palette "$(palette_json)" \
        '.wallpaper = $wallpaper | .palette = $palette' \
        "${THEME_SOURCE}" >"${staged}"
    mv "${staged}" "${ACTIVE_JSON}"
}
