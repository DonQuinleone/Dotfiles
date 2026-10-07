# shellcheck shell=bash

: "${THEME_ACCENT:=DC6F00}" "${THEME_FG_DIM:=C0C0C0}"

PROMPT_RESET=$'\e[0m'
PROMPT_HIDE=$'\001'
PROMPT_SHOW=$'\002'
PROMPT_GIT_ICON=''
PROMPT_GIT_HASH_LENGTH=7

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

prompt_hidden_sgr() {
    printf '%s%s%s' \
        "${PROMPT_HIDE}" "$(prompt_sgr "$1")" "${PROMPT_SHOW}"
}

# Reads HEAD itself: asking git costs a fork and about twenty
# milliseconds on every prompt.
# shellcheck disable=SC2034
prompt_git_head() {
    local -n found=$1
    local dir=$PWD git ref
    while :; do
        git=$dir/.git
        if [[ -f $git ]]; then
            read -r git <"$git"
            git=${git#gitdir: }
            [[ $git == /* ]] || git=$dir/$git
        fi
        [[ -f $git/HEAD ]] && break
        [[ $dir ]] || return 1
        dir=${dir%/*}
    done
    read -r ref <"$git/HEAD"
    found=${ref:0:PROMPT_GIT_HASH_LENGTH}
    [[ $ref == ref:\ refs/heads/* ]] &&
        found=${ref#ref: refs/heads/}
    return 0
}

prompt_git_refresh() {
    local branch
    PROMPT_GIT=''
    prompt_git_head branch || return 0
    PROMPT_GIT="${PROMPT_GIT_STYLE_ICON} ${PROMPT_GIT_ICON} "
    PROMPT_GIT+="${PROMPT_GIT_STYLE_TEXT}${branch}"
}

prompt_build() {
    local host=''
    [[ ${SSH_TTY-} || ${SSH_CONNECTION-} ]] && host='@\h'
    PROMPT_GIT_STYLE_ICON=''
    PROMPT_GIT_STYLE_TEXT=''
    if ! prompt_supports_truecolor; then
        PS1="\\u${host} \\W\${PROMPT_GIT}\\n\\$ "
        return
    fi
    PROMPT_GIT_STYLE_ICON=$(prompt_hidden_sgr ACCENT)
    PROMPT_GIT_STYLE_TEXT=$(prompt_hidden_sgr FG_DIM)
    PS1="\\[$(prompt_sgr ACCENT)\\]\\u${host} "
    PS1+="\\[$(prompt_sgr FG_DIM)\\]\\W\${PROMPT_GIT}"
    PS1+="\\[${PROMPT_RESET}\\]\\n"
    PS1+="\\[$(prompt_sgr ACCENT)\\]\\$\\[${PROMPT_RESET}\\] "
}

[[ " ${PROMPT_COMMAND[*]-} " == *" prompt_git_refresh "* ]] ||
    PROMPT_COMMAND+=(prompt_git_refresh)
