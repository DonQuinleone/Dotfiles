# shellcheck shell=bash

readonly SHELL_COLOURS_BASH="${STATE_DIR}/shell-colours.sh"
readonly SHELL_COLOURS_FISH="${STATE_DIR}/shell-colours.fish"
readonly SHELL_PROMPT_ROLES=(accent fg fgDim)

shell_role_var() {
    case "$1" in
        fgDim) printf 'THEME_FG_DIM\n' ;;
        *) printf 'THEME_%s\n' "${1^^}" ;;
    esac
}

write_shell_colours_bash() {
    local role
    {
        for role in "${SHELL_PROMPT_ROLES[@]}"; do
            printf 'export %s=%s\n' \
                "$(shell_role_var "${role}")" \
                "$(bare_hex "${COLOURS[${role}]}")"
        done
    } >"${SHELL_COLOURS_BASH}"
}

write_shell_colours_fish() {
    local role
    {
        for role in "${SHELL_PROMPT_ROLES[@]}"; do
            printf 'set -g %s %s\n' \
                "$(shell_role_var "${role}")" \
                "$(bare_hex "${COLOURS[${role}]}")"
        done
    } >"${SHELL_COLOURS_FISH}"
}

apply_shell() {
    mkdir -p "${STATE_DIR}"
    write_shell_colours_bash
    write_shell_colours_fish
}
