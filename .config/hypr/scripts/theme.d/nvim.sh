# shellcheck shell=bash

readonly NVIM_STATE_FILE="${STATE_DIR}/nvim.lua"
readonly NVIM_CONTRAST_STEP=6
readonly NVIM_CONTRAST_TRIES=24

readonly NVIM_UI_KEYS=(
    accent accentDim bg bgAlt border borderStrong onAccent surface
)

readonly NVIM_TEXT_KEYS=(accent bad fg fgDim good warn)

away_from_background() {
    if theme_is_dark; then
        lighten "$1" "${NVIM_CONTRAST_STEP}"
        return
    fi
    darken "$1" "${NVIM_CONTRAST_STEP}"
}

# Text colours only ever move away from the background, so a
# palette that already clears AA, as the high-contrast variants
# do, is emitted untouched.
raise_to_readable() {
    local colour="$1" tries=0
    until contrast_passes \
        "$(contrast_centis "${colour}" "${COLOURS[bg]}")"; do
        ((tries < NVIM_CONTRAST_TRIES)) || break
        colour=$(away_from_background "${colour}")
        tries=$((tries + 1))
    done
    printf '%s\n' "${colour}"
}

nvim_ui_entries() {
    local key
    for key in "${NVIM_UI_KEYS[@]}"; do
        printf '        %s = "%s",\n' \
            "${key}" "${COLOURS[${key}]}"
    done
}

nvim_text_entries() {
    local key readable
    for key in "${NVIM_TEXT_KEYS[@]}"; do
        readable=$(raise_to_readable "${COLOURS[${key}]}")
        printf '        %s = "%s",\n' "${key}" "${readable}"
    done
}

write_nvim_state() {
    {
        printf 'return {\n'
        printf '    background = "%s",\n' "$(light_or_dark)"
        printf '    ui = {\n'
        nvim_ui_entries
        printf '    },\n    text = {\n'
        nvim_text_entries
        printf '    },\n}\n'
    } >"${NVIM_STATE_FILE}"
}

apply_nvim() {
    mkdir -p "${STATE_DIR}"
    write_nvim_state
}
