# shellcheck shell=bash

readonly IMV_CONFIG_DIR="${CONFIG_HOME}/imv"
readonly IMV_CONFIG="${IMV_CONFIG_DIR}/config"
readonly IMV_TEMPLATE="${TEMPLATE_DIR}/imv.conf.in"
readonly IMV_FONT_POINTS=12

apply_imv() {
    mkdir -p "${IMV_CONFIG_DIR}"
    render_template "${IMV_TEMPLATE}" "${IMV_CONFIG}" \
        "imvBackground=$(bare_hex "${COLOURS[bg]}")" \
        "imvText=$(bare_hex "${COLOURS[fg]}")" \
        "imvOverlay=$(bare_hex "${COLOURS[surface]}")" \
        "imvFont=${FONTS[mono]}:${IMV_FONT_POINTS}"
}
