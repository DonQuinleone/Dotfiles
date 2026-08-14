# shellcheck shell=bash

readonly QT6CT_CONF="${CONFIG_HOME}/qt6ct/qt6ct.conf"
readonly QT6CT_SCHEME="${CONFIG_HOME}/qt6ct/colors/current.conf"

readonly QT_ROLES=(
    window_text button light midlight dark mid text
    bright_text button_text base window shadow highlight
    highlighted_text link link_visited alternate_base
    no_role tooltip_base tooltip_text placeholder_text
)

readonly MIDLIGHT_BLEND=50
readonly MID_BLEND=70
readonly BASE_BLEND=50
readonly DARK_SHADE=25
readonly SHADOW_SHADE=85
readonly BRIGHT_TEXT_SHADE=60
readonly DISABLED_HIGHLIGHT_BLEND=70

declare -A QT_ROLE=()

qt_bright_text() {
    if theme_is_dark; then
        lighten "${COLOURS[fg]}" "${BRIGHT_TEXT_SHADE}"
        return
    fi
    darken "${COLOURS[fg]}" "${BRIGHT_TEXT_SHADE}"
}

qt_active_roles() {
    QT_ROLE=(
        [window_text]="${COLOURS[fg]}"
        [button]="${COLOURS[bgAlt]}"
        [light]="${COLOURS[border]}"
        [midlight]=$(mix "${COLOURS[bgAlt]}" \
            "${COLOURS[border]}" "${MIDLIGHT_BLEND}")
        [dark]=$(darken "${COLOURS[bg]}" "${DARK_SHADE}")
        [mid]=$(mix "${COLOURS[bg]}" "${COLOURS[bgAlt]}" \
            "${MID_BLEND}")
        [text]="${COLOURS[fg]}"
        [bright_text]=$(qt_bright_text)
        [button_text]="${COLOURS[fg]}"
        [base]=$(mix "${COLOURS[bg]}" "${COLOURS[bgAlt]}" \
            "${BASE_BLEND}")
        [window]="${COLOURS[bg]}"
        [shadow]=$(darken "${COLOURS[bg]}" "${SHADOW_SHADE}")
        [highlight]="${COLOURS[accent]}"
        [highlighted_text]="${COLOURS[onAccent]}"
        [link]="${COLOURS[accent]}"
        [link_visited]="${COLOURS[accentSoft]}"
        [alternate_base]="${COLOURS[bgAlt]}"
        [no_role]="${COLOURS[fg]}"
        [tooltip_base]="${COLOURS[surface]}"
        [tooltip_text]="${COLOURS[fg]}"
        [placeholder_text]="${COLOURS[fgDim]}"
    )
}

qt_disable_roles() {
    local role
    for role in window_text text button_text no_role \
        tooltip_text placeholder_text; do
        QT_ROLE["${role}"]="${COLOURS[fgFaint]}"
    done
    QT_ROLE[highlight]=$(mix "${COLOURS[accent]}" \
        "${COLOURS[bg]}" "${DISABLED_HIGHLIGHT_BLEND}")
    QT_ROLE[highlighted_text]="${COLOURS[fgDim]}"
    QT_ROLE[link]="${COLOURS[accentDim]}"
    QT_ROLE[link_visited]="${COLOURS[accentDim]}"
}

qt_deactivate_roles() {
    QT_ROLE[highlight]="${COLOURS[accentDark]}"
    QT_ROLE[highlighted_text]="${COLOURS[fg]}"
}

qt_colour_list() {
    local role output=""
    qt_active_roles
    case "$1" in
        disabled) qt_disable_roles ;;
        inactive) qt_deactivate_roles ;;
    esac
    for role in "${QT_ROLES[@]}"; do
        [[ -n "${output}" ]] && output+=", "
        output+="${QT_ROLE[${role}],,}"
    done
    printf '%s\n' "${output}"
}

write_qt6ct_scheme() {
    mkdir -p "$(dirname "${QT6CT_SCHEME}")"
    cat >"${QT6CT_SCHEME}" <<EOF
[ColorScheme]
active_colors=$(qt_colour_list active)
disabled_colors=$(qt_colour_list disabled)
inactive_colors=$(qt_colour_list inactive)
EOF
}

write_qt6ct_conf() {
    mkdir -p "$(dirname "${QT6CT_CONF}")"
    cat >"${QT6CT_CONF}" <<EOF
[Appearance]
color_scheme_path=${QT6CT_SCHEME}
custom_palette=true
standard_dialogs=default
style=Fusion
EOF
}

point_qt6ct_at_scheme() {
    grep -q '^color_scheme_path=' "${QT6CT_CONF}" 2>/dev/null ||
        {
            write_qt6ct_conf
            return
        }
    sed -i \
        -e "s|^color_scheme_path=.*|color_scheme_path=${QT6CT_SCHEME}|" \
        -e "s|^custom_palette=.*|custom_palette=true|" \
        "${QT6CT_CONF}"
}

apply_qt() {
    write_qt6ct_scheme
    point_qt6ct_at_scheme
}
