# Globals
export EDITOR=/usr/bin/nvim
export VISUAL=/usr/bin/nvim
export PAGER="most"
export GPG_TTY=$(tty)
eval $(/opt/homebrew/bin/brew shellenv)
export XDG_CONFIG_HOME=~/.config
export XDG_DATA_HOME=~/.local/share
export BW_SESSION="KWLH2xrtS7c14c++0ae9mwMpvXocZ1qKQFx2v5EOik3NqZdl9mZSkPb+p8TD4l6WlFgB4FxkI0c0hFHX+GSv6w=="

# Prompt
PS1='\[\e[38;5;198m\]\u \[\e[38;5;129m\]\W\n\[\e[97m\]\$ \[\e[0m\]'

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

alias python="python3"
alias p="python3"

alias a2m="AAXtoMP3 --chaptered -e:m4b -c --use-audible-cli-data -t '/Users/joshuaquinlan/Downloads' -s"

alias mutt="neomutt"
alias m="neomutt"

# Secure file redirection
set -o noclobber

# Easy extractor
ex () {
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

lfcd () {
    tmp="$(mktemp)"
    lf -last-dir-path="$tmp" "$@"
        [ -d "$dir" ] && [ "$dir" != "$(pwd)" ] && cd "$dir"
}

# Use fzf
#source /usr/share/fzf/key-bindings.bash
#source /usr/share/fzf/completion.bash

cd
