# shellcheck shell=bash
# shellcheck disable=SC1090,SC1091

bleopt exec_errexit_mark=
bleopt exec_elapsed_mark=
bleopt exec_exit_mark=
bleopt edit_marker=
bleopt edit_marker_error=
bleopt prompt_eol_mark=$'\e[2m⏎\e[m'

bleopt default_keymap=vi

# DECSCUSR shapes: 1 blinking block, 3 blinking underline, 5
# blinking bar.
readonly -a BLESH_VI_CURSORS=(
    "vi_imap:5"
    "vi_nmap:1"
    "vi_omap:3"
    "vi_xmap:1"
    "vi_smap:1"
    "vi_cmap:5"
)

blesh_vi_setup() {
    local entry
    for entry in "${BLESH_VI_CURSORS[@]}"; do
        ble-bind -m "${entry%%:*}" --cursor "${entry#*:}"
    done
    bleopt keymap_vi_mode_show=
}
blehook/eval-after-load keymap_vi blesh_vi_setup

ble-import -d integration/fzf-completion
ble-import -d integration/fzf-key-bindings

source "${XDG_CONFIG_HOME}/blesh/prompt.sh"

blesh_theme_file="${XDG_STATE_HOME}/theme/blesh-colours.sh"
blesh_theme_stamp=''

blesh_theme_refresh() {
    local stamp
    stamp=$(stat -c %Y "${blesh_theme_file}" 2>/dev/null) || return 0
    [[ ${stamp} == "${blesh_theme_stamp}" ]] && return 0
    blesh_theme_stamp=${stamp}
    source "${XDG_STATE_HOME}/theme/shell-colours.sh"
    source "${blesh_theme_file}"
    prompt_build
}
blehook PRECMD+=blesh_theme_refresh
