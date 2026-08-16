# shellcheck shell=bash

readonly LSD_CONFIG_DIR="${CONFIG_HOME}/lsd"
readonly LSD_COLOURS="${LSD_CONFIG_DIR}/colors.yaml"

# lsd reads crossterm colours, which take a hex string as well as
# a palette index, so the theme goes in at full depth rather than
# being rounded to the nearest of 256.
apply_lsd() {
    mkdir -p "${LSD_CONFIG_DIR}"
    render_template "${TEMPLATE_DIR}/lsd-colors.yaml.in" \
        "${LSD_COLOURS}"
}
