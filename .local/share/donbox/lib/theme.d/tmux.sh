# shellcheck shell=bash

readonly TMUX_THEME_FILE="${CONFIG_HOME}/tmux/theme.conf"

write_tmux_theme() {
    cat >"${TMUX_THEME_FILE}" <<EOF
set -g status-style "bg=${COLOURS[bgAlt]},fg=${COLOURS[fgDim]}"
set -g status-left-style "bg=${COLOURS[accent]},fg=${COLOURS[onAccent]},bold"
set -g status-right-style "bg=${COLOURS[bgAlt]},fg=${COLOURS[fgDim]}"
set -g window-status-current-style "bg=${COLOURS[surface]},fg=${COLOURS[fg]},bold"
set -g window-status-style "bg=${COLOURS[bgAlt]},fg=${COLOURS[fgDim]}"
set -g window-status-activity-style "fg=${COLOURS[warn]}"
set -g window-status-bell-style "fg=${COLOURS[bad]}"
set -g pane-border-style "fg=${COLOURS[border]}"
set -g pane-active-border-style "fg=${COLOURS[accent]}"
set -g message-style "bg=${COLOURS[surface]},fg=${COLOURS[fg]}"
set -g message-command-style "bg=${COLOURS[surface]},fg=${COLOURS[fg]}"
set -g mode-style "bg=${COLOURS[accent]},fg=${COLOURS[onAccent]}"
set -g copy-mode-match-style "bg=${COLOURS[warn]},fg=${COLOURS[onWarn]}"
set -g copy-mode-current-match-style "bg=${COLOURS[accent]},fg=${COLOURS[onAccent]}"
set -g clock-mode-colour "${COLOURS[accent]}"
EOF
}

apply_tmux() {
    command -v tmux >/dev/null 2>&1 || return 0
    mkdir -p "$(dirname "${TMUX_THEME_FILE}")"
    write_tmux_theme
    tmux list-sessions >/dev/null 2>&1 || return 0
    tmux source-file "${TMUX_THEME_FILE}" >/dev/null 2>&1 || true
}
