#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

readonly CONFIG_DIR="${ROOT}/.config/hypr"
readonly COMMON="${CONFIG_DIR}/hypridle-common.conf"
readonly WAIT_UNTIL_LOCKED=3
# shellcheck disable=SC2088 # hyprlang expands it, not us
readonly LOCKER="~/.local/bin/donbox idle lock"

declare -A VARIABLE=()

read_variables() {
    local name value
    while read -r name value; do
        VARIABLE["${name}"]="${value}"
    done < <(sed -n 's/^\$\([A-Z_]*\) *= *\(.*\)$/\1 \2/p' "${COMMON}")
}

setting() {
    local raw
    raw=$(sed -n "s/^ *$1 *= *//p" "$2" | head -n 1)
    case "${raw}" in
    '$'*) printf '%s\n' "${VARIABLE[${raw#$}]-}" ;;
    *) printf '%s\n' "${raw}" ;;
    esac
}

profiles() {
    local path
    for path in "${CONFIG_DIR}"/hypridle*.conf; do
        [[ "${path}" != "${COMMON}" ]] || continue
        printf '%s\n' "${path}"
    done
}

read_variables

assert_equal "sleep waits for the compositor to report the lock" \
    "$(setting inhibit_sleep "${COMMON}")" "${WAIT_UNTIL_LOCKED}"

assert_equal "logind's lock signal reaches donbox's locker" \
    "$(setting lock_cmd "${COMMON}")" "${LOCKER}"

assert "there is more than one profile to check" \
    [ "$(profiles | wc -l)" -gt 1 ]

# A profile that misses the shared block suspends without waiting
# for the locker, which shows the desktop on the way back.
while read -r profile; do
    name=$(basename "${profile}")
    assert_equal "${name} takes the shared general block" \
        "$(grep -c '^source = .*hypridle-common\.conf$' \
            "${profile}")" "1"
done < <(profiles)
