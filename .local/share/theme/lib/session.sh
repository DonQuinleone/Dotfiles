# shellcheck shell=bash

readonly GREETER_DIR=/var/lib/greeter-theme
readonly GREETER_STYLE=${GREETER_DIR}/style.css
readonly GREETER_BACKGROUND=${GREETER_DIR}/background

readonly -a TEAMSPEAK_LINKS=(
    "teamspeak.qss:current.qss"
    "teamspeak-chat.qss:current_chat.qss"
)

# waybar has no reload signal: SIGUSR2 and SIGHUP both kill
# it, so the units are restarted instead of signalled.
readonly -a RELOADS=(
    "makoctl:makoctl reload"
    "hyprctl:hyprctl reload"
    "kitty:pkill -SIGUSR1 kitty"
    "tmux:tmux source-file ${RENDERED}/tmux.conf"
    "tmux-badge:tmux-badge all"
    "waybar:systemctl --user restart waybar.target"
)

# TeamSpeak reads its stylesheet once at start, so there is no
# reload entry for it; a switch shows on its next launch.
apply_teamspeak() {
    local styles=${HOME}/.local/opt/teamspeak3/styles entry source
    [[ -d $styles ]] || return 0
    for entry in "${TEAMSPEAK_LINKS[@]}"; do
        source=${RENDERED}/${entry%%:*}
        [[ -f $source ]] || continue
        link_file "${source}" "${styles}/${entry#*:}"
    done
}

# The greeter runs as its own user and cannot reach this
# account's home, so its stylesheet and background are copied
# where it can read them; the install step hands this account
# ownership of that directory, and a switch is a no-op
# without it.
apply_greeter() {
    [[ -w $GREETER_DIR ]] || return 0
    local chosen=${RENDERED}/wallpaper image
    [[ -f ${RENDERED}/gtkgreet.css ]] &&
        cp -- "${RENDERED}/gtkgreet.css" "${GREETER_STYLE}"
    [[ -f $chosen ]] || return 0
    image=$(<"${chosen}")
    [[ -f $image ]] || return 0
    cp -- "${image}" "${GREETER_BACKGROUND}"
}

follow_wallpaper() {
    command -v wallpaper >/dev/null 2>&1 || return 0
    wallpaper theme >/dev/null 2>&1 || true
}

reload_live() {
    local entry
    for entry in "${RELOADS[@]}"; do
        command -v "${entry%%:*}" >/dev/null 2>&1 || continue
        # shellcheck disable=SC2086 # the table holds argument lists
        ${entry#*:} >/dev/null 2>&1 || true
    done
}
