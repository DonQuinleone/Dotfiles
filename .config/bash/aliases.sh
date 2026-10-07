# shellcheck shell=bash

alias ..="cd .."
alias 2..="cd ../.."
alias 3..="cd ../../.."
alias 4..="cd ../../../.."
alias 5..="cd ../../../../.."
alias ls="lsd"
alias ll="lsd -lah"
alias cp="cp -i"
alias df="df -h"
alias vim="nvim"
alias v="nvim"
alias m="weremutt"
alias claude="claude --dangerously-skip-permissions"

llf() {
    lsd -la --blocks permission,user,group,size,date,name \
        --date $'+%Y-%m-%d \e[38;5;103m%H:%M:%S\e[0m' "$@"
}
