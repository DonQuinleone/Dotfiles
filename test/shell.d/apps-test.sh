#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command luajit

readonly APP="${BIN_DIR}/donbox-app"
readonly TERM_LAUNCHER="${BIN_DIR}/donbox-term"
readonly APPS_FILE="${ROOT}/.config/donbox/apps.lua"

workspace

# The launcher execs the terminal, so the stub reports the
# command line it was given rather than opening a window.
cat >"${WORKSPACE}/kitty" <<'STUB'
#!/usr/bin/env bash
printf '%s\n' "$*"
STUB
cat >"${WORKSPACE}/ghostty" <<'STUB'
#!/usr/bin/env bash
printf '%s\n' "$*"
STUB
chmod +x "${WORKSPACE}/kitty" "${WORKSPACE}/ghostty"
export PATH="${WORKSPACE}:${PATH}"

assert_equal "the shipped defaults name kitty" \
    "$(DONBOX_APPS_FILE="${APPS_FILE}" "${APP}" terminal)" "kitty"

assert_equal "a role resolves to its window class" \
    "$(DONBOX_APPS_FILE="${APPS_FILE}" "${APP}" class settings)" \
    "com.donquinleone.settings"

assert_status "an unknown role is refused" 1 \
    env DONBOX_APPS_FILE="${APPS_FILE}" "${APP}" class nonesuch

assert_status "an unknown key is refused" 1 \
    env DONBOX_APPS_FILE="${APPS_FILE}" "${APP}" nonesuch

assert_status "a missing file is refused" 1 \
    env DONBOX_APPS_FILE="${WORKSPACE}/absent.lua" "${APP}" terminal

wrote() {
    cat >"${WORKSPACE}/apps.lua" <<EOF
return {
    terminal = "$1",
    classes = { settings = "com.donquinleone.settings" },
}
EOF
}

launch() {
    DONBOX_APPS_FILE="${WORKSPACE}/apps.lua" "${TERM_LAUNCHER}" "$@"
}

wrote kitty
assert_equal "kitty is opened bare when nothing is asked of it" \
    "$(launch)" ""

assert_equal "kitty takes the class as its own flag" \
    "$(launch --role settings)" "--class com.donquinleone.settings"

assert_equal "kitty takes the type size as an override" \
    "$(launch --font-size 20 -- btop)" \
    "--override font_size=20 btop"

assert_equal "kitty runs a command as trailing words" \
    "$(launch -- env FOO=1 btop --preset 2)" "env FOO=1 btop --preset 2"

wrote ghostty
assert_equal "ghostty is told not to fold into a running instance" \
    "$(launch --role settings)" \
    "--class=com.donquinleone.settings --gtk-single-instance=false"

assert_equal "ghostty runs a command behind -e" \
    "$(launch --font-size 20 -- btop)" "--font-size=20 -e btop"

assert_status "an unknown option is refused" 1 launch --nonesuch

assert_equal "DONBOX_TERMINAL overrides the named terminal" \
    "$(DONBOX_TERMINAL="${WORKSPACE}/ghostty" launch -- btop)" \
    "-e btop"

wrote nonesuch-terminal
assert_status "a terminal that is not installed is refused" 1 launch
