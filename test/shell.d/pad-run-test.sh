#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

readonly PAD_RUN="${BIN_DIR}/donbox-pad-run"

workspace

readonly STARTED="${WORKSPACE}/started"

cat >"${WORKSPACE}/nosuchprogram" <<STUB
#!/usr/bin/env bash
printf 'started %s\n' "\$*" >>"${STARTED}"
STUB
chmod +x "${WORKSPACE}/nosuchprogram"

windows() {
    cat >"${WORKSPACE}/hyprctl" <<STUB
#!/usr/bin/env bash
printf '%s\n' '$1'
STUB
    chmod +x "${WORKSPACE}/hyprctl"
}

export PATH="${WORKSPACE}:${PATH}"

windows '[]'
: >"${STARTED}"
"${PAD_RUN}" "com.example.absent" -- nosuchprogram --flag
assert "a pane with nothing in it is filled" [ -s "${STARTED}" ]

assert_equal "the program is given its own arguments" \
    "$(cat "${STARTED}")" "started --flag"

windows '[{"class": "com.example.present"}]'
: >"${STARTED}"
"${PAD_RUN}" "com.example.present" -- nosuchprogram
assert "a pane already showing is left alone" \
    [ ! -s "${STARTED}" ]

# The command names the program, and so does this script's own
# command line: matching that would find itself and start
# nothing, ever.
windows '[]'
: >"${STARTED}"
"${PAD_RUN}" "com.example.absent" -- nosuchprogram
assert "looking for the program does not find this script" \
    [ -s "${STARTED}" ]

windows '[]'
: >"${STARTED}"
sleep 30 &
readonly SLEEPER=$!
"${PAD_RUN}" "com.example.absent" -- sleep 30
kill "${SLEEPER}" 2>/dev/null || true
assert "a program already running is not started again" \
    [ ! -s "${STARTED}" ]

assert_status "a command is required" 1 "${PAD_RUN}" only-a-class

# "flatpak" alone answers for every flatpak on the machine, so
# one running must not stand in for another.
cat >"${WORKSPACE}/holder" <<STUB
#!/usr/bin/env bash
printf 'held %s\\n' "\$*" >>"${STARTED}"
sleep 40
STUB
chmod +x "${WORKSPACE}/holder"

windows '[]'
: >"${STARTED}"
holder other.app.entirely &
readonly OTHER=$!
sleep 1
"${PAD_RUN}" "com.example.absent" -- holder the.app.wanted &
readonly WANTED=$!
sleep 2
kill "${OTHER}" "${WANTED}" 2>/dev/null || true
assert "another program sharing a word is not mistaken for it" \
    grep -q "the.app.wanted" "${STARTED}"
