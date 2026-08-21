#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

workspace

# The command finds the migrations by walking up from its own real
# path, so a copy of it in a throwaway tree brings that tree's
# migrations with it.
readonly REPO="${WORKSPACE}/repo"
readonly MIGRATIONS="${REPO}/migrations"
readonly MIGRATE="${REPO}/.local/bin/donbox-migrate"
readonly LOG="${WORKSPACE}/ran"

mkdir -p "${MIGRATIONS}" "${REPO}/.local/bin"
cp "${BIN_DIR}/donbox-migrate" "${MIGRATE}"

export XDG_STATE_HOME="${WORKSPACE}/state"
readonly APPLIED="${XDG_STATE_HOME}/donbox/migrations"

migration() {
    local path="${MIGRATIONS}/$1.sh"
    printf '#!/usr/bin/env bash\nset -euo pipefail\n%s\n' "$2" \
        >"${path}"
    chmod +x "${path}"
}

ran() {
    cat "${LOG}" 2>/dev/null || true
}

assert_equal "an untouched machine has nothing to apply" \
    "$("${MIGRATE}" | tail -n 1)" "donbox migrate: already up to date"

migration 1700000002 "printf 'second\n' >>'${LOG}'"
migration 1700000001 "printf 'first\n' >>'${LOG}'"

"${MIGRATE}" >/dev/null

assert_equal "the oldest migration runs first" \
    "$(ran)" "$(printf 'first\nsecond')"

assert "the first migration is recorded" \
    [ -e "${APPLIED}/1700000001" ]
assert "the second migration is recorded" \
    [ -e "${APPLIED}/1700000002" ]

"${MIGRATE}" >/dev/null
assert_equal "a second pass leaves them alone" \
    "$(ran)" "$(printf 'first\nsecond')"

migration 1700000003 "printf 'third\n' >>'${LOG}'"

"${MIGRATE}" >/dev/null
assert_equal "only the new migration runs" \
    "$(ran)" "$(printf 'first\nsecond\nthird')"

migration 1700000004 "printf 'fourth\n' >>'${LOG}'; exit 1"
migration 1700000005 "printf 'fifth\n' >>'${LOG}'"

assert_status "a migration that fails takes the run down with it" \
    1 "${MIGRATE}"

assert "the failure is not recorded" [ ! -e "${APPLIED}/1700000004" ]

assert_equal "the run stops rather than skipping past the failure" \
    "$(ran)" "$(printf 'first\nsecond\nthird\nfourth')"

migration 1700000004 "printf 'repaired\n' >>'${LOG}'"

"${MIGRATE}" >/dev/null
assert_equal "the repaired migration is retried, then the rest" \
    "$(ran)" \
    "$(printf 'first\nsecond\nthird\nfourth\nrepaired\nfifth')"

migration 1700000006 "true"
chmod -x "${MIGRATIONS}/1700000006.sh"

assert_status "a migration that cannot be run says so" \
    1 "${MIGRATE}"

assert_status "an argument it does not take fails" \
    1 "${MIGRATE}" --everything
