# shellcheck shell=bash

readonly GTK3_CSS="${CONFIG_HOME}/gtk-3.0/gtk.css"
readonly GTK4_CSS="${CONFIG_HOME}/gtk-4.0/gtk.css"
readonly GTK3_SETTINGS="${CONFIG_HOME}/gtk-3.0/settings.ini"
readonly GTK4_SETTINGS="${CONFIG_HOME}/gtk-4.0/settings.ini"

# Application text stays at a sighted reader's size on purpose:
# the magnifier does the enlarging, and inflating it here would
# only cut how much text fits under the lens.
readonly GTK_FONT_POINTS=10

# Named here rather than left to whatever a desktop happened to
# set, so removing that desktop cannot take them with it.
readonly GTK_ICON_THEME="Adwaita"
readonly GTK_THEME_NAME="Adwaita"

gtk_prefers_dark() {
    if theme_is_dark; then
        printf '1\n'
        return
    fi
    printf '0\n'
}

colour_scheme() {
    printf 'prefer-%s\n' "$(light_or_dark)"
}

replace_with_regular_file() {
    mkdir -p "$(dirname "$1")"
    if [[ -L "$1" ]]; then
        rm -- "$1"
    fi
}

write_gtk3_css() {
    replace_with_regular_file "${GTK3_CSS}"
    cat >"${GTK3_CSS}" <<EOF
@define-color theme_selected_bg_color ${COLOURS[accent]};
@define-color theme_selected_fg_color ${COLOURS[onAccent]};

*:selected,
*:selected:focus,
selection {
    background-color: @theme_selected_bg_color;
    color: @theme_selected_fg_color;
}
EOF
}

write_gtk4_css() {
    replace_with_regular_file "${GTK4_CSS}"
    cat >"${GTK4_CSS}" <<EOF
@define-color accent_bg_color ${COLOURS[accent]};
@define-color accent_fg_color ${COLOURS[onAccent]};
@define-color accent_color ${COLOURS[accentSoft]};

selection {
    background-color: @accent_bg_color;
    color: @accent_fg_color;
}
EOF
}

write_gtk_settings() {
    replace_with_regular_file "$1"
    cat >"$1" <<EOF
[Settings]
gtk-font-name=${FONTS[ui]} ${GTK_FONT_POINTS}
gtk-icon-theme-name=${GTK_ICON_THEME}
gtk-theme-name=${GTK_THEME_NAME}
gtk-application-prefer-dark-theme=$(gtk_prefers_dark)
EOF
}

# What the portal reads and hands to GTK 4, and what GTK 3 reads
# directly. Both toolkits ask here before they ask settings.ini.
announce_appearance() {
    command -v gsettings >/dev/null 2>&1 || return 0
    local -a appearance=(
        "font-name:${FONTS[ui]} ${GTK_FONT_POINTS}"
        "icon-theme:${GTK_ICON_THEME}"
        "gtk-theme:${GTK_THEME_NAME}"
        "color-scheme:$(colour_scheme)"
    )
    local entry
    for entry in "${appearance[@]}"; do
        gsettings set org.gnome.desktop.interface \
            "${entry%%:*}" "${entry#*:}" >/dev/null 2>&1 || true
    done
}

apply_gtk() {
    write_gtk3_css
    write_gtk4_css
    write_gtk_settings "${GTK3_SETTINGS}"
    write_gtk_settings "${GTK4_SETTINGS}"
    announce_appearance
}
