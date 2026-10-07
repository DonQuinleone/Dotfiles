# shellcheck shell=bash

export EDITOR=nvim
export VISUAL=nvim
export PAGER=most

export GNUPGHOME="$XDG_DATA_HOME/gnupg"
export NPM_CONFIG_CACHE="$XDG_CACHE_HOME/npm"

# gpg-agent serves SSH too, and a terminal started by the
# compositor never sees ~/.config/environment.d. The socket
# path derives from GNUPGHOME, so that has to be set first.
if command -v gpgconf >/dev/null 2>&1; then
    SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
    export SSH_AUTH_SOCK
fi

export GOPATH="$XDG_DATA_HOME/go"
export PATH="$GOPATH/bin:$PATH:$HOME/.local/bin"

export ANSIBLE_CONFIG="$XDG_CONFIG_HOME/ansible/ansible.cfg"
export ANSIBLE_HOME="$XDG_DATA_HOME/ansible"
export ANSIBLE_LOCAL_TEMP="$XDG_CACHE_HOME/ansible/tmp"
export ANSIBLE_SSH_CONTROL_PATH_DIR="$XDG_CACHE_HOME/ansible/cp"
export ANSIBLE_GALAXY_CACHE_DIR="$XDG_CACHE_HOME/ansible/galaxy_cache"
export ANSIBLE_REMOTE_TEMP="$XDG_CACHE_HOME/ansible/tmp"

export KUBECONFIG="$XDG_CONFIG_HOME/kube/config"
export KUBECACHEDIR="$XDG_CACHE_HOME/kube"

export CLAUDE_CONFIG_DIR="$XDG_DATA_HOME/claude"

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
