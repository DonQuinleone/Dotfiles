# shellcheck shell=bash

: "${THEME_ACCENT:=DC6F00}" "${THEME_FG_DIM:=C0C0C0}"

readonly PROMPT_RESET=$'\e[0m'

prompt_supports_truecolor() {
    case "${COLORTERM:-}" in
        truecolor | 24bit) return 0 ;;
    esac
    return 1
}

prompt_sgr() {
    local -n hex="THEME_$1"
    printf '\e[38;2;%d;%d;%dm' \
        "0x${hex:0:2}" "0x${hex:2:2}" "0x${hex:4:2}"
}

prompt_build() {
    if ! prompt_supports_truecolor; then
        PS1='\u \W\n\$ '
        return
    fi
    local host=''
    [[ ${SSH_TTY-} || ${SSH_CONNECTION-} ]] && host='@\h'
    PS1="\\[$(prompt_sgr ACCENT)\\]\\u${host} "
    PS1+="\\[$(prompt_sgr FG_DIM)\\]\\W\\[${PROMPT_RESET}\\]\\n"
    PS1+="\\[$(prompt_sgr ACCENT)\\]\\$\\[${PROMPT_RESET}\\] "
}
