# shellcheck shell=bash
# shellcheck source-path=SCRIPTDIR

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"

bash_config="$XDG_CONFIG_HOME/bash"

# shellcheck source=.config/bash/environment.sh
source "$bash_config/environment.sh"

[[ $- == *i* ]] || return

for module in interactive aliases prompt theme; do
    # shellcheck disable=SC1090
    source "$bash_config/$module.sh"
done
unset module bash_config
