# shellcheck shell=bash

THEME_DIR="$XDG_STATE_HOME/theme"
theme_stamp=''

theme_load() {
    # shellcheck disable=SC1091
    source "$THEME_DIR/shell-colours.sh"
    if [[ -r "$THEME_DIR/fzf-opts.sh" ]]; then
        # shellcheck disable=SC1091
        source "$THEME_DIR/fzf-opts.sh"
        export FZF_DEFAULT_OPTS="$FZF_THEME_OPTS"
    fi
}

# A theme switch re-renders the palette while running shells
# keep the colours they started with, so each prompt checks the
# render's timestamp and reloads when it has moved.
theme_refresh() {
    local stamp
    stamp=$(stat -c %Y "$THEME_DIR/shell-colours.sh" 2>/dev/null) ||
        stamp=none
    [[ $stamp == "$theme_stamp" ]] && return 0
    theme_stamp=$stamp
    [[ $stamp == none ]] || theme_load
    prompt_build
}

theme_refresh
[[ " ${PROMPT_COMMAND[*]-} " == *" theme_refresh "* ]] ||
    PROMPT_COMMAND+=(theme_refresh)
