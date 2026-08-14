# shellcheck shell=bash

readonly GTK3_CSS="${CONFIG_HOME}/gtk-3.0/gtk.css"
readonly GTK4_CSS="${CONFIG_HOME}/gtk-4.0/gtk.css"

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

apply_gtk() {
    write_gtk3_css
    write_gtk4_css
}
