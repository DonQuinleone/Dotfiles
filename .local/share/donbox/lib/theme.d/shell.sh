# shellcheck shell=bash

readonly SHELL_COLOURS_BASH="${STATE_DIR}/shell-colours.sh"
readonly SHELL_COLOURS_FISH="${STATE_DIR}/shell-colours.fish"
readonly FISH_SYNTAX_FISH="${STATE_DIR}/fish-syntax.fish"
readonly SHELL_PROMPT_ROLES=(accent fg fgDim)

# shellcheck disable=SC2034 # read by name in colour_pairs
readonly -a FISH_SYNTAX=(
    "normal:fg"
    "command:accent"
    "function:accent"
    "builtin:accentSoft"
    "keyword:accentSoft"
    "quote:good"
    "redirection:warn"
    "operator:warn"
    "end:fgDim"
    "param:fg"
    "option:accentSoft"
    "comment:fgDim"
    "escape:warn"
    "error:bad"
    "cancel:bad"
    "autosuggestion:fgFaint"
)

# shellcheck disable=SC2034 # read by name in colour_pairs
readonly -a FISH_PAGER=(
    "prefix:accent"
    "completion:fg"
    "description:fgDim"
)

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

write_fish_syntax() {
    local name colour
    {
        while IFS=$'\t' read -r name colour; do
            printf 'set -g fish_color_%s %s\n' \
                "${name}" "$(bare_hex "${colour}")"
        done < <(colour_pairs FISH_SYNTAX)
        while IFS=$'\t' read -r name colour; do
            printf 'set -g fish_pager_color_%s %s\n' \
                "${name}" "$(bare_hex "${colour}")"
        done < <(colour_pairs FISH_PAGER)
        printf 'set -g fish_color_valid_path --underline\n'
        printf 'set -g fish_color_selection --background=%s\n' \
            "${COLOURS[surface]}"
        printf 'set -g fish_color_search_match --background=%s\n' \
            "${COLOURS[surface]}"
        printf 'set -g fish_color_history_current %s --bold\n' \
            "$(bare_hex "${COLOURS[accent]}")"
        printf 'set -g fish_pager_color_progress %s\n' \
            "$(bare_hex "${COLOURS[fgDim]}")"
        printf '%s --background=%s\n' \
            'set -g fish_pager_color_selected_background' \
            "${COLOURS[surface]}"
    } >"${FISH_SYNTAX_FISH}"
}

apply_shell() {
    mkdir -p "${STATE_DIR}"
    write_shell_colours_bash
    write_shell_colours_fish
    write_fish_syntax
}
