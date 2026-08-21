#!/usr/bin/env bash
set -euo pipefail
shopt -s dotglob nullglob

readonly CONFIG_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}"
readonly STATE_HOME="${XDG_STATE_HOME:-${HOME}/.local/state}"
readonly GENERATED="${STATE_HOME}/donbox/current"
readonly WAS="${STATE_HOME}/theme"

readonly TAKE=(
    "lsd-colors.yaml:${CONFIG_HOME}/lsd/colors.yaml"
    "fastfetch.jsonc:${CONFIG_HOME}/fastfetch/config.jsonc"
    "fish_variables:${CONFIG_HOME}/fish/fish_variables"
    "settings.json:${CONFIG_HOME}/quickshell/settings.json"
    "theme.json:${CONFIG_HOME}/quickshell/themes/current.json"
)

announce() {
    printf 'generated: %s\n' "$1"
}

# Emptied a file at a time rather than renamed, since the shell
# may already have written its settings to the new directory.
empty_old_state_dir() {
    [[ -d "${WAS}" ]] || return 0
    mkdir -p "${GENERATED}"

    local path
    for path in "${WAS}"/*; do
        [[ ! -e "${GENERATED}/${path##*/}" ]] || continue
        mv -- "${path}" "${GENERATED}/"
    done

    rmdir --ignore-fail-on-non-empty -- "${WAS}"
    announce "${WAS} is now ${GENERATED}"
}

# Stow folded these directories into links to the repository, so
# the path an application writes to resolves into the working
# tree, and it is the resolved file that has to be moved.
take() {
    local generated="${GENERATED}/$1" target="$2" source
    source=$(readlink -f -- "${target}") || return 0
    [[ -f "${source}" ]] || return 0
    [[ "${source}" != "${generated}" ]] || return 0

    mkdir -p "${GENERATED}"
    if [[ -e "${generated}" ]]; then
        rm -f -- "${source}"
    else
        mv -- "${source}" "${generated}"
    fi
    rm -f -- "${target}"
    announce "${target} is now ${generated}"
}

empty_old_state_dir

for entry in "${TAKE[@]}"; do
    take "${entry%%:*}" "${entry#*:}"
done
