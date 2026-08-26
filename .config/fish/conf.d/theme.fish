set -g __theme_dir "$XDG_STATE_HOME/theme"
set -g __theme_file $__theme_dir/shell-colours.fish

function __theme_load
    test -r $__theme_file
    and source $__theme_file
    # fzf's options are rendered as a POSIX assignment, which
    # fish cannot read, so the shell that can is asked for it.
    set -l options $__theme_dir/fzf-opts.sh
    set -l extract '. "$1"; printf %s "$FZF_THEME_OPTS"'
    test -r $options
    and set -gx FZF_DEFAULT_OPTS (bash -c $extract _ $options)
end

# A theme switch re-renders the palette while running sessions
# keep the colours they started with, so each prompt checks the
# render's timestamp and reloads when it has moved.
function __theme_refresh --on-event fish_prompt
    set -l stamp (stat -c %Y $__theme_file 2>/dev/null)
    test "$stamp" = "$__theme_stamp"
    and return
    set -g __theme_stamp $stamp
    __theme_load
end

__theme_refresh
