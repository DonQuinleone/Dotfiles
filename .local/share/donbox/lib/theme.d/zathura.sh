# shellcheck shell=bash

readonly ZATHURA_CONFIG_DIR="${CONFIG_HOME}/zathura"
readonly ZATHURA_CONFIG="${ZATHURA_CONFIG_DIR}/zathurarc"
readonly ZATHURA_TEMPLATE="${TEMPLATE_DIR}/zathurarc.in"
readonly ZATHURA_FONT_POINTS=10

apply_zathura() {
    mkdir -p "${ZATHURA_CONFIG_DIR}"
    render_template "${ZATHURA_TEMPLATE}" "${ZATHURA_CONFIG}" \
        "zathuraFont=${FONTS[mono]} ${ZATHURA_FONT_POINTS}"
}
