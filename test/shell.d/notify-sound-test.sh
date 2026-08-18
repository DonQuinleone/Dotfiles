#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

readonly NOTIFY_SOUND="${BIN_DIR}/donbox-notify-sound"
readonly SOUNDS_DIR="${ROOT}/.local/share/donbox/sounds"
readonly RULES="${ROOT}/.config/quickshell/notifications.json"

workspace

# The real thing plays a sound; the stub says which file it was
# handed, so a suite can run on a machine with no ears.
cat >"${WORKSPACE}/pw-play" <<'STUB'
#!/usr/bin/env bash
printf '%s\n' "$1" >"${PLAYED_FILE}"
STUB
chmod +x "${WORKSPACE}/pw-play"

export PATH="${WORKSPACE}:${PATH}"
export PLAYED_FILE="${WORKSPACE}/played"

assert "the alarm has a sound of its own" \
    [ -r "${SOUNDS_DIR}/alarm.wav" ]

assert "every bundled sound is credited" \
    grep -q "alarm.wav" "${SOUNDS_DIR}/SOURCES.txt"

# A rule naming a sound that was never bundled is silence where
# a sound was asked for, which nothing else would report.
named=$(jq -r '
    [(.defaults // {}), (.applications // {})]
    | map(to_entries[].value.sound // empty)
    | flatten | unique[]' "${RULES}")

for sound in ${named}; do
    assert "the rules' ${sound} sound is bundled" \
        [ -r "${SOUNDS_DIR}/${sound}.wav" ]
done

assert "an alarm makes no announcement of its own" \
    [ "$(jq -r '.applications.Alarm.sound' "${RULES}")" = "null" ]

assert_status "an unknown sound is refused" 1 \
    "${NOTIFY_SOUND}" nonesuch

assert_status "a name is required" 1 "${NOTIFY_SOUND}"

"${NOTIFY_SOUND}" alarm
sleep 1
assert_equal "the alarm sound plays the bundled file" \
    "$(cat "${PLAYED_FILE}")" "${SOUNDS_DIR}/alarm.wav"
