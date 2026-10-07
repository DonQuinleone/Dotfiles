# shellcheck shell=bash

GPG_TTY="$(tty)"
export GPG_TTY

export HISTFILE="$XDG_STATE_HOME/bash/history"
[ -d "${HISTFILE%/*}" ] || mkdir -p "${HISTFILE%/*}"
export HISTSIZE=100000
export HISTFILESIZE=100000
export HISTCONTROL=ignoreboth
shopt -s histappend

export INPUTRC="$XDG_CONFIG_HOME/readline/inputrc"

# PackageKit's handler blocks on a D-Bus package search before the
# shell will print "command not found".
unset -f command_not_found_handle

command -v fzf >/dev/null 2>&1 && eval "$(fzf --bash)"
