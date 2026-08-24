set -gx XDG_CONFIG_HOME $HOME/.config
set -gx XDG_DATA_HOME $HOME/.local/share
set -gx XDG_CACHE_HOME $HOME/.cache
set -gx XDG_STATE_HOME $HOME/.local/state

set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx PAGER most

set -gx GNUPGHOME $XDG_DATA_HOME/gnupg
set -gx NPM_CONFIG_CACHE $XDG_CACHE_HOME/npm

# The session names the keyring's agent in SSH_AUTH_SOCK, and
# its keys answer without a passphrase. A bare tty has no
# session to inherit it from, so gpg-agent's ssh support stands
# in there; its socket path derives from GNUPGHOME, set above.
if not set -q SSH_AUTH_SOCK; and command -q gpgconf
    set -gx SSH_AUTH_SOCK (gpgconf --list-dirs agent-ssh-socket)
end

# fish_add_path defaults to a universal variable, which would persist
# in fish_variables outside this repository.
fish_add_path --global --path --append $HOME/.local/bin

set -gx ANSIBLE_CONFIG $XDG_CONFIG_HOME/ansible/ansible.cfg
set -gx ANSIBLE_HOME $XDG_DATA_HOME/ansible
set -gx ANSIBLE_LOCAL_TEMP $XDG_CACHE_HOME/ansible/tmp
set -gx ANSIBLE_SSH_CONTROL_PATH_DIR $XDG_CACHE_HOME/ansible/cp
set -gx ANSIBLE_GALAXY_CACHE_DIR $XDG_CACHE_HOME/ansible/galaxy_cache

set -gx CLAUDE_CONFIG_DIR $XDG_DATA_HOME/claude
set -gx GOPATH $XDG_DATA_HOME/go
set -gx W3M_DIR $XDG_STATE_HOME/w3m

set -gx PYTHON_HISTORY $XDG_STATE_HOME/python/history
set -l python_history_directory (path dirname $PYTHON_HISTORY)
test -d $python_history_directory
or mkdir -p $python_history_directory
