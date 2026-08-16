# shellcheck shell=bash

readonly HYPR_LOOK_FILE="${STATE_DIR}/hyprland.lua"
readonly BORDER_GRADIENT_ANGLE=45

readonly HYPR_LOOK_LOADER='dofile((os.getenv("XDG_STATE_HOME")'\
' or (os.getenv("HOME") .. "/.local/state"))'\
' .. "/theme/hyprland.lua")'

hypr_font() {
    jq -r "$1" "${THEME_SOURCE}"
}

hypr_colour() {
    printf 'rgba(%sff)\n' "$(bare_hex "$1")"
}

write_hyprland_look() {
    cat >"${HYPR_LOOK_FILE}" <<EOF
hl.config({
    general = {
        col = {
            active_border = {
                colors = {
                    "$(hypr_colour "${COLOURS[accent]}")",
                    "$(hypr_colour "${COLOURS[accentSoft]}")",
                },
                angle = ${BORDER_GRADIENT_ANGLE},
            },
            inactive_border =
                "$(hypr_colour "${COLOURS[border]}")",
        },
    },
    group = {
        col = {
            border_active = {
                colors = {
                    "$(hypr_colour "${COLOURS[accent]}")",
                    "$(hypr_colour "${COLOURS[accentSoft]}")",
                },
                angle = ${BORDER_GRADIENT_ANGLE},
            },
            border_inactive =
                "$(hypr_colour "${COLOURS[border]}")",
        },
        groupbar = {
            font_family = "$(hypr_font .fonts.ui)",
            font_size = $(hypr_font .fontSizes.large),
            col = {
                active = "$(hypr_colour "${COLOURS[accent]}")",
                inactive =
                    "$(hypr_colour "${COLOURS[surface]}")",
            },
            text_color =
                "$(hypr_colour "${COLOURS[onAccent]}")",
            text_color_inactive =
                "$(hypr_colour "${COLOURS[fg]}")",
        },
    },
    misc = {
        background_color = "$(hypr_colour "${COLOURS[bg]}")",
    },
})
EOF
}

apply_hyprland() {
    mkdir -p "${STATE_DIR}"
    write_hyprland_look
    if [[ -z "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
        return
    fi
    hyprctl eval "${HYPR_LOOK_LOADER}" >/dev/null ||
        warn "hyprctl could not apply the border colours"
}
