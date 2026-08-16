#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

readonly ROUTER="${BIN_DIR}/donbox"
readonly UNKNOWN_ROUTE_STATUS=127

stub() {
    local name="$1" summary="${2-}"
    local path="${WORKSPACE}/donbox-${name}"
    {
        printf '#!/usr/bin/env bash\n'
        [[ -z "${summary}" ]] ||
            printf '# donbox:summary=%s\n' "${summary}"
        # shellcheck disable=SC2016
        printf 'printf "%%s|%%s\\n" "${0##*/}" "$*"\n'
    } >"${path}"
    chmod +x "${path}"
}

hidden_stub() {
    stub "$1" "$2"
    sed -i '2i # donbox:hidden=true' "${WORKSPACE}/donbox-$1"
}

router() {
    "${WORKSPACE}/donbox" "$@"
}

workspace
install -m 755 "${ROUTER}" "${WORKSPACE}/donbox"

stub theme "Set the palette"
stub theme-menu "Choose a palette"
hidden_stub theme-daemon "Watch the palette"

assert_equal "an exact route runs its binary" \
    "$(router theme)" "donbox-theme|"

assert_equal "the longest matching prefix wins" \
    "$(router theme menu)" "donbox-theme-menu|"

assert_equal "unmatched words become arguments" \
    "$(router theme set ember)" "donbox-theme|set ember"

assert_equal "help resolves without running the binary" \
    "$(router theme set --help | head -n 1)" \
    "usage: donbox theme"

assert_equal "a flag after -- belongs to the command" \
    "$(router theme -- --help)" "donbox-theme|-- --help"

assert_status "an unknown route exits ${UNKNOWN_ROUTE_STATUS}" \
    "${UNKNOWN_ROUTE_STATUS}" router nonesuch

listed() {
    router commands "$@" | grep -c 'donbox theme daemon' || true
}

assert_equal "the listing hides hidden commands" \
    "$(listed)" "0"

assert_equal "--all lists hidden commands" \
    "$(listed --all)" "1"

assert_status "the lint passes on documented commands" \
    0 router commands --check

stub undocumented
assert_status "the lint fails on a missing summary" \
    1 router commands --check

assert_status "the shipped commands are documented" \
    0 "${ROUTER}" commands --check
