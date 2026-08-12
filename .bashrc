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

export PATH="$PATH:$HOME/.local/bin"

export HISTFILE="$XDG_STATE_HOME/bash/history"
[ -d "${HISTFILE%/*}" ] || mkdir -p "${HISTFILE%/*}"
export HISTSIZE=100000
export HISTFILESIZE=100000
export HISTCONTROL=ignoreboth
shopt -s histappend

prompt_accent='\[\e[38;2;220;111;0m\]'
prompt_muted='\[\e[38;2;192;192;192m\]'
prompt_on_background='\[\e[38;2;231;231;231m\]'
prompt_reset='\[\e[0m\]'
PS1="${prompt_accent}\u ${prompt_muted}\W\n"
PS1+="${prompt_on_background}\\$ ${prompt_reset}"
unset prompt_accent prompt_muted prompt_on_background prompt_reset

alias ..="cd .."
alias 2..="cd ../.."
alias 3..="cd ../../.."
alias 4..="cd ../../../.."
alias 5..="cd ../../../../.."
alias ls="lsd"
alias ll="lsd -lah" 
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

# Claude Code
export CLAUDE_CONFIG_DIR="$XDG_DATA_HOME/claude"

# Go
export GOPATH="$XDG_DATA_HOME/go"

# Python
export PYTHON_HISTORY="$XDG_STATE_HOME/python/history"
[ -d "${PYTHON_HISTORY%/*}" ] || mkdir -p "${PYTHON_HISTORY%/*}"

# w3m
export W3M_DIR="$XDG_STATE_HOME/w3m"
