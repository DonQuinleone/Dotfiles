function fish_command_not_found --description 'Report an unknown command'
    # The shipped handler blocks on a D-Bus package search first.
    printf "fish: Unknown command: %s\n" (string escape -- $argv[1]) >&2
end
