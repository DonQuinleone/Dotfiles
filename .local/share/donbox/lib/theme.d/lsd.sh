# shellcheck shell=bash

readonly LSD_COLOURS="${STATE_DIR}/lsd-colors.yaml"

# lsd reads crossterm colours, which take a hex string as well as
# a palette index, so the theme goes in at full depth rather than
# being rounded to the nearest of 256.
apply_lsd() {
    mkdir -p "${STATE_DIR}"
    render_template "${TEMPLATE_DIR}/lsd-colors.yaml.in" \
        "${LSD_COLOURS}"
}
