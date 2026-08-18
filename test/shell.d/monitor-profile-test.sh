#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

readonly PROFILE="${BIN_DIR}/donbox-monitor-profile"

require_command python3

workspace

# A stub ahead of the real thing on PATH, so a suite run inside a
# live session cannot reach the compositor it is describing.
cat >"${WORKSPACE}/hyprctl" <<'STUB'
#!/usr/bin/env bash
exit 0
STUB
chmod +x "${WORKSPACE}/hyprctl"

export PATH="${WORKSPACE}:${PATH}"
export XDG_STATE_HOME="${WORKSPACE}/state"

cat >"${WORKSPACE}/monitors.json" <<'JSON'
[
  {
    "name": "DP-5",
    "description": "Test Wide OLED",
    "width": 3840,
    "height": 2160,
    "refreshRate": 60.0,
    "x": 0,
    "y": 0,
    "scale": 1.5,
    "transform": 0,
    "currentFormat": "XRGB2101010"
  },
  {
    "name": "eDP-1",
    "description": "Test Built-in Panel",
    "width": 1920,
    "height": 1200,
    "refreshRate": 60.0,
    "x": 2560,
    "y": 0,
    "scale": 1.0,
    "transform": 0,
    "currentFormat": "XRGB8888"
  }
]
JSON

cat >"${WORKSPACE}/workspaces.json" <<'JSON'
[
  { "id": 1, "monitor": "DP-5" },
  { "id": 21, "monitor": "eDP-1" }
]
JSON

MONITOR_PROFILE_TEST_MONITORS_JSON="${WORKSPACE}/monitors.json"
MONITOR_PROFILE_TEST_WORKSPACES_JSON="${WORKSPACE}/workspaces.json"
export MONITOR_PROFILE_TEST_MONITORS_JSON
export MONITOR_PROFILE_TEST_WORKSPACES_JSON

readonly SAVED="${XDG_STATE_HOME}/hypr/monitor-profiles/docked.json"

"${PROFILE}" save docked >/dev/null

saved_depth() {
    python3 -c '
import json
import sys

for output in json.load(open(sys.argv[1]))["outputs"]:
    if output["description"] == sys.argv[2]:
        print(output["bitdepth"])
        break
' "${SAVED}" "$1"
}

assert_equal "a ten-bit buffer saves as a ten-bit depth" \
    "$(saved_depth "Test Wide OLED")" "10"

assert_equal "an eight-bit buffer saves as an eight-bit depth" \
    "$(saved_depth "Test Built-in Panel")" "8"

plan=$("${PROFILE}" apply docked --dry-run)

assert_equal "apply carries the saved depth into the rule" \
    "$(grep -c 'bitdepth.*10' <<<"${plan}")" "1"

python3 - "${SAVED}" <<'PY'
import json
import sys

profile = json.load(open(sys.argv[1]))
for output in profile["outputs"]:
    output.pop("bitdepth", None)
json.dump(profile, open(sys.argv[1], "w"), indent=2)
PY

plan=$("${PROFILE}" apply docked --dry-run)

assert_equal "a profile saved before depths falls back to eight" \
    "$(grep -c 'bitdepth.*8' <<<"${plan}")" "2"

# Reconfiguring an output that already holds the mode asked of
# it still blanks the screen, and detect runs on every reload.
detected=$("${PROFILE}" detect --dry-run)

assert_equal "detect leaves outputs already in place alone" \
    "$(grep -c 'hl.monitor' <<<"${detected}")" "0"

assert "detect still puts the workspaces where they belong" \
    grep -q 'workspace.move' <<<"${detected}"
