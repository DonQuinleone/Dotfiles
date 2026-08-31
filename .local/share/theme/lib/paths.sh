# shellcheck shell=bash
# shellcheck disable=SC2034 # the callers read these by name

CONFIG=${XDG_CONFIG_HOME:-${HOME}/.config}
STATE=${XDG_STATE_HOME:-${HOME}/.local/state}
DATA=${XDG_DATA_HOME:-${HOME}/.local/share}
readonly CONFIG STATE DATA

readonly THEMES=${CONFIG}/theme/themes
readonly TEMPLATES=${CONFIG}/theme/templates
readonly RENDERED=${STATE}/theme
readonly CURRENT=${RENDERED}/current
readonly CARDS=${RENDERED}/cards

die() {
    printf '%s: %s\n' "${0##*/}" "$1" >&2
    exit 1
}
