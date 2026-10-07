# shellcheck shell=bash
# shellcheck disable=SC2016,SC2154 # ble.sh owns the hashed names

readonly PROMPT_SLOW_SECONDS=5

readonly -A PROMPT_SIGNS=(
    ["vi_imap"]="ACCENT:❯"
    ["vi_nmap"]="FG_DIM:❱"
    ["vi_omap"]="FG_DIM:❱"
    ["vi_xmap"]="WARN:❱"
    ["vi_smap"]="WARN:❱"
    ["vi_cmap"]="ACCENT:❯"
)

prompt_command_started=''
prompt_last_duration=''

prompt_role_colour() {
    local -n hex="THEME_$1"
    printf '\\g{fg=#%s}' "${hex}"
}

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

function ble/prompt/backslash:duration {
    ble/prompt/unit/add-hash '$prompt_last_duration'
    [[ ${prompt_last_duration} ]] || return 0
    ble/prompt/process-prompt-string \
        "$(prompt_role_colour WARN)${prompt_last_duration} "
}

function ble/prompt/backslash:sign {
    ble/prompt/unit/add-hash \
        '$_ble_decode_keymap,${_ble_decode_keymap_stack[*]}'
    local keymap sign='FG:$'
    for keymap in "${_ble_decode_keymap}" \
        "${_ble_decode_keymap_stack[@]}"; do
        [[ ${keymap} && -v PROMPT_SIGNS[${keymap}] ]] || continue
        sign=${PROMPT_SIGNS[${keymap}]}
        break
    done
    ble/prompt/process-prompt-string \
        "$(prompt_role_colour "${sign%%:*}")${sign#*:}\\g{none}"
}

prompt_build() {
    local host=''
    [[ ${SSH_TTY-} || ${SSH_CONNECTION-} ]] && host='@\h'
    PS1="$(prompt_role_colour ACCENT)\\u${host} "
    PS1+="$(prompt_role_colour FG_DIM)\\W\\g{none}\\n\\q{sign} "
    local right
    right="\\q{duration}$(prompt_role_colour FG_DIM)\\A\\g{none}"
    bleopt prompt_rps1="${right}"
    bleopt prompt_ps1_transient=trim
    bleopt prompt_rps1_transient=1
}
