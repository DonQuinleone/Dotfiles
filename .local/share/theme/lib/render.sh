# shellcheck shell=bash

MIX_TOKEN='\{\{[[:space:]]*(mix|mix_strip)[[:space:]]+'
MIX_TOKEN+='([A-Za-z0-9_]+)[[:space:]]+([A-Za-z0-9_]+)'
MIX_TOKEN+='[[:space:]]+([0-9]+)%?[[:space:]]*\}\}'
readonly MIX_TOKEN

readonly NAME_TOKEN='\{\{[[:space:]]*([A-Za-z0-9_]+)[[:space:]]*\}\}'

readonly -a LINKS=(
    "btop.theme:btop/themes/current.theme"
    "lsd-colours.yaml:lsd/colors.yaml"
    "qt6ct.conf:qt6ct/colors/current.conf"
    "gtk3.css:gtk-3.0/gtk.css"
    "gtk3-settings.ini:gtk-3.0/settings.ini"
    "gtk4.css:gtk-4.0/gtk.css"
    "gtk4-settings.ini:gtk-4.0/settings.ini"
    "yazi-theme.toml:yazi/theme.toml"
    "imv.conf:imv/config"
    "rofi.rasi:rofi/theme.rasi"
    "mako.conf:mako/config"
    "hyprlock.conf:hypr/hyprlock-colours.conf"
    "waybar.css:waybar/style.css"
    "zathurarc:zathura/zathurarc"
)

declare -A BLENDED=()

# A template's trailing newlines are part of the file, and
# command substitution eats them, so every one of these hands
# its result back through a named variable instead.
read_file() {
    local -n destination=$1
    IFS= read -r -d '' destination <"$2" || true
}

blend() {
    local key="$1 $2 $3"
    [[ -n ${BLENDED[$key]:-} ]] || BLENDED[$key]=$(mix "$1" "$2" "$3")
    printf '%s\n' "${BLENDED[$key]}"
}

render_mixes() {
    local -n destination=$1
    local rest=$2 out='' match verb start end amount value
    while [[ $rest =~ $MIX_TOKEN ]]; do
        match=${BASH_REMATCH[0]}
        verb=${BASH_REMATCH[1]}
        start=${BASH_REMATCH[2]}
        end=${BASH_REMATCH[3]}
        amount=${BASH_REMATCH[4]}
        out+=${rest%%"${match}"*}
        rest=${rest#*"${match}"}
        if [[ -z ${TOKENS[$start]:-} || -z ${TOKENS[$end]:-} ]]; then
            out+=${match}
            continue
        fi
        value=$(blend "${TOKENS[$start]}" "${TOKENS[$end]}" \
            "${amount}")
        [[ $verb == mix_strip ]] && value=${value#\#}
        out+=${value}
    done
    # shellcheck disable=SC2034 # a nameref on the caller's own
    destination=${out}${rest}
}

render_names() {
    local -n destination=$1
    local rest=$2 out='' match name
    while [[ $rest =~ $NAME_TOKEN ]]; do
        match=${BASH_REMATCH[0]}
        name=${BASH_REMATCH[1]}
        out+=${rest%%"${match}"*}
        rest=${rest#*"${match}"}
        out+=${TOKENS[$name]:-$match}
    done
    # shellcheck disable=SC2034 # a nameref on the caller's own
    destination=${out}${rest}
}

render_template() {
    local template=$1 text blended filled
    read_file text "${template}"
    render_mixes blended "${text}"
    render_names filled "${blended}"
    printf '%s' "${filled}" \
        >"${RENDERED}/$(basename "${template}" .tpl)"
}

render_templates() {
    local template written=0
    for template in "${TEMPLATES}"/*.tpl; do
        [[ -e $template ]] || continue
        render_template "${template}"
        written=$(( written + 1 ))
    done
    printf '%d\n' "${written}"
}

link_file() {
    local target=$1 path=$2
    mkdir -p "$(dirname "${path}")"
    [[ -L $path && $(readlink "${path}") == "${target}" ]] && return 0
    [[ -e $path || -L $path ]] && rm -f -- "${path}"
    ln -s "${target}" "${path}"
}

link_rendered() {
    local entry target
    for entry in "${LINKS[@]}"; do
        target=${RENDERED}/${entry%%:*}
        [[ -f $target ]] || continue
        link_file "${target}" "${CONFIG}/${entry#*:}"
    done
}
