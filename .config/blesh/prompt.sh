# shellcheck shell=bash
# shellcheck disable=SC2016,SC2154 # ble.sh owns the hashed names

readonly PROMPT_SLOW_SECONDS=5

readonly -A PROMPT_MODES=(
    ["vi_imap"]=insert
    ["vi_cmap"]=insert
    ["vi_nmap"]=normal
    ["vi_omap"]=normal
    ["vi_xmap"]=visual
    ["vi_smap"]=visual
)

readonly -A PROMPT_MODE_COLOURS=(
    [insert]=ACCENT
    [normal]=GOOD
    [visual]=WARN
)

declare -A prompt_signs=()
prompt_mode=insert
prompt_reported_colour=''
prompt_duration_sgr=''
prompt_command_started=''
prompt_last_duration=''

prompt_format_duration() {
    local seconds=$1
    (( seconds >= 3600 )) &&
        { printf '%dh%dm' $(( seconds / 3600 )) \
            $(( seconds % 3600 / 60 )); return; }
    (( seconds >= 60 )) &&
        { printf '%dm%ds' $(( seconds / 60 )) $(( seconds % 60 ))
          return; }
    printf '%ds' "${seconds}"
}

prompt_note_start() {
    prompt_command_started=${EPOCHSECONDS}
}

prompt_note_end() {
    prompt_last_duration=''
    [[ ${prompt_command_started} ]] || return 0
    local elapsed=$(( EPOCHSECONDS - prompt_command_started ))
    prompt_command_started=''
    (( elapsed >= PROMPT_SLOW_SECONDS )) || return 0
    prompt_last_duration=$(prompt_format_duration "${elapsed}")
}
blehook PREEXEC+=prompt_note_start
blehook PRECMD+=prompt_note_end

prompt_resolve_mode() {
    local keymap
    prompt_mode=insert
    for keymap in "${_ble_decode_keymap}" \
        "${_ble_decode_keymap_stack[@]}"; do
        [[ ${keymap} && -v PROMPT_MODES[${keymap}] ]] || continue
        prompt_mode=${PROMPT_MODES[${keymap}]}
        return
    done
}

# tmux colours its status bar with the mode as well, so the
# active pane's colour is handed to it whenever the mode moves.
prompt_report_mode() {
    [[ ${TMUX-} ]] || return 0
    local -n hex="THEME_${PROMPT_MODE_COLOURS[${prompt_mode}]}"
    [[ ${hex} != "${prompt_reported_colour}" ]] || return 0
    prompt_reported_colour=${hex}
    tmux set -p @mode_colour "#${hex}" \; refresh-client -S
}

function ble/prompt/backslash:duration {
    ble/prompt/unit/add-hash '$prompt_last_duration'
    [[ ${prompt_last_duration} ]] || return 0
    ble/prompt/print \
        "${prompt_duration_sgr}${prompt_last_duration}${PROMPT_RESET} "
}

function ble/prompt/backslash:sign {
    ble/prompt/unit/add-hash \
        '$_ble_decode_keymap,${_ble_decode_keymap_stack[*]}'
    prompt_resolve_mode
    prompt_report_mode
    ble/prompt/print "${prompt_signs[${prompt_mode}]}"
}

prompt_build_blesh() {
    local mode sign='$'
    (( EUID == 0 )) && sign='#'
    for mode in "${!PROMPT_MODE_COLOURS[@]}"; do
        prompt_signs[${mode}]="$(prompt_sgr \
            "${PROMPT_MODE_COLOURS[${mode}]}")${sign}${PROMPT_RESET}"
    done
    prompt_duration_sgr=$(prompt_sgr WARN)
    prompt_reported_colour=''
    bleopt prompt_rps1="\\q{duration}\\[$(prompt_sgr FG_DIM)\\]\\A"
    bleopt prompt_ps1_transient=trim
    bleopt prompt_rps1_transient=1
}
