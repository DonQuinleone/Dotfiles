# shellcheck shell=bash

readonly THUNDERBIRD_ROOTS=(
    "${CONFIG_HOME}/thunderbird"
    "${HOME}/.thunderbird"
)
readonly THUNDERBIRD_CHROME_TEMPLATE="thunderbird-chrome.css.in"

apply_thunderbird() {
    mozilla_theme_app "${THUNDERBIRD_CHROME_TEMPLATE}" \
        "${THUNDERBIRD_ROOTS[@]}"
}
