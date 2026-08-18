# shellcheck shell=bash

readonly SLACK_STATE="${HOME}/.var/app/com.slack.Slack/config\
/Slack/storage/root-state.json"

readonly SLACK_THEME_FILE="${STATE_DIR}/slack-theme.txt"

# Slack keeps the sidebar palette on its own servers, per
# workspace, so the desktop can only write out the string its
# Preferences accept and follow the system's light or dark.
slack_theme_string() {
    local -a parts=(
        "${COLOURS[bgAlt]}"
        "${COLOURS[surface]}"
        "${COLOURS[accent]}"
        "${COLOURS[onAccent]}"
        "${COLOURS[surface]}"
        "${COLOURS[fg]}"
        "${COLOURS[good]}"
        "${COLOURS[bad]}"
    )
    local joined
    printf -v joined '%s,' "${parts[@]}"
    printf '%s\n' "${joined%,}"
}

follow_system_scheme() {
    [[ -r "${SLACK_STATE}" ]] || return 0
    pgrep -f "com.slack.Slack" >/dev/null 2>&1 && return 0
    python3 - "${SLACK_STATE}" "$(light_or_dark)" <<'PY'
import json
import sys

path, scheme = sys.argv[1], sys.argv[2]
state = json.load(open(path))
settings = state.setdefault("settings", {})
settings["userTheme"] = scheme
settings["systemThemeSyncEnabled"] = True
choices = settings.setdefault("userChoices", {})
choices["userTheme"] = scheme
choices["systemThemeSyncEnabled"] = True
json.dump(state, open(path, "w"))
PY
}

apply_slack() {
    mkdir -p "${STATE_DIR}"
    slack_theme_string >"${SLACK_THEME_FILE}"
    follow_system_scheme
}
