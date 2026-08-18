if status is-interactive
    set -g fish_greeting ''
    set -gx GPG_TTY (tty)

    abbr --add .. 'cd ..'
    for depth in 2 3 4 5
        abbr --add "$depth.." "cd "(string repeat -n $depth ../)
    end

    abbr --add ls lsd
    abbr --add ll 'lsd -lah'
    abbr --add cp 'cp -i'
    abbr --add df 'df -h'
    abbr --add vim nvim
    abbr --add v nvim
    abbr --add m weremutt

    command -q fzf
    and fzf --fish | source

    set -l fzf_theme "$XDG_STATE_HOME/theme/fzf-opts"
    test -r $fzf_theme
    and set -gx FZF_DEFAULT_OPTS (cat $fzf_theme)
end
