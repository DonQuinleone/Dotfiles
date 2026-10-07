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
# Alt-C offers zoxide's most-visited directories first, then
# everything visible under home and the dotfiles.
# shellcheck disable=SC2089,SC2090 # fzf hands the string to sh
export FZF_ALT_C_COMMAND="{ zoxide query -l 2>/dev/null; \
    find ~ ~/.dotfiles -mindepth 1 \
    \\( -name '.*' -o -name node_modules \\) \
    -prune -o -type d -print; } | awk '!seen[\$0]++'"
export FZF_ALT_C_OPTS="--tmux center,70%,60%"
export FZF_CTRL_T_OPTS="--walker-skip ${FZF_WALKER_SKIP}"
unset FZF_WALKER_SKIP
command -v fzf >/dev/null 2>&1 && eval "$(fzf --bash)"
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init bash)"
