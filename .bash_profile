# shellcheck shell=bash

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
    # shellcheck source=.bashrc
    . ~/.bashrc
fi

# User specific environment and startup programs

# Cursor theme/size for COSMIC. start-cosmic(1) execs a login shell to collect
# the environment before launching cosmic-comp, which reads these two vars.
# Defaults if unset: theme "default", size 24.
export XCURSOR_THEME=Adwaita
export XCURSOR_SIZE=48
