# shellcheck shell=bash

: "${THEME_ACCENT:=DC6F00}" "${THEME_FG_DIM:=C0C0C0}"

PROMPT_RESET=$'\e[0m'
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

prompt_build() {
    local host=''
    [[ ${SSH_TTY-} || ${SSH_CONNECTION-} ]] && host='@\h'
    if ! prompt_supports_truecolor; then
        PS1="\\u${host} \\W\\n\\$ "
        return
    fi
    PS1="\\[$(prompt_sgr ACCENT)\\]\\u${host} "
    PS1+="\\[$(prompt_sgr FG_DIM)\\]\\W\\[${PROMPT_RESET}\\]\\n"
    PS1+="\\[$(prompt_sgr ACCENT)\\]\\$\\[${PROMPT_RESET}\\] "
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

# The badge in the kitty window corner shows the branch, so it
# is redrawn when the branch under the prompt changes.
prompt_badge_refresh() {
    local branch=''
    [[ ${TMUX_PANE-} ]] || return 0
    prompt_git_head branch || branch=''
    [[ $branch == "${PROMPT_BADGE_SENT-}" ]] && return 0
    PROMPT_BADGE_SENT=$branch
    (tmux-badge "${TMUX_PANE}" >/dev/null 2>&1 &)
}

[[ " ${PROMPT_COMMAND[*]-} " == *" prompt_badge_refresh "* ]] ||
    PROMPT_COMMAND+=(prompt_badge_refresh)
