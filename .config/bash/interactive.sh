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

FZF_WALKER_SKIP=".git,node_modules,target,.cache,claude"
FZF_ALT_C_OPTS="--walker-skip ${FZF_WALKER_SKIP} --walker-root=$HOME"
FZF_ALT_C_OPTS+=" --tmux center,70%,60%"
export FZF_ALT_C_OPTS
export FZF_CTRL_T_OPTS="--walker-skip ${FZF_WALKER_SKIP}"
unset FZF_WALKER_SKIP
command -v fzf >/dev/null 2>&1 && eval "$(fzf --bash)"
