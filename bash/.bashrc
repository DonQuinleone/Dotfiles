# Globals
export EDITOR=/usr/bin/nvim
export VISUAL=/usr/bin/nvim
export PAGER="most"
export GPG_TTY=$(tty)

# Prompt
export PS1="\[\033[38;5;11m\]\u\[$(tput sgr0)\]@\h:\[$(tput sgr0)\]\[\033[38;5;6m\][\W]\[$(tput sgr0)\]: \[$(tput sgr0)\]"

# Aliases -> navigation
alias cp="cp -i"                               
alias df="df -h"   
alias free="free -m"
alias vim="nvim"
alias v="nvim"
alias ..="cd .."
alias 2..="cd ../.."
alias 3..="cd ../../.."
alias 4..="cd ../../../.."
alias 5..="cd ../../../../.."
alias ls="exa"

if [ -f /bin/netcat ]; then
  alias termbin="nc termbin.com 9999"
fi

alias c="cal"
alias cal="cs; ikhal; cs; clear"
alias cs="vdirsyncer sync"
alias con="khard"

alias a2m="AAXtoMP3 --chaptered -e:mp3 -c --use-audible-cli-data --level 3"

alias mutt="neomutt"
alias m="neomutt"

# Secure file redirection
set -o noclobber

# Easy extractor
ex ()
{
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1   ;;
      *.tar.gz)    tar xzf $1   ;;
      *.bz2)       bunzip2 $1   ;;
      *.rar)       unrar x $1     ;;
      *.gz)        gunzip $1    ;;
      *.tar)       tar xf $1    ;;
      *.tbz2)      tar xjf $1   ;;
      *.tgz)       tar xzf $1   ;;
      *.zip)       unzip $1     ;;
      *.Z)         uncompress $1;;
      *.7z)        7z x $1      ;;
      *)           echo "'$1' cannot be extracted via ex()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# Use fzf
source /usr/share/fzf/key-bindings.bash
source /usr/share/fzf/completion.bash

export PATH=~/.local/bin:~/.emacs.d/bin/doom:~/.bin:$PATH
cd
