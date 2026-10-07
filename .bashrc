# shellcheck shell=bash

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"

# Loaded first and attached last, as ble.sh asks, so everything
# between is in place before it takes over the line.
BLESH="$HOME/.local/opt/blesh/ble.sh"
if [[ $- == *i* && -r "$BLESH" ]]; then
    # shellcheck disable=SC1090
    source -- "$BLESH" --attach=none \
        --rcfile "$XDG_CONFIG_HOME/blesh/init.sh"
fi

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
    local theme_file="${XDG_STATE_HOME}/theme"
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

[[ ${BLE_VERSION-} ]] || PROMPT_COMMAND=prompt_build_ps1

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
export PATH="$GOPATH/bin:$PATH"

export PYTHON_HISTORY="$XDG_STATE_HOME/python/history"
[ -d "${PYTHON_HISTORY%/*}" ] || mkdir -p "${PYTHON_HISTORY%/*}"

export W3M_DIR="$XDG_STATE_HOME/w3m"

# newt's built-in palette is a fixed blue-on-lightgray. These
# ANSI names resolve through the terminal palette, so nmtui and
# whiptail follow the active theme.
export NEWT_COLORS='root=lightgray,black
border=brown,black
window=lightgray,black
shadow=black,black
title=brown,black
button=black,brown
actbutton=black,brown
compactbutton=lightgray,black
checkbox=lightgray,black
actcheckbox=black,brown
entry=lightgray,black
disentry=gray,black
label=lightgray,black
listbox=lightgray,black
actlistbox=black,brown
sellistbox=brown,black
actsellistbox=black,brown
textbox=lightgray,black
acttextbox=black,brown
helpline=lightgray,black
roottext=gray,black
emptyscale=lightgray,black
fullscale=black,brown'

eval "$(thefuck --alias)"
# >>> theme >>>
__theme_file="/home/user/.local/state/theme/shell-colours.sh"
__theme_refresh() {
    local stamp
    stamp=$(stat -c %Y "${__theme_file}" 2>/dev/null)
    [ "${stamp}" = "${__theme_stamp:-}" ] && return 0
    __theme_stamp="${stamp}"
    # shellcheck disable=SC1090,SC1091
    [ -r "${__theme_file}" ] &&
        . "${__theme_file}"
    [ -r "${__theme_file%/*}/fzf-opts.sh" ] || return 0
    # shellcheck disable=SC1091
    . "${__theme_file%/*}/fzf-opts.sh"
    export FZF_DEFAULT_OPTS="${FZF_THEME_OPTS}"
}
__theme_refresh
case "${PROMPT_COMMAND:-}" in
*__theme_refresh*) ;;
*) PROMPT_COMMAND="__theme_refresh${PROMPT_COMMAND:+; ${PROMPT_COMMAND}}" ;;
esac
# <<< theme <<<

[[ ! ${BLE_VERSION-} ]] || ble-attach
