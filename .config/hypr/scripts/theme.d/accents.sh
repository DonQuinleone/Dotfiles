# shellcheck shell=bash

readonly ACCENT_STATE_DIR="${STATE_DIR}/accents"
readonly ACCENT_SOFT_BLEND=35
readonly ACCENT_COLUMN_WIDTH=16
readonly ACCENT_LOW_NOTE="below AA"

declare -A ACCENTS=()
declare -a ACCENT_ORDER=()

DEFAULT_ACCENT=""
ACCENT_NAME=""
ACCENT_REQUEST=""

load_accents() {
    local name value
    ACCENTS=()
    ACCENT_ORDER=()
    while IFS=$'\t' read -r name value; do
        ACCENTS["${name}"]="${value}"
        ACCENT_ORDER+=("${name}")
    done < <(jq -r '.accents // {} | to_entries[] |
        [.key, .value] | @tsv' "$1")
    DEFAULT_ACCENT=$(jq -r '.defaultAccent // ""' "$1")
}

accent_state_file() {
    printf '%s/%s\n' "${ACCENT_STATE_DIR}" "$1"
}

stored_accent() {
    local file
    file=$(accent_state_file "$1")
    [[ -r "${file}" ]] || return 0
    head -n 1 "${file}"
}

store_accent() {
    mkdir -p "${ACCENT_STATE_DIR}"
    printf '%s\n' "$2" >"$(accent_state_file "$1")"
}

accent_soft() {
    if theme_is_dark; then
        lighten "$1" "${ACCENT_SOFT_BLEND}"
        return
    fi
    darken "$1" "${ACCENT_SOFT_BLEND}"
}

wear_accent() {
    local name="$1" hex="${ACCENTS[$1]:-}"
    [[ -n "${hex}" ]] || return 1
    ACCENT_NAME="${name}"
    [[ "${name}" != "${DEFAULT_ACCENT}" ]] || return 0
    PALETTE[accent]="${hex}"
    PALETTE[accentSoft]=$(accent_soft "${hex}")
}

resolve_accent() {
    local slug="$1" chosen="${ACCENT_REQUEST}"
    ACCENT_NAME="${DEFAULT_ACCENT}"
    [[ -n "${chosen}" ]] || chosen=$(stored_accent "${slug}")
    [[ -n "${chosen}" ]] || return 0
    wear_accent "${chosen}" ||
        warn "${slug} has no '${chosen}' accent"
}

accent_contrast() {
    contrast_centis "${PALETTE[accent]}" "${PALETTE[bg]}"
}

accent_is_readable() {
    contrast_passes "$(accent_contrast)"
}

report_accent_contrast() {
    warn "the ${ACCENT_NAME} accent reads" \
        "$(contrast_text "$(accent_contrast)") on the background," \
        "under the $(contrast_text "${CONTRAST_MINIMUM}") that" \
        "WCAG AA asks for"
}

warn_unreadable_accent() {
    accent_is_readable && return 0
    report_accent_contrast
}

require_readable_accent() {
    accent_is_readable && return 0
    report_accent_contrast
    [[ "${ACCENT_NAME}" != "${DEFAULT_ACCENT}" ]] || return 0
    die "refusing '${ACCENT_NAME}'; choose a stronger accent"
}

list_accents() {
    local name hex centis note marker
    ((${#ACCENT_ORDER[@]} > 0)) ||
        die "${THEME_SLUG} has no accent variants"
    for name in "${ACCENT_ORDER[@]}"; do
        hex="${ACCENTS[${name}]}"
        centis=$(contrast_centis "${hex}" "${PALETTE[bg]}")
        note=""
        contrast_passes "${centis}" || note="${ACCENT_LOW_NOTE}"
        marker=" "
        [[ "${name}" != "${ACCENT_NAME}" ]] || marker="*"
        printf '%s %-*s %s %8s%s\n' \
            "${marker}" "${ACCENT_COLUMN_WIDTH}" "${name}" \
            "${hex}" "$(contrast_text "${centis}")" \
            "${note:+  ${note}}"
    done
}
