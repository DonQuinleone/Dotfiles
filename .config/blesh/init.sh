# shellcheck shell=bash
# shellcheck disable=SC1091

bleopt exec_errexit_mark=
bleopt exec_elapsed_mark=
bleopt exec_exit_mark=
bleopt edit_marker=
bleopt edit_marker_error=
bleopt prompt_eol_mark=$'\e[2m⏎\e[m'

bleopt default_keymap=vi
bind 'set keyseq-timeout 1'

# DECSCUSR shapes: 1 blinking block, 2 steady block.
readonly -a BLESH_VI_CURSORS=(
    "vi_imap:1"
    "vi_cmap:1"
    "vi_nmap:2"
    "vi_omap:2"
    "vi_xmap:2"
    "vi_smap:2"
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
