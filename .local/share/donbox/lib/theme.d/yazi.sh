# shellcheck shell=bash

readonly YAZI_CONFIG_DIR="${CONFIG_HOME}/yazi"
readonly YAZI_THEME="${YAZI_CONFIG_DIR}/theme.toml"
readonly YAZI_TEMPLATE="${TEMPLATE_DIR}/yazi-theme.toml.in"

apply_yazi() {
    mkdir -p "${YAZI_CONFIG_DIR}"
    render_template "${YAZI_TEMPLATE}" "${YAZI_THEME}"
}
