function fish_prompt --description 'User, directory, sign'
    set -l accent DC6F00
    set -l muted C0C0C0
    set -l on_background E7E7E7

    set -l generated "$XDG_STATE_HOME/donbox/current"
    set -l theme_file "$generated/shell-colours.fish"
    test -r $theme_file
    and source $theme_file

    set -q THEME_ACCENT
    and set accent $THEME_ACCENT
    set -q THEME_FG_DIM
    and set muted $THEME_FG_DIM
    set -q THEME_FG
    and set on_background $THEME_FG

    set -l working_directory (path basename $PWD)
    test $PWD = $HOME
    and set working_directory '~'

    set_color $accent
    echo -n "$USER "
    set_color $muted
    echo $working_directory
    set_color $on_background
    echo -n '$ '
    set_color normal
end
