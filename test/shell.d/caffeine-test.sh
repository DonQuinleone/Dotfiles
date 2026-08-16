#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

readonly CAFFEINE="${BIN_DIR}/donbox-caffeine"

workspace

# The real thing holds a logind lock for as long as it lives, so
# the stub is a bare sleep wearing its name: alive until killed,
# and matching the /proc/<pid>/cmdline check.
cat >"${WORKSPACE}/systemd-inhibit" <<'STUB'
#!/usr/bin/env bash
exec -a systemd-inhibit sleep infinity
STUB
chmod +x "${WORKSPACE}/systemd-inhibit"

export PATH="${WORKSPACE}:${PATH}"
export XDG_STATE_HOME="${WORKSPACE}/state"
readonly PID_FILE="${XDG_STATE_HOME}/donbox/caffeine.pid"

caffeine() {
    "${CAFFEINE}" "$@"
}

assert_equal "it starts uncaffeinated" "$(caffeine status)" "off"

caffeine on
assert_equal "on holds the session awake" "$(caffeine status)" "on"

assert "on records the inhibitor it started" [ -r "${PID_FILE}" ]

first=$(cat "${PID_FILE}")
caffeine on
assert_equal "on twice keeps the first inhibitor" \
    "$(cat "${PID_FILE}")" "${first}"

caffeine off
assert_equal "off lets the session sleep again" \
    "$(caffeine status)" "off"

assert "off clears the record" [ ! -e "${PID_FILE}" ]

readonly STATE_FILE="${XDG_STATE_HOME}/donbox/caffeine"

assert_equal "the desktop reads off from the state file" \
    "$(cat "${STATE_FILE}")" "off"

caffeine on
assert_equal "the state file follows the inhibitor" \
    "$(cat "${STATE_FILE}")" "on"
caffeine off

assert_equal "toggle reports the state it reached" \
    "$(caffeine toggle)" "on"
assert_equal "toggle turns it back off" "$(caffeine toggle)" "off"

# A reboot leaves the file behind with nothing alive under it.
caffeine on
stale=$(cat "${PID_FILE}")
kill "${stale}" 2>/dev/null || true
sleep 0.2
assert_equal "a dead inhibitor reads as off" \
    "$(caffeine status)" "off"

assert_equal "status corrects the file a reboot left behind" \
    "$(cat "${STATE_FILE}")" "off"

caffeine on
assert_equal "on replaces a dead inhibitor" "$(caffeine status)" "on"
caffeine off

assert_status "an unknown verb fails" 1 caffeine nonesuch
