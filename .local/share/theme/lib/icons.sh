# shellcheck shell=bash

readonly ICON_SOURCE=/usr/share/icons/Adwaita/scalable
readonly ICON_THEME=adwaita-accent
readonly ICON_SIZE=128
readonly ICON_MIN_SIZE=8
readonly ICON_MAX_SIZE=512
readonly SHADE_SCALE=100000

# Adwaita writes its blue ramp into each drawing, so icons are
# the one surface no setting can point at an accent. Each blue
# is re-shaded to the accent at its own lightness, which keeps
# the depth the artwork relies on.
readonly -a ICON_BLUES=(
    "#14498a" "#1a5fb4" "#1c71d8" "#3584e4" "#438de6"
    "#62a0ea" "#99c1f1" "#a4caee" "#afd4ff" "#b3d3f9"
    "#c0d5ea" "#d7e8fc"
)

# The blue a folder body is drawn in, so the shade that becomes
# the accent exactly; the rest ramp around it.
readonly ICON_ANCHOR="#438de6"

readonly -a ICON_CONTEXTS=(
    "actions:Actions"
    "apps:Applications"
    "categories:Categories"
    "devices:Devices"
    "emblems:Emblems"
    "mimetypes:MimeTypes"
    "places:Places"
    "status:Status"
)
readonly ICON_CONTEXT_FALLBACK=Legacy

icon_shade() {
    local blue=$1 accent=$2 anchor value
    anchor=$(luma "${ICON_ANCHOR}")
    value=$(luma "${blue}")
    if (( value <= anchor )); then
        mix "${accent}" "#000000" \
            "$(( (anchor - value) * SHADE_SCALE / anchor ))" \
            "${SHADE_SCALE}"
        return
    fi
    mix "${accent}" "#ffffff" \
        "$(( (value - anchor) * SHADE_SCALE
             / (CHANNEL_MAX - anchor) ))" "${SHADE_SCALE}"
}

shade_script() {
    local accent=$1 blue
    for blue in "${ICON_BLUES[@]}"; do
        printf 's/%s/%s/Ig\n' "${blue}" \
            "$(icon_shade "${blue}" "${accent}")"
    done
}

icon_context() {
    local directory=${1##*/} entry
    for entry in "${ICON_CONTEXTS[@]}"; do
        [[ ${entry%%:*} == "${directory}" ]] || continue
        printf '%s\n' "${entry#*:}"
        return
    done
    printf '%s\n' "${ICON_CONTEXT_FALLBACK}"
}

write_icon_index() {
    local theme_dir=$1
    local -n listed=$2
    local directory
    {
        printf '[Icon Theme]\n'
        printf 'Name=%s\n' "${ICON_THEME}"
        printf 'Comment=Adwaita, re-shaded to the accent\n'
        printf 'Inherits=Adwaita,hicolor\n'
        printf 'Directories=%s\n' \
            "$(printf '%s,' "${listed[@]}" | sed 's/,$//')"
        for directory in "${listed[@]}"; do
            printf '\n[%s]\n' "${directory}"
            printf 'Context=%s\n' "$(icon_context "${directory}")"
            printf 'Size=%d\n' "${ICON_SIZE}"
            printf 'MinSize=%d\n' "${ICON_MIN_SIZE}"
            printf 'MaxSize=%d\n' "${ICON_MAX_SIZE}"
            printf 'Type=Scalable\n'
        done
    } >"${theme_dir}/index.theme"
}

refresh_icon_cache() {
    command -v gtk-update-icon-cache >/dev/null 2>&1 || return 0
    gtk-update-icon-cache --force --quiet "$1" || true
}

# Re-shading the set is the one slow thing here and it turns on
# nothing but the accent, so the accent it was shaded from is
# recorded beside it and an unchanged one is not shaded twice.
apply_icons() {
    [[ -d $ICON_SOURCE ]] || return 0
    local accent=${TOKENS[accent]}
    local theme_dir=${DATA}/icons/${ICON_THEME}
    local stamp=${theme_dir}/accent
    [[ -f $stamp && $(<"${stamp}") == "${accent}" ]] && return 0

    local script pattern source relative target parent
    script=$(shade_script "${accent}")
    pattern=$(printf '%s|' "${ICON_BLUES[@]}" | sed 's/|$//')
    rm -rf -- "${theme_dir}"

    local -a directories=()
    local -A seen=()
    while IFS= read -r source; do
        grep -qiE "${pattern}" "${source}" || continue
        relative=${source#"${ICON_SOURCE}"/}
        target=${theme_dir}/${relative}
        mkdir -p "$(dirname "${target}")"
        sed "${script}" "${source}" >"${target}"
        parent=$(dirname "${relative}")
        [[ -n ${seen[$parent]:-} ]] && continue
        seen[${parent}]=1
        directories+=("${parent}")
    done < <(find "${ICON_SOURCE}" -name '*.svg' | LC_ALL=C sort)

    (( ${#directories[@]} )) || return 0
    write_icon_index "${theme_dir}" directories
    printf '%s\n' "${accent}" >"${stamp}"
    refresh_icon_cache "${theme_dir}"
}
