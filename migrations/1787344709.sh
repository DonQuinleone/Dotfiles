#!/usr/bin/env bash
set -euo pipefail

readonly CONFIG_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}"
readonly STATE_HOME="${XDG_STATE_HOME:-${HOME}/.local/state}"

rename() {
    local from="$1" to="$2"
    [[ -e "${from}" ]] || return 0
    [[ ! -e "${to}" ]] || {
        printf 'nightshift: %s is already here, leaving %s\n' \
            "${to}" "${from}" >&2
        return 0
    }
    mkdir -p "$(dirname "${to}")"
    mv -- "${from}" "${to}"
    printf 'nightshift: %s is now %s\n' "${from}" "${to}"
}

rename "${STATE_HOME}/night-shift" \
    "${STATE_HOME}/donbox/nightshift"
rename "${CONFIG_HOME}/night-shift.conf" \
    "${CONFIG_HOME}/donbox/nightshift.conf"
