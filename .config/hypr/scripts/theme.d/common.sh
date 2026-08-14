# shellcheck shell=bash

readonly CONFIG_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}"
readonly STATE_DIR="${XDG_STATE_HOME:-${HOME}/.local/state}/theme"
readonly THEME_JSON_DIR="${CONFIG_HOME}/quickshell/themes"
readonly ACTIVE_JSON="${THEME_JSON_DIR}/current.json"
readonly ACTIVE_NAME_FILE="${STATE_DIR}/current"
readonly WALLPAPER_ROOT="${HOME}/Pictures/walls"
readonly WALLPAPER_STATE_DIR="${STATE_DIR}/wallpapers"
readonly GENERATED_SLUG="current"
readonly FALLBACK_SLUG="ember"

readonly COLOUR_CHANNELS=3
readonly PERCENT_FULL=100
readonly LUMA_RED_WEIGHT=299
readonly LUMA_GREEN_WEIGHT=587
readonly LUMA_BLUE_WEIGHT=114
readonly LUMA_WEIGHT_TOTAL=1000
readonly LUMA_MIDPOINT=128
readonly BLACK="#000000"
readonly WHITE="#FFFFFF"

readonly FAINT_BLEND=45
readonly BORDER_STRONG_BLEND=25
readonly ACCENT_DIM_BLEND=15
readonly ACCENT_DARK_BLEND=55

declare -A PALETTE=()
declare -A COLOURS=()
declare -A FONTS=()

THEME_SLUG=""
THEME_SOURCE=""
THEME_WALLPAPER=""

die() {
    printf 'theme: %s\n' "$*" >&2
    exit 1
}

warn() {
    printf 'theme: %s\n' "$*" >&2
}

require_command() {
    command -v "$1" >/dev/null 2>&1 ||
        die "$1 is not installed but is required"
}

