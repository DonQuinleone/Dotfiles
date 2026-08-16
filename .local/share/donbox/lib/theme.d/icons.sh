# shellcheck shell=bash

readonly ICON_THEME_NAME="donbox"
readonly ICON_SOURCE_THEME="/usr/share/icons/Adwaita"
readonly ICON_THEME_DIR="${DATA_HOME}/icons/${ICON_THEME_NAME}"

# Adwaita draws folders and devices in a fixed blue ramp with the
# shades written into each drawing, so icons are the one surface
# that cannot be pointed at an accent by configuration. Every
# blue is re-shaded to the accent at its own lightness, which
# keeps the shading and depth the artwork relies on.
readonly -a ICON_BLUES=(
    "#14498a" "#1a5fb4" "#1c71d8" "#3584e4" "#438de6"
    "#62a0ea" "#99c1f1" "#a4caee" "#afd4ff" "#b3d3f9"
    "#c0d5ea" "#d7e8fc"
)

# The blue a folder body is drawn in, so the one that becomes the
# accent exactly. The rest ramp around it.
readonly ICON_BLUE_ANCHOR="#438de6"

readonly ICON_NOMINAL_SIZE=128
readonly ICON_MIN_SIZE=8
readonly ICON_MAX_SIZE=512

declare -rA ICON_CONTEXTS=(
    [actions]=Actions
    [apps]=Applications
    [categories]=Categories
    [devices]=Devices
    [emblems]=Emblems
    [mimetypes]=MimeTypes
    [places]=Places
    [status]=Status
)

accent_shade_for() {
    local anchor subject
    anchor=$(luminance "${ICON_BLUE_ANCHOR}")
    subject=$(luminance "$1")
    if ((subject <= anchor)); then
        darken "${COLOURS[accent]}" \
            $(((anchor - subject) * PERCENT_FULL / anchor))
        return
    fi
    lighten "${COLOURS[accent]}" \
        $(((subject - anchor) * PERCENT_FULL /
            (LUMA_MAX - anchor)))
}

icon_recolour_script() {
    local blue
    for blue in "${ICON_BLUES[@]}"; do
        printf 's/%s/%s/gI;' "${blue}" \
            "$(accent_shade_for "${blue}")"
    done
}

icon_sources() {
    local pattern
    pattern=$(printf '%s|' "${ICON_BLUES[@]#\#}")
    grep -rlEi --include='*.svg' "${pattern%|}" \
        "${ICON_SOURCE_THEME}/scalable" 2>/dev/null
}

write_icon_index() {
    local -a directories=("$@")
    local directory context joined
    joined=$(
        IFS=,
        printf '%s' "${directories[*]}"
    )
    {
        cat <<EOF
[Icon Theme]
Name=${ICON_THEME_NAME}
Comment=Adwaita, re-shaded to the active accent
Inherits=Adwaita,hicolor
Directories=${joined}
EOF
        for directory in "${directories[@]}"; do
            context="${ICON_CONTEXTS[${directory##*/}]:-Legacy}"
            cat <<EOF

[${directory}]
Context=${context}
Size=${ICON_NOMINAL_SIZE}
MinSize=${ICON_MIN_SIZE}
MaxSize=${ICON_MAX_SIZE}
Type=Scalable
EOF
        done
    } >"${ICON_THEME_DIR}/index.theme"
}

# Nothing here is fatal: a missing Adwaita only costs the accent
# on folders, so it warns and leaves whatever is already there.
apply_icons() {
    local -a sources=()
    local source
    while IFS= read -r source; do
        sources+=("${source}")
    done < <(icon_sources)

    if ((${#sources[@]} == 0)); then
        warn "no Adwaita icons found; folders keep their own blue"
        return 0
    fi

    local script relative target
    local -A seen=()
    local -a directories=()
    script=$(icon_recolour_script)
    rm -rf "${ICON_THEME_DIR}"
    for source in "${sources[@]}"; do
        relative="${source#"${ICON_SOURCE_THEME}/"}"
        target="${ICON_THEME_DIR}/${relative}"
        mkdir -p "$(dirname "${target}")"
        sed "${script}" "${source}" >"${target}"
        if [[ -z "${seen[${relative%/*}]:-}" ]]; then
            seen["${relative%/*}"]=1
            directories+=("${relative%/*}")
        fi
    done
    write_icon_index "${directories[@]}"
    refresh_icon_cache
}

refresh_icon_cache() {
    command -v gtk-update-icon-cache >/dev/null 2>&1 || return 0
    gtk-update-icon-cache --force --quiet \
        "${ICON_THEME_DIR}" >/dev/null 2>&1 || true
}
