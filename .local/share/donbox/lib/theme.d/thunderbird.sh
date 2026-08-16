# shellcheck shell=bash

readonly THUNDERBIRD_ROOTS=(
    "${CONFIG_HOME}/thunderbird"
    "${HOME}/.thunderbird"
)
readonly THUNDERBIRD_CHROME_TEMPLATE="thunderbird-chrome.css.in"
readonly THUNDERBIRD_TITLEBAR_PREF="mail.tabs.drawInTitlebar"

thunderbird_release_titlebar() {
    local profile
    while read -r profile; do
        mozilla_set_user_pref "${profile}/${MOZILLA_USER_PREFS}" \
            "${THUNDERBIRD_TITLEBAR_PREF}" false
    done < <(mozilla_app_profiles "${THUNDERBIRD_ROOTS[@]}")
}

apply_thunderbird() {
    mozilla_theme_app thunderbird "${THUNDERBIRD_CHROME_TEMPLATE}" \
        "${THUNDERBIRD_ROOTS[@]}"
    thunderbird_release_titlebar
}
