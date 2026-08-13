function fish_prompt --description 'User, working directory, prompt sign'
    set -l accent DC6F00
    set -l muted C0C0C0
    set -l on_background E7E7E7

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
