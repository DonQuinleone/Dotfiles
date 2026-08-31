# shellcheck shell=bash

readonly GTK_PORTAL_UNIT=xdg-desktop-portal-gtk.service
readonly GTK_PORTAL_DROP_IN=theme.conf

readonly APPEARANCE_SCHEMA=org.gnome.desktop.interface

colour_scheme() {
    printf 'prefer-%s\n' "${TOKENS[mode]}"
}

# What the portal reads and hands to GTK 4, and what GTK 3 reads
# directly. Both toolkits ask here before they ask settings.ini,
# so this is what carries light and dark to everything that is
# not rendered from a template.
announce_appearance() {
    command -v gsettings >/dev/null 2>&1 || return 0
    local -a appearance=(
        "font-name:${FONT_UI} ${GTK_FONT_POINTS}"
        "icon-theme:${ICON_THEME}"
        "gtk-theme:${GTK_THEME_NAME}"
        "color-scheme:$(colour_scheme)"
    )
    local entry
    for entry in "${appearance[@]}"; do
        gsettings set "${APPEARANCE_SCHEMA}" "${entry%%:*}" \
            "${entry#*:}" >/dev/null 2>&1 || true
    done
}

gtk_theme_variant() {
    [[ ${TOKENS[mode]} == dark ]] || {
        printf '%s\n' "${GTK_THEME_NAME}"
        return
    }
    printf '%s:dark\n' "${GTK_THEME_NAME}"
}

# GTK 3 asks the settings portal which theme to wear, and
# xdg-desktop-portal-gtk is that portal, so it has nobody to ask
# and falls back to stock light Adwaita however settings.ini
# reads. Naming the variant outright through the unit's own
# environment is what reaches it, and the file chooser it draws
# is the only GTK 3 window most applications ever show.
#
# A toolkit reads its theme once, at startup, so the portal is
# restarted rather than signalled. It is stateless and comes back
# on the next request whether or not it is running now.
publish_gtk_theme() {
    command -v systemctl >/dev/null 2>&1 || return 0
    local runtime=${XDG_RUNTIME_DIR:-/run/user/$(id -u)}
    local drop_in=${runtime}/systemd/user/${GTK_PORTAL_UNIT}.d
    mkdir -p "${drop_in}" 2>/dev/null || return 0
    printf '[Service]\nEnvironment=GTK_THEME=%s\n' \
        "$(gtk_theme_variant)" >"${drop_in}/${GTK_PORTAL_DROP_IN}"
    systemctl --user unset-environment GTK_THEME >/dev/null 2>&1 || true
    systemctl --user daemon-reload >/dev/null 2>&1 || true
    systemctl --user try-restart "${GTK_PORTAL_UNIT}" \
        >/dev/null 2>&1 || true
}
