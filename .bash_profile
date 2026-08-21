# shellcheck shell=bash
# shellcheck source-path=SCRIPTDIR

if [ -f ~/.bashrc ]; then
    # shellcheck source=.bashrc
    . ~/.bashrc
fi

# start-hyprland execs a login shell to collect the environment
# before launching the compositor. Defaults if unset: theme
# "default", size 24.
export XCURSOR_THEME=Adwaita
export XCURSOR_SIZE=48
