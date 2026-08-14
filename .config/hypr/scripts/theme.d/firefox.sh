# shellcheck shell=bash

readonly FIREFOX_ROOTS=(
    "${CONFIG_HOME}/mozilla/firefox"
    "${HOME}/.mozilla/firefox"
)
readonly FIREFOX_CHROME_TEMPLATE="firefox-chrome.css.in"

apply_firefox() {
    mozilla_theme_app "${FIREFOX_CHROME_TEMPLATE}" \
        "${FIREFOX_ROOTS[@]}"
}
