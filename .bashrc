# shellcheck shell=bash
# shellcheck source-path=SCRIPTDIR

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"

BASH_CONFIG="$XDG_CONFIG_HOME/bash"

# shellcheck source=.config/bash/environment.sh
source "$BASH_CONFIG/environment.sh"

[[ $- == *i* ]] || return

# ble.sh asks to be loaded before the rest of an interactive
# setup and attached after it.
BLESH="$HOME/.local/opt/blesh/ble.sh"
if [[ -r "$BLESH" ]]; then
    # shellcheck disable=SC1090
    source -- "$BLESH" --attach=none \
        --rcfile "$XDG_CONFIG_HOME/blesh/init.sh"
fi

for module in interactive aliases prompt theme; do
    # shellcheck disable=SC1090
    source "$BASH_CONFIG/$module.sh"
done
unset module

[[ ! ${BLE_VERSION-} ]] || ble-attach
