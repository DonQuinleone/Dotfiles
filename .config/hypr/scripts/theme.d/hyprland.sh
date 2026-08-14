# shellcheck shell=bash

readonly HYPR_LOOK_FILE="${STATE_DIR}/hyprland.lua"
readonly BORDER_GRADIENT_ANGLE=45

readonly HYPR_LOOK_LOADER='dofile((os.getenv("XDG_STATE_HOME")'\
' or (os.getenv("HOME") .. "/.local/state"))'\
' .. "/theme/hyprland.lua")'

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