theme_slugs() {
    local path slug
    for path in "${THEME_JSON_DIR}"/*.json; do
        [[ -f "${path}" ]] || continue
        slug=$(basename "${path}" .json)
        if [[ "${slug}" != "${GENERATED_SLUG}" ]]; then
            printf '%s\n' "${slug}"
        fi
    done
}

active_slug() {
    if [[ -r "${ACTIVE_NAME_FILE}" ]]; then
        head -n 1 "${ACTIVE_NAME_FILE}"
        return
    fi
    printf '%s\n' "${FALLBACK_SLUG}"
}

channels() {
    local hex="${1#\#}"
    [[ "${hex}" =~ ^[0-9A-Fa-f]{6}$ ]] ||
        die "'$1' is not a six-digit hex colour"
    printf '%d %d %d\n' \
        "0x${hex:0:2}" "0x${hex:2:2}" "0x${hex:4:2}"
}

mix() {
    local -a base other
    read -r -a base <<<"$(channels "$1")"
    read -r -a other <<<"$(channels "$2")"
    local weight="$3" index value result=""
    for ((index = 0; index < COLOUR_CHANNELS; index++)); do
        value=$(((base[index] * (PERCENT_FULL - weight) +
            other[index] * weight) / PERCENT_FULL))
        result+=$(printf '%02X' "${value}")
    done
    printf '#%s\n' "${result}"
}

darken() {
    mix "$1" "${BLACK}" "$2"
}

lighten() {
    mix "$1" "${WHITE}" "$2"
}

luminance() {
    local -a rgb
    read -r -a rgb <<<"$(channels "$1")"
    printf '%d\n' $(((rgb[0] * LUMA_RED_WEIGHT +
        rgb[1] * LUMA_GREEN_WEIGHT +
        rgb[2] * LUMA_BLUE_WEIGHT) / LUMA_WEIGHT_TOTAL))
}

absolute() {
    printf '%d\n' "${1#-}"
}

readable_on() {
    local subject bg_gap fg_gap
    subject=$(luminance "$1")
    bg_gap=$(absolute \
        $((subject - $(luminance "${PALETTE[bg]}"))))
    fg_gap=$(absolute \
        $((subject - $(luminance "${PALETTE[fg]}"))))
    if ((bg_gap >= fg_gap)); then
        printf '%s\n' "${PALETTE[bg]}"
        return
    fi
    printf '%s\n' "${PALETTE[fg]}"
}

theme_is_dark() {
    (($(luminance "${PALETTE[bg]}") < LUMA_MIDPOINT))
}

light_or_dark() {
    if theme_is_dark; then
        printf 'dark\n'
        return
    fi
    printf 'light\n'
}

bare_hex() {
    local hex="${1#\#}"
    printf '%s\n' "${hex,,}"
}

load_palette() {
    local key value
    PALETTE=()
    while IFS=$'\t' read -r key value; do
        PALETTE["${key}"]="${value}"
    done < <(jq -r '.palette | to_entries[] |
        [.key, .value] | @tsv' "$1")
    [[ -n "${PALETTE[accent]:-}" ]] ||
        die "$1 has no palette.accent"
}

load_fonts() {
    local key value
    FONTS=()
    while IFS=$'\t' read -r key value; do
        FONTS["${key}"]="${value}"
    done < <(jq -r '.fonts | to_entries[] |
        [.key, .value] | @tsv' "$1")
    [[ -n "${FONTS[ui]:-}" && -n "${FONTS[mono]:-}" ]] ||
        die "$1 must name both fonts.ui and fonts.mono"
}

palette_json() {
    local key args=()
    for key in "${!PALETTE[@]}"; do
        args+=(--arg "${key}" "${PALETTE[${key}]}")
    done
    jq -n "${args[@]}" '$ARGS.named'
}

derive_colours() {
    local key
    COLOURS=()
    for key in "${!PALETTE[@]}"; do
        COLOURS["${key}"]="${PALETTE[${key}]}"
    done
    COLOURS[onAccent]=$(readable_on "${PALETTE[accent]}")
    COLOURS[fgFaint]=$(mix "${PALETTE[fgDim]}" \
        "${PALETTE[bg]}" "${FAINT_BLEND}")
    COLOURS[borderStrong]=$(mix "${PALETTE[border]}" \
        "${PALETTE[fg]}" "${BORDER_STRONG_BLEND}")
    COLOURS[accentDim]=$(mix "${PALETTE[accent]}" \
        "${PALETTE[bg]}" "${ACCENT_DIM_BLEND}")
    COLOURS[accentDark]=$(mix "${PALETTE[accent]}" \
        "${PALETTE[bg]}" "${ACCENT_DARK_BLEND}")
}

render_template() {
    local template="$1" target="$2" key pair args=()
    shift 2
    [[ -f "${template}" ]] ||
        die "missing template ${template}"
    for key in "${!COLOURS[@]}"; do
        args+=(-e "s|@${key}@|${COLOURS[${key}]}|g")
    done
    for pair in "$@"; do
        args+=(-e "s|@${pair%%=*}@|${pair#*=}|g")
    done
    sed "${args[@]}" "${template}" >"${target}"
}

wallpaper_override_file() {
    printf '%s/%s\n' "${WALLPAPER_STATE_DIR}" "$1"
}

expand_home() {
    # shellcheck disable=SC2088
    case "$1" in
    "~/"*) printf '%s/%s\n' "${HOME}" "${1:2}" ;;
    *) printf '%s\n' "$1" ;;
    esac
}

resolve_wallpaper() {
    local override
    override=$(wallpaper_override_file "$1")
    if [[ -r "${override}" ]]; then
        expand_home "$(head -n 1 "${override}")"
        return
    fi
    expand_home "$(jq -r '.wallpaper // ""' "$2")"
}

select_theme() {
    local slug="$1"
    THEME_SOURCE="${THEME_JSON_DIR}/${slug}.json"
    [[ -f "${THEME_SOURCE}" ]] ||
        die "unknown theme '${slug}'; try: $(theme_slugs |
            paste -sd ' ' -)"
    jq -e . "${THEME_SOURCE}" >/dev/null 2>&1 ||
        die "${THEME_SOURCE} is not valid JSON"
    THEME_SLUG="${slug}"
    THEME_WALLPAPER=$(resolve_wallpaper "${slug}" \
        "${THEME_SOURCE}")
    load_palette "${THEME_SOURCE}"
    load_fonts "${THEME_SOURCE}"
    load_accents "${THEME_SOURCE}"
    resolve_accent "${slug}"
    derive_colours
}
