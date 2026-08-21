# shellcheck shell=bash

# Kept in state: stow links the whole tmux directory, so a
# generated file written beside the config lands in the
# repository.
readonly TMUX_THEME_FILE="${STATE_DIR}/tmux-theme.conf"

write_tmux_theme() {
    local accent="${COLOURS[accent]}"
    local on_accent="${COLOURS[onAccent]}"
    local bg_alt="${COLOURS[bgAlt]}" fg_dim="${COLOURS[fgDim]}"
    local surface="${COLOURS[surface]}" fg="${COLOURS[fg]}"
    local warn="${COLOURS[warn]}" on_warn="${COLOURS[onWarn]}"
    local bad="${COLOURS[bad]}" border="${COLOURS[border]}"

    cat >"${TMUX_THEME_FILE}" <<EOF
set -g status-style "bg=${bg_alt},fg=${fg_dim}"
set -g status-left-style "bg=${accent},fg=${on_accent},bold"
set -g status-right-style "bg=${bg_alt},fg=${fg_dim}"
set -g window-status-current-style "bg=${surface},fg=${fg},bold"
set -g window-status-style "bg=${bg_alt},fg=${fg_dim}"
set -g window-status-activity-style "fg=${warn}"
set -g window-status-bell-style "fg=${bad}"
set -g pane-border-style "fg=${border}"
set -g pane-active-border-style "fg=${accent}"
set -g message-style "bg=${surface},fg=${fg}"
set -g message-command-style "bg=${surface},fg=${fg}"
set -g mode-style "bg=${accent},fg=${on_accent}"
set -g copy-mode-match-style "bg=${warn},fg=${on_warn}"
set -g copy-mode-current-match-style "bg=${accent},fg=${on_accent}"
set -g clock-mode-colour "${accent}"
EOF
}

apply_tmux() {
    command -v tmux >/dev/null 2>&1 || return 0
    mkdir -p "$(dirname "${TMUX_THEME_FILE}")"
    write_tmux_theme
    tmux list-sessions >/dev/null 2>&1 || return 0
    tmux source-file "${TMUX_THEME_FILE}" >/dev/null 2>&1 || true
}
