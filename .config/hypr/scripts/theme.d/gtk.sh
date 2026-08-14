# shellcheck shell=bash

readonly GTK3_CSS="${CONFIG_HOME}/gtk-3.0/gtk.css"
readonly GTK4_CSS="${CONFIG_HOME}/gtk-4.0/gtk.css"
readonly GTK3_SETTINGS="${CONFIG_HOME}/gtk-3.0/settings.ini"
readonly GTK4_SETTINGS="${CONFIG_HOME}/gtk-4.0/settings.ini"

# Application text stays at a sighted reader's size on purpose:
# the magnifier does the enlarging, and inflating it here would
# only cut how much text fits under the lens.
readonly GTK_FONT_POINTS=10

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
EOF
}

announce_gtk_font() {
    command -v gsettings >/dev/null 2>&1 || return 0
    gsettings set org.gnome.desktop.interface font-name \
        "${FONTS[ui]} ${GTK_FONT_POINTS}" >/dev/null 2>&1 || true
}

apply_gtk() {
    write_gtk3_css
    write_gtk4_css
    write_gtk_settings "${GTK3_SETTINGS}"
    write_gtk_settings "${GTK4_SETTINGS}"
    announce_gtk_font
}
