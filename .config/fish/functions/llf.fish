function llf --description 'Long listing with a seconds-precision time'
    # fish has no ANSI-C quoting, so the escapes are built by printf.
    set -l timestamp (printf '\e[38;5;103m')
    set -l reset (printf '\e[0m')

    lsd -la --blocks permission,user,group,size,date,name \
        --date "+%Y-%m-%d $timestamp%H:%M:%S$reset" $argv
end
