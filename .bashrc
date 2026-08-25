# shellcheck shell=bash

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"

export EDITOR=nvim
export VISUAL=nvim
export PAGER=most
GPG_TTY="$(tty)"
export GPG_TTY

export GNUPGHOME="$XDG_DATA_HOME/gnupg"
export NPM_CONFIG_CACHE="$XDG_CACHE_HOME/npm"

# gpg-agent serves SSH too, and a terminal started by the
# compositor never sees ~/.config/environment.d. The socket
# path derives from GNUPGHOME, so that has to be set first.
if command -v gpgconf >/dev/null 2>&1; then
    SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
    export SSH_AUTH_SOCK
fi

export PATH="$PATH:$HOME/.local/bin"

export HISTFILE="$XDG_STATE_HOME/bash/history"
[ -d "${HISTFILE%/*}" ] || mkdir -p "${HISTFILE%/*}"
export HISTSIZE=100000
export HISTFILESIZE=100000
export HISTCONTROL=ignoreboth
shopt -s histappend

# PackageKit's handler blocks on a D-Bus package search before the
# shell will print "command not found".
unset -f command_not_found_handle

prompt_supports_truecolor() {
    case "${COLORTERM:-}" in
        truecolor | 24bit) return 0 ;;
    esac
    return 1
}

prompt_hex_rgb() {
    local hex="${1#\#}"
    printf '%d %d %d' \
        "$((16#${hex:0:2}))" "$((16#${hex:2:2}))" "$((16#${hex:4:2}))"
}

prompt_colour() {
    local -a rgb
    read -r -a rgb <<<"$(prompt_hex_rgb "$1")"
    printf '\\[\\e[38;2;%s;%s;%sm\\]' \
        "${rgb[0]}" "${rgb[1]}" "${rgb[2]}"
}

prompt_build_ps1() {
    local theme_file="${XDG_STATE_HOME}/donbox/current/theme"
    theme_file+="/shell-colours.sh"
    local accent=DC6F00 muted=C0C0C0 on_background=E7E7E7

    if [[ -r "${theme_file}" ]]; then
        local THEME_ACCENT='' THEME_FG_DIM='' THEME_FG=''
        # shellcheck disable=SC1090
        source "${theme_file}"
        accent="${THEME_ACCENT:-${accent}}"
        muted="${THEME_FG_DIM:-${muted}}"
        on_background="${THEME_FG:-${on_background}}"
    fi

    if ! prompt_supports_truecolor; then
        PS1='\u \W\n\$ '
        return
    fi

    PS1="$(prompt_colour "${accent}")\u "
    PS1+="$(prompt_colour "${muted}")\W\n"
    PS1+="$(prompt_colour "${on_background}")\\$ \[\e[0m\]"
}

PROMPT_COMMAND=prompt_build_ps1

alias ..="cd .."
alias 2..="cd ../.."
alias 3..="cd ../../.."
alias 4..="cd ../../../.."
alias 5..="cd ../../../../.."
alias ls="lsd"
alias ll="lsd -lah"
alias claude="claude --dangerously-skip-permissions"
llf () {
    lsd -la --blocks permission,user,group,size,date,name \
        --date $'+%Y-%m-%d \e[38;5;103m%H:%M:%S\e[0m' "$@"
}
alias cp="cp -i"
alias df="df -h"
alias vim="nvim"
alias v="nvim"
alias m="weremutt"

export ANSIBLE_CONFIG="$XDG_CONFIG_HOME/ansible/ansible.cfg"
export ANSIBLE_HOME="$XDG_DATA_HOME/ansible"
export ANSIBLE_LOCAL_TEMP="$XDG_CACHE_HOME/ansible/tmp"
export ANSIBLE_SSH_CONTROL_PATH_DIR="$XDG_CACHE_HOME/ansible/cp"
export ANSIBLE_GALAXY_CACHE_DIR="$XDG_CACHE_HOME/ansible/galaxy_cache"

export CLAUDE_CONFIG_DIR="$XDG_DATA_HOME/claude"

export GOPATH="$XDG_DATA_HOME/go"

export PYTHON_HISTORY="$XDG_STATE_HOME/python/history"
[ -d "${PYTHON_HISTORY%/*}" ] || mkdir -p "${PYTHON_HISTORY%/*}"

export W3M_DIR="$XDG_STATE_HOME/w3m"

eval "$(thefuck --alias)"
# >>> donbox theme >>>
__donbox_theme_file="/home/user/.local/state/donbox/current/theme/shell-colours.sh"
__donbox_theme_refresh() {
    local stamp
    stamp=$(stat -c %Y "${__donbox_theme_file}" 2>/dev/null)
    [ "${stamp}" = "${__donbox_theme_stamp:-}" ] && return 0
    __donbox_theme_stamp="${stamp}"
    [ -r "${__donbox_theme_file}" ] &&
        . "${__donbox_theme_file}"
}
__donbox_theme_refresh
case "${PROMPT_COMMAND:-}" in
*__donbox_theme_refresh*) ;;
*) PROMPT_COMMAND="__donbox_theme_refresh${PROMPT_COMMAND:+; ${PROMPT_COMMAND}}" ;;
esac
# <<< donbox theme <<<
