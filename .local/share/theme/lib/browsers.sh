# shellcheck shell=bash

readonly BRAVE_POLICY=/etc/brave/policies/managed/theme-colour.json
readonly BRAVE_BINARY=brave-origin
readonly BRAVE_REFRESH_TIMEOUT=10
readonly BRAVE_TINT=30

readonly FIREFOX_ROOT_RELATIVE=mozilla/firefox
readonly -a FIREFOX_LINKS=(
    "firefox-chrome.css:theme.css:userChrome.css"
    "firefox-content.css:theme-content.css:userContent.css"
)
readonly FIREFOX_PREF=toolkit.legacyUserProfileCustomizations.stylesheets

# The flag tells a running browser to reread its policy, but with
# no browser to tell it starts a whole one that never exits, since
# there is no window to close. A browser that is not running reads
# the policy at launch anyway, so it needs no telling.
refresh_brave() {
    command -v "${BRAVE_BINARY}" >/dev/null 2>&1 || return 0
    pgrep -x brave >/dev/null 2>&1 || return 0
    timeout "${BRAVE_REFRESH_TIMEOUT}" "${BRAVE_BINARY}" \
        --refresh-platform-policy --no-startup-window \
        >/dev/null 2>&1 || true
}

# Chromium reads its theme from managed policy, which is a
# directory only root may write; the install step hands this
# account ownership of it, and a switch is a no-op without that.
apply_brave() {
    [[ -w $(dirname "${BRAVE_POLICY}") ]] || return 0
    local scheme=Light
    [[ ${TOKENS[mode]} == dark ]] && scheme=Dark
    cat >"${BRAVE_POLICY}" <<JSON
{
  "BrowserThemeColor": "$(blend "${TOKENS[background]}" \
        "${TOKENS[accent]}" "${BRAVE_TINT}")",
  "BrowserColorScheme": "${scheme}"
}
JSON
    refresh_brave
}

import_line() {
    printf '@import url("%s");\n' "$1"
}

apply_firefox_sheets() {
    local profile=$1 entry source name importer sheet
    for entry in "${FIREFOX_LINKS[@]}"; do
        source=${RENDERED}/${entry%%:*}
        name=${entry#*:}
        importer=${name#*:}
        name=${name%%:*}
        [[ -f $source ]] || continue
        link_file "${source}" "${profile}/chrome/${name}"
        sheet=${profile}/chrome/${importer}
        grep -qF "$(import_line "${name}")" "${sheet}" 2>/dev/null &&
            continue
        import_line "${name}" >"${sheet}"
    done
}

apply_firefox_pref() {
    local user_js=$1/user.js
    grep -qF "${FIREFOX_PREF}" "${user_js}" 2>/dev/null && return 0
    printf 'user_pref("%s", true);\n' "${FIREFOX_PREF}" >>"${user_js}"
}

apply_firefox() {
    local root=${CONFIG}/${FIREFOX_ROOT_RELATIVE} profile
    [[ -d $root ]] || return 0
    for profile in "${root}"/*; do
        [[ -f ${profile}/prefs.js || -f ${profile}/times.json ]] ||
            continue
        apply_firefox_sheets "${profile}"
        apply_firefox_pref "${profile}"
    done
}
