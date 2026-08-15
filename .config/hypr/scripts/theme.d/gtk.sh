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

# Every surface libadwaita paints, against the palette entry it
# takes. Adwaita ships a complete palette of its own, so a name
# missing here is a surface that keeps the toolkit's grey rather
# than ours, and one missing accent is enough to leave a window
# looking like stock GNOME.
# shellcheck disable=SC2034 # read by name in colour_pairs
readonly -a GTK4_SURFACES=(
    "window_bg_color:bg"
    "window_fg_color:fg"
    "view_bg_color:bgAlt"
    "view_fg_color:fg"
    "headerbar_bg_color:bg"
    "headerbar_fg_color:fg"
    "headerbar_border_color:border"
    "headerbar_backdrop_color:bg"
    "sidebar_bg_color:bgAlt"
    "sidebar_fg_color:fg"
    "sidebar_border_color:border"
    "sidebar_backdrop_color:bg"
    "secondary_sidebar_bg_color:surface"
    "secondary_sidebar_fg_color:fg"
    "secondary_sidebar_border_color:border"
    "secondary_sidebar_backdrop_color:bg"
    "card_bg_color:surface"
    "card_fg_color:fg"
    "thumbnail_bg_color:surface"
    "thumbnail_fg_color:fg"
    "dialog_bg_color:bgAlt"
    "dialog_fg_color:fg"
    "popover_bg_color:surface"
    "popover_fg_color:fg"
    "accent_bg_color:accent"
    "accent_fg_color:onAccent"
    "accent_color:accentSoft"
    "destructive_bg_color:bad"
    "destructive_fg_color:onBad"
    "destructive_color:bad"
    "success_bg_color:good"
    "success_fg_color:onGood"
    "success_color:good"
    "warning_bg_color:warn"
    "warning_fg_color:onWarn"
    "warning_color:warn"
    "borders:border"
)

# shellcheck disable=SC2034 # read by name in colour_pairs
readonly -a GTK3_SURFACES=(
    "theme_bg_color:bg"
    "theme_fg_color:fg"
    "theme_base_color:bgAlt"
    "theme_text_color:fg"
    "theme_selected_bg_color:accent"
    "theme_selected_fg_color:onAccent"
    "theme_unfocused_bg_color:bg"
    "theme_unfocused_fg_color:fg"
    "theme_unfocused_base_color:bgAlt"
    "theme_unfocused_text_color:fg"
    "theme_unfocused_selected_bg_color:accent"
    "theme_unfocused_selected_fg_color:onAccent"
    "insensitive_bg_color:bg"
    "insensitive_fg_color:fgDim"
    "insensitive_base_color:bgAlt"
    "borders:border"
    "unfocused_borders:border"
    "success_color:good"
    "warning_color:warn"
    "error_color:bad"
)

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

colour_pairs() {
    local -n table="$1"
    local entry
    for entry in "${table[@]}"; do
        printf '%s\t%s\n' "${entry%%:*}" \
            "${COLOURS[${entry#*:}]}"
    done
}

emit_define_colours() {
    local name colour
    while IFS=$'\t' read -r name colour; do
        printf '@define-color %s %s;\n' "${name}" "${colour}"
    done
}

emit_css_variables() {
    local name colour
    while IFS=$'\t' read -r name colour; do
        printf '    --%s: %s;\n' "${name//_/-}" "${colour}"
    done
}

write_gtk3_css() {
    replace_with_regular_file "${GTK3_CSS}"
    {
        colour_pairs GTK3_SURFACES | emit_define_colours
        cat <<'EOF'

*:selected,
*:selected:focus,
selection {
    background-color: @theme_selected_bg_color;
    color: @theme_selected_fg_color;
}
EOF
    } >"${GTK3_CSS}"
}

# libadwaita 1.6 moved these to CSS variables and left the old
# spelling deprecated but read, so both go out: the variables are
# what a current libadwaita honours, and the older names are what
# plain GTK 4 applications still look for.
write_gtk4_css() {
    replace_with_regular_file "${GTK4_CSS}"
    {
        printf ':root {\n'
        colour_pairs GTK4_SURFACES | emit_css_variables
        printf '}\n\n'
        colour_pairs GTK4_SURFACES | emit_define_colours
        cat <<'EOF'

selection {
    background-color: @accent_bg_color;
    color: @accent_fg_color;
}
EOF
    } >"${GTK4_CSS}"
}

write_gtk_settings() {
    replace_with_regular_file "$1"
    cat >"$1" <<EOF
[Settings]
gtk-font-name=${FONTS[ui]} ${GTK_FONT_POINTS}
gtk-icon-theme-name=${GTK_ICON_THEME}
gtk-theme-name=${GTK_THEME_NAME}
EOF
}

# libadwaita takes light and dark from color-scheme and warns on
# every launch when it finds this key, so only GTK 3, which has
# no other way to be told, gets it.
write_gtk3_settings() {
    write_gtk_settings "${GTK3_SETTINGS}"
    printf 'gtk-application-prefer-dark-theme=%s\n' \
        "$(gtk_prefers_dark)" >>"${GTK3_SETTINGS}"
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
    write_gtk3_settings
    write_gtk_settings "${GTK4_SETTINGS}"
    announce_appearance
}
