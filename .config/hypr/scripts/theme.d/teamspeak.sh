# shellcheck shell=bash

readonly TEAMSPEAK_STYLE_DIR="${HOME}/.local/opt/teamspeak3/styles"
readonly TEAMSPEAK_STYLE_NAME="current"

render_template() {
    local template="$1" target="$2" key
    local args=()
    [[ -f "${template}" ]] ||
        die "missing template ${template}"
    for key in "${!COLOURS[@]}"; do
        args+=(-e "s|@${key}@|${COLOURS[${key}]}|g")
    done
    sed "${args[@]}" "${template}" >"${target}"
}

apply_teamspeak() {
    [[ -d "${TEAMSPEAK_STYLE_DIR}" ]] || return 0
    render_template "${TEMPLATE_DIR}/teamspeak.qss.in" \
        "${TEAMSPEAK_STYLE_DIR}/${TEAMSPEAK_STYLE_NAME}.qss"
    render_template "${TEMPLATE_DIR}/teamspeak-chat.qss.in" \
        "${TEAMSPEAK_STYLE_DIR}/${TEAMSPEAK_STYLE_NAME}_chat.qss"
}
