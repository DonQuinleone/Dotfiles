# shellcheck shell=bash

readonly PERCENT=100

readonly LUMA_RED=299
readonly LUMA_GREEN=587
readonly LUMA_BLUE=114
readonly LUMA_TOTAL=1000

# shellcheck disable=SC2034 # the icon ramp reads it
readonly CHANNEL_MAX=255

channel_sum() {
    local bare=${1#\#}
    printf '%d\n' "$(( 0x${bare:0:2} + 0x${bare:2:2}
                     + 0x${bare:4:2} ))"
}

# Weighted the way the drawing is read rather than the way
# contrast is measured: what matters is where a shade sits in
# the ramp, not what it does against a background.
luma() {
    local bare=${1#\#}
    printf '%d\n' "$(( (0x${bare:0:2} * LUMA_RED
                      + 0x${bare:2:2} * LUMA_GREEN
                      + 0x${bare:4:2} * LUMA_BLUE)
                     / LUMA_TOTAL ))"
}

mix() {
    local start=${1#\#} end=${2#\#} amount=$3 scale=${4:-$PERCENT}
    local offset value part blended='#'
    (( amount < 0 )) && amount=0
    (( amount > scale )) && amount=scale
    for offset in 0 2 4; do
        value=$(( ((0x${start:offset:2} * (scale - amount)
                  + 0x${end:offset:2} * amount) * 2 + scale)
                 / (2 * scale) ))
        printf -v part '%02x' "$value"
        blended+=$part
    done
    printf '%s\n' "$blended"
}
