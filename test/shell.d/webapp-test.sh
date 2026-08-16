#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

readonly WEBAPP="${BIN_DIR}/donbox-webapp"
readonly APP_NAME="Test App"
readonly APP_SLUG=test-app

workspace

stub() {
    printf '#!/usr/bin/env bash\n%s\n' "$2" >"${WORKSPACE}/$1"
    chmod +x "${WORKSPACE}/$1"
}

stub brave-origin "exit 0"
# No icon comes back, so the entry falls back to naming the
# browser's own icon rather than pointing at nothing.
stub curl "exit 1"

export PATH="${WORKSPACE}:${PATH}"
export XDG_DATA_HOME="${WORKSPACE}/data"
export XDG_STATE_HOME="${WORKSPACE}/state"
readonly ENTRY="${XDG_DATA_HOME}/applications/donbox-webapp-${APP_SLUG}.desktop"

webapp() {
    "${WEBAPP}" "$@"
}

webapp install "${APP_NAME}" example.com >/dev/null

assert "install writes a desktop entry" [ -f "${ENTRY}" ]

assert_equal "the entry opens the site as an application" \
    "$(sed -n 's/^Exec=//p' "${ENTRY}")" \
    "brave-origin --app=https://example.com"

assert_equal "a bare host gains a scheme" \
    "$(grep -c 'https://example.com' "${ENTRY}")" "1"

assert_equal "the entry carries the name it was given" \
    "$(sed -n 's/^Name=//p' "${ENTRY}")" "${APP_NAME}"

assert_equal "the entry is marked as ours" \
    "$(sed -n 's/^X-Donbox-Webapp=//p' "${ENTRY}")" "true"

assert_equal "a site with no icon falls back to the browser's" \
    "$(sed -n 's/^Icon=//p' "${ENTRY}")" "brave-origin"

assert_equal "list names what is installed" \
    "$(webapp list)" "${APP_NAME}"

# Something else's entry, sitting where ours live and named as
# ours are, but without the marker.
readonly FOREIGN="${XDG_DATA_HOME}/applications/donbox-webapp-other.desktop"
printf '[Desktop Entry]\nName=Other\n' >"${FOREIGN}"

assert_equal "list ignores an entry that is not ours" \
    "$(webapp list)" "${APP_NAME}"

assert_status "remove refuses an entry that is not ours" \
    1 webapp remove Other

assert "the entry that is not ours is untouched" [ -f "${FOREIGN}" ]

webapp remove "${APP_NAME}" >/dev/null
assert "remove takes the entry away" [ ! -f "${ENTRY}" ]

assert_status "remove complains when there is nothing of ours" \
    1 webapp remove

assert_status "an unknown verb fails" 1 webapp nonesuch
assert_status "no verb fails" 1 webapp
