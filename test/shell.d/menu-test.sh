#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

readonly MENU="${BIN_DIR}/donbox-menu"

workspace

readonly OFFERED="${WORKSPACE}/offered"
readonly RAN="${WORKSPACE}/ran"
readonly TREE="${WORKSPACE}/menu.json"

readonly ANSWERS="${WORKSPACE}/answers"

# Records what it was shown, and answers with the next line of a
# prepared sequence, so a menu that asks twice can be walked
# without anything being clicked.
cat >"${WORKSPACE}/pick" <<PICK
#!/usr/bin/env bash
cat >>'${OFFERED}'
[ -z "\${CANCELLING:-}" ] || exit 1
head -n 1 '${ANSWERS}'
sed -i 1d '${ANSWERS}'
PICK
chmod +x "${WORKSPACE}/pick"

answer() {
    printf '%s\n' "$@" >"${ANSWERS}"
}

cat >"${TREE}" <<TREE_JSON
{
  "items": {
    "root": { "label": "Test" },
    "alpha": { "label": "Alpha" },
    "alpha.one": { "label": "One", "action": "echo one >>'${RAN}'" },
    "alpha.two": {
      "label": "Two",
      "when": "false",
      "action": "echo two >>'${RAN}'"
    },
    "alpha.three": {
      "label": "Three",
      "checked": "true",
      "action": "echo three >>'${RAN}'"
    },
    "gamma": {
      "label": "Gamma",
      "provider": "printf 'one\\tOne\\n two\\tTwo\\n'",
      "current": "printf 'two\\n'",
      "pickArgs": "--grid",
      "actionFor": "echo chose {} >>'${RAN}'",
      "cancelFor": "echo cancelled {} >>'${RAN}'"
    },
    "beta": { "label": "Beta" },
    "beta.risky": {
      "label": "Risky",
      "confirm": true,
      "action": "echo risky >>'${RAN}'"
    }
  }
}
TREE_JSON

export PATH="${WORKSPACE}:${PATH}"
export DONBOX_PICK="${WORKSPACE}/pick"
export DONBOX_MENU_TREE="${TREE}"

menu() {
    : >"${OFFERED}"
    "${MENU}" "$@"
}

offered_column() {
    cut -f"$1" "${OFFERED}"
}

answer ""
menu >/dev/null || true

assert_equal "the root lists the items with no dot in them" \
    "$(offered_column 1 | tr '\n' ' ')" "alpha gamma beta "

answer ""
menu alpha >/dev/null || true

assert_equal "a failing when hides its row" \
    "$(offered_column 1 | grep -c 'alpha.two' || true)" "0"

assert_equal "a passing checked ticks its row" \
    "$(offered_column 2 | grep -c 'Three ✓')" "1"

assert_equal "an unticked row keeps its plain label" \
    "$(offered_column 2 | grep -cx 'One')" "1"

: >"${RAN}"
answer "alpha.one"
menu alpha >/dev/null
sleep 1
assert_equal "choosing a row runs its action" \
    "$(cat "${RAN}")" "one"

: >"${RAN}"
answer "beta.risky" "cancel"
menu beta >/dev/null
sleep 1
assert_equal "a row wanting confirmation stops when it is refused" \
    "$(cat "${RAN}")" ""

: >"${RAN}"
answer "beta.risky" "confirm"
menu beta >/dev/null
sleep 1
assert_equal "the same row runs once it is confirmed" \
    "$(cat "${RAN}")" "risky"

: >"${RAN}"
answer "one"
menu gamma >/dev/null
sleep 1
assert_equal "a provider's rows come from its command" \
    "$(cut -f1 "${OFFERED}" | tr -d ' ' | tr '\n' ' ')" "one two "

assert_equal "the chosen row fills the template" \
    "$(cat "${RAN}")" "chose one"

: >"${RAN}"
answer ""
CANCELLING=1 menu gamma >/dev/null || true
sleep 1
assert_equal "cancelling runs the template for what was current" \
    "$(cat "${RAN}")" "cancelled two"

assert_status "an unknown route is refused" 1 "${MENU}" nonesuch
