# shellcheck shell=bash

readonly TEAMSPEAK_STYLE_DIR="${HOME}/.local/opt/teamspeak3/styles"
readonly TEAMSPEAK_STYLE_NAME="current"

apply_teamspeak() {
    [[ -d "${TEAMSPEAK_STYLE_DIR}" ]] || return 0
    render_template "${TEMPLATE_DIR}/teamspeak.qss.in" \
        "${TEAMSPEAK_STYLE_DIR}/${TEAMSPEAK_STYLE_NAME}.qss"
    render_template "${TEMPLATE_DIR}/teamspeak-chat.qss.in" \
        "${TEAMSPEAK_STYLE_DIR}/${TEAMSPEAK_STYLE_NAME}_chat.qss"
}
