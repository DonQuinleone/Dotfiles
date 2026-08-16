# shellcheck shell=bash

readonly CONTRAST_SCALE=100
readonly CONTRAST_MINIMUM=450
readonly CONTRAST_DECIMALS=2

contrast_centis() {
    local -a subject background
    read -r -a subject <<<"$(channels "$1")"
    read -r -a background <<<"$(channels "$2")"
    awk -v scale="${CONTRAST_SCALE}" \
        -v subjectRed="${subject[0]}" \
        -v subjectGreen="${subject[1]}" \
        -v subjectBlue="${subject[2]}" \
        -v backgroundRed="${background[0]}" \
        -v backgroundGreen="${background[1]}" \
        -v backgroundBlue="${background[2]}" '
        function linear(value,    ratio) {
            ratio = value / channelMaximum
            if (ratio <= linearThreshold) {
                return ratio / linearDivisor
            }
            return ((ratio + gammaOffset) / gammaDivisor) \
                ^ gammaExponent
        }
        function luminance(red, green, blue) {
            return redWeight * linear(red) \
                + greenWeight * linear(green) \
                + blueWeight * linear(blue)
        }
        BEGIN {
            channelMaximum = 255
            linearThreshold = 0.04045
            linearDivisor = 12.92
            gammaOffset = 0.055
            gammaDivisor = 1.055
            gammaExponent = 2.4
            redWeight = 0.2126
            greenWeight = 0.7152
            blueWeight = 0.0722
            ambient = 0.05

            lighter = luminance(subjectRed, subjectGreen, subjectBlue)
            darker = luminance(backgroundRed, backgroundGreen,
                backgroundBlue)
            if (lighter < darker) {
                swap = lighter
                lighter = darker
                darker = swap
            }
            contrast = (lighter + ambient) / (darker + ambient)
            printf "%d\n", int(contrast * scale)
        }'
}

contrast_text() {
    local centis="$1"
    printf '%d.%0*d:1\n' \
        "$((centis / CONTRAST_SCALE))" \
        "${CONTRAST_DECIMALS}" \
        "$((centis % CONTRAST_SCALE))"
}

contrast_passes() {
    (($1 >= CONTRAST_MINIMUM))
}
