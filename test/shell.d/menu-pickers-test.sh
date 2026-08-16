#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

readonly EMOJI="${BIN_DIR}/donbox-menu-emoji"
readonly CLIPBOARD="${BIN_DIR}/donbox-menu-clipboard"

workspace

stub() {
    printf '#!/usr/bin/env bash\n%s\n' "$2" >"${WORKSPACE}/$1"
    chmod +x "${WORKSPACE}/$1"
}

readonly COPIED="${WORKSPACE}/copied"
readonly OFFERED="${WORKSPACE}/offered"

# The chooser is the seam: it records what it was offered and
# answers with a fixed row, so nothing has to be clicked.
stub pick "cat >'${OFFERED}'
sed -n \"\${DONBOX_PICK_ROW:-1}p\" '${OFFERED}' | cut -f1"
stub wl-copy "cat >'${COPIED}'"

export PATH="${WORKSPACE}:${PATH}"
export DONBOX_PICK="${WORKSPACE}/pick"

readonly EMOJI_DATA="${WORKSPACE}/emoji-test.txt"
cat >"${EMOJI_DATA}" <<'DATA'
# group: Smileys & Emotion
1F600                    ; fully-qualified     # 😀 E1.0 grinning face
1F636 200D 1F32B FE0F    ; fully-qualified     # 😶‍🌫️ E13.1 face in clouds
1F636 200D 1F32B         ; minimally-qualified # 😶‍🌫 E13.1 face in clouds
DATA
export DONBOX_EMOJI_DATA="${EMOJI_DATA}"

"${EMOJI}"

assert_equal "the emoji picker copies the glyph alone" \
    "$(cat "${COPIED}")" "😀"

assert_equal "only fully-qualified emoji are offered" \
    "$(wc -l <"${OFFERED}")" "2"

assert_equal "an emoji is searchable by its name" \
    "$(sed -n '1p' "${OFFERED}" | cut -f2)" "😀 grinning face"

assert_equal "a multi-codepoint emoji survives the parse" \
    "$(sed -n '2p' "${OFFERED}" | cut -f1)" "😶‍🌫️"

DONBOX_PICK_ROW=2 "${EMOJI}"
assert_equal "the chosen row is what gets copied" \
    "$(cat "${COPIED}")" "😶‍🌫️"

rm -f "${COPIED}" "${OFFERED}"

stub cliphist "case \"\$1\" in
    list) printf '7\tfirst thing\n8\tsecond\twith a tab\n' ;;
    decode) printf 'decoded %s' \"\$2\" ;;
esac"

"${CLIPBOARD}"

assert_equal "the clipboard picker restores what was chosen" \
    "$(cat "${COPIED}")" "decoded 7"

assert_equal "a preview keeps its own tabs out of the format" \
    "$(sed -n '2p' "${OFFERED}" | cut -f2)" "second with a tab"

stub cliphist "case \"\$1\" in list) : ;; esac"
assert_status "an empty history says so" 1 "${CLIPBOARD}"
