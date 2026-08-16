# shellcheck shell=bash

readonly BRAVE_POLICY_DIR=/etc/brave/policies/managed
readonly BRAVE_POLICY_FILE="${BRAVE_POLICY_DIR}/donbox-colour.json"
readonly BRAVE_COMMAND=brave-origin

# Chromium has no userChrome.css, so the browser is told its
# colour the only way it accepts one from outside: an enterprise
# policy.
#
# The colour is the background, not the accent. Chromium paints
# the whole frame with it and works the rest out from there, so
# an accent turns the entire browser that colour rather than
# accenting anything.
#
# The scheme is capitalised because the policy is an enum, and an
# unrecognised value is not an error: it is ignored, which reads
# as the theme silently refusing to go dark.
brave_scheme() {
    if theme_is_dark; then
        printf 'Dark\n'
        return
    fi
    printf 'Light\n'
}

write_brave_policy() {
    jq -n --arg colour "${COLOURS[bg]}" \
        --arg scheme "$(brave_scheme)" \
        '{BrowserThemeColor: $colour, BrowserColorScheme: $scheme}' \
        >"${BRAVE_POLICY_FILE}"
}

# Policy is read at startup, so a running browser is asked to
# read it again rather than left a theme behind.
refresh_brave() {
    pgrep -x "${BRAVE_COMMAND}" >/dev/null 2>&1 || return 0
    "${BRAVE_COMMAND}" --refresh-platform-policy \
        --no-startup-window >/dev/null 2>&1 || true
}

apply_brave() {
    command -v "${BRAVE_COMMAND}" >/dev/null 2>&1 || return 0
    [[ -w "${BRAVE_POLICY_DIR}" ]] || {
        warn "${BRAVE_POLICY_DIR} is not writable;" \
            "run: donbox install brave theme"
        return 0
    }
    write_brave_policy
    refresh_brave
}
