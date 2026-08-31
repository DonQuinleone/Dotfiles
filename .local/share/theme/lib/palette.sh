# shellcheck shell=bash

readonly FONT_UI="IBM Plex Sans"
readonly FONT_MONO="JetBrainsMono Nerd Font"
readonly SIZE_UI=17
readonly SIZE_MONO=17
readonly SIZE_BAR=16
readonly WEIGHT_BODY=400
readonly WEIGHT_BOLD=700

readonly TERMINAL_DARK_OPACITY=0.8
readonly TERMINAL_LIGHT_OPACITY=0.97
readonly LIGHT_MODE_SUM=382

# shellcheck disable=SC2034 # passed to add_pairs by name
readonly -a MOTION=(
    "motion_quick:150"
    "motion_normal:175"
    "motion_slow:200"
    "motion_standard:OutCubic"
    "motion_enter:OutBack"
    "motion_exit:OutCubic"
    "motion_reduce:false"
)

# shellcheck disable=SC2034 # passed to add_pairs by name
readonly -a CONSTANT_TOKENS=(
    "theme_font_ui:${FONT_UI}"
    "theme_font_mono:${FONT_MONO}"
    "theme_size_ui:${SIZE_UI}"
    "theme_size_mono:${SIZE_MONO}"
    "theme_size_bar:${SIZE_BAR}"
    "theme_weight_body:${WEIGHT_BODY}"
    "theme_weight_bold:${WEIGHT_BOLD}"
)

declare -A TOKENS=()

slugs() {
    local path
    for path in "${THEMES}"/*.toml; do
        [[ -e $path ]] || continue
        printf '%s\n' "$(basename "${path}" .toml)"
    done
}

read_palette() {
    local path=$1 line key value
    while IFS= read -r line; do
        [[ $line =~ ^[[:space:]]*([A-Za-z0-9_]+)[[:space:]]*=[[:space:]]*(.*)$ ]] ||
            continue
        key=${BASH_REMATCH[1]}
        value=${BASH_REMATCH[2]}
        value=${value%"${value##*[![:space:]]}"}
        value=${value#\"}
        value=${value%\"}
        TOKENS[${key}]=${value}
    done <"${path}"
}

default_token() {
    [[ -n ${TOKENS[$1]:-} ]] && return 0
    TOKENS[$1]=$2
}

derive_mode() {
    [[ -n ${TOKENS[mode]:-} ]] && return 0
    TOKENS[mode]=dark
    (( $(channel_sum "${TOKENS[background]}") > LIGHT_MODE_SUM )) &&
        TOKENS[mode]=light
    return 0
}

add_pairs() {
    local -n rows=$1
    local entry
    for entry in "${rows[@]}"; do
        TOKENS[${entry%%:*}]=${entry#*:}
    done
}

add_stripped() {
    local key
    for key in "${!TOKENS[@]}"; do
        [[ ${TOKENS[$key]} == '#'* ]] || continue
        TOKENS[${key}_strip]=${TOKENS[$key]#\#}
    done
}

tokens_for() {
    local slug=$1 path=${THEMES}/$1.toml
    [[ -f $path ]] ||
        die "no theme called '${slug}' (have: $(slugs | tr '\n' ' '))"

    TOKENS=()
    read_palette "${path}"
    derive_mode

    default_token cursor "${TOKENS[bright_foreground]}"
    default_token selection_background "${TOKENS[selection]}"
    default_token selection_foreground "${TOKENS[bright_foreground]}"

    TOKENS[prefers_dark]=false
    TOKENS[terminal_opacity]=${TERMINAL_LIGHT_OPACITY}
    if [[ ${TOKENS[mode]} == dark ]]; then
        TOKENS[prefers_dark]=true
        TOKENS[terminal_opacity]=${TERMINAL_DARK_OPACITY}
    fi

    TOKENS[theme_slug]=${slug}
    TOKENS[theme_name]=${TOKENS[name]:-$slug}
    add_pairs CONSTANT_TOKENS
    add_pairs MOTION
    add_stripped
}
