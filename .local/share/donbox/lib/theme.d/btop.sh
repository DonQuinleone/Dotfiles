# shellcheck shell=bash

readonly BTOP_CONFIG_DIR="${CONFIG_HOME}/btop"
readonly BTOP_THEME_DIR="${BTOP_CONFIG_DIR}/themes"
readonly BTOP_THEME_NAME="donbox"
readonly BTOP_THEME_FILE="${BTOP_THEME_DIR}/${BTOP_THEME_NAME}.theme"
readonly BTOP_CONF="${BTOP_CONFIG_DIR}/btop.conf"

# btop floods main_bg over the whole terminal, so naming a colour
# here would punch an opaque rectangle through the shell's
# translucency and blur. Empty leaves the terminal's own ground,
# which this theme has already painted.
readonly BTOP_TERMINAL_GROUND=""

readonly BTOP_FADE_BLEND=45
readonly BTOP_LIFT_SHADE=30

readonly -a BTOP_RAMP_STOPS=(start mid end)

# Meters that answer "how bad is it", which read as one ramp from
# healthy to alarming.
readonly -a BTOP_LOAD_RAMPS=(temp cpu used process)

# Meters that only measure one quantity, which each take a single
# palette hue faded in from the background and lifted past it.
readonly -a BTOP_HUE_RAMPS=(
    "free:good"
    "available:warn"
    "cached:accentSoft"
    "download:good"
    "upload:accent"
)

# shellcheck disable=SC2034 # read by name in colour_pairs
readonly -a BTOP_SURFACES=(
    "main_fg:fg"
    "title:fg"
    "hi_fg:accent"
    "selected_bg:accent"
    "selected_fg:onAccent"
    "followed_bg:good"
    "followed_fg:onGood"
    "inactive_fg:fgFaint"
    "graph_text:fg"
    "meter_bg:surface"
    "proc_misc:accentSoft"
    "proc_banner_bg:accent"
    "proc_banner_fg:onAccent"
    "proc_follow_bg:good"
    "proc_pause_bg:warn"
    "cpu_box:borderStrong"
    "mem_box:borderStrong"
    "net_box:borderStrong"
    "proc_box:borderStrong"
    "div_line:border"
)

btop_lift() {
    if theme_is_dark; then
        lighten "$1" "${BTOP_LIFT_SHADE}"
        return
    fi
    darken "$1" "${BTOP_LIFT_SHADE}"
}

emit_btop_colours() {
    local name colour
    while IFS=$'\t' read -r name colour; do
        printf 'theme[%s]="%s"\n' "${name}" "${colour}"
    done
}

emit_btop_ramp() {
    local name="$1" stop
    shift
    for stop in "${BTOP_RAMP_STOPS[@]}"; do
        printf 'theme[%s_%s]="%s"\n' "${name}" "${stop}" "$1"
        shift
    done
}

emit_btop_load_ramps() {
    local name
    for name in "${BTOP_LOAD_RAMPS[@]}"; do
        emit_btop_ramp "${name}" "${COLOURS[good]}" \
            "${COLOURS[warn]}" "${COLOURS[bad]}"
    done
}

emit_btop_hue_ramps() {
    local entry hue
    for entry in "${BTOP_HUE_RAMPS[@]}"; do
        hue="${COLOURS[${entry#*:}]}"
        emit_btop_ramp "${entry%%:*}" \
            "$(mix "${hue}" "${COLOURS[bg]}" "${BTOP_FADE_BLEND}")" \
            "${hue}" "$(btop_lift "${hue}")"
    done
}

write_btop_theme() {
    mkdir -p "${BTOP_THEME_DIR}"
    {
        printf 'theme[main_bg]="%s"\n' "${BTOP_TERMINAL_GROUND}"
        colour_pairs BTOP_SURFACES | emit_btop_colours
        emit_btop_load_ramps
        emit_btop_hue_ramps
    } >"${BTOP_THEME_FILE}"
}

btop_theme_line() {
    printf 'color_theme = "%s"\n' "${BTOP_THEME_NAME}"
}

# btop rewrites its whole configuration on exit, so only the one
# line it owns here may be touched: anything else would discard
# settings tuned in the running program.
point_btop_at_theme() {
    local replacement
    mkdir -p "${BTOP_CONFIG_DIR}"
    if [[ ! -f "${BTOP_CONF}" ]]; then
        btop_theme_line >"${BTOP_CONF}"
        return
    fi
    if ! grep -q '^color_theme[[:space:]]*=' "${BTOP_CONF}"; then
        btop_theme_line >>"${BTOP_CONF}"
        return
    fi
    replacement=$(btop_theme_line)
    sed -i "s|^color_theme[[:space:]]*=.*|${replacement}|" \
        "${BTOP_CONF}"
}

apply_btop() {
    write_btop_theme
    point_btop_at_theme
}
