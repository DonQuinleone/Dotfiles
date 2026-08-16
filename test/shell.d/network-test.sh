#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

readonly NETWORK="${BIN_DIR}/donbox-network"
readonly DEVICE=fake0
# Documentation ranges, so a stub can never be mistaken for a
# real address if one ever ends up in a log.
readonly STUB_V4=203.0.113.42
readonly STUB_V6=2001:db8::1

workspace

stub() {
    local name="$1"
    shift
    printf '#!/usr/bin/env bash\n%s\n' "$*" >"${WORKSPACE}/${name}"
    chmod +x "${WORKSPACE}/${name}"
}

stub dig "case \" \$* \" in
    *-4*) printf '%s\n' '${STUB_V4}' ;;
    *) printf '%s\n' '${STUB_V6}' ;;
esac"

stub ip "printf 'x via y dev %s src z\n' '${DEVICE}'"

# Answers at once and moves nothing, so the measured rate is a
# known zero rather than whatever the machine managed.
stub curl "sleep 0.05"

readonly STATS="${WORKSPACE}/net/${DEVICE}/statistics"
mkdir -p "${STATS}"
printf '1000\n' >"${STATS}/rx_bytes"
printf '2000\n' >"${STATS}/tx_bytes"

export PATH="${WORKSPACE}:${PATH}"
export DONBOX_NET_STATS_ROOT="${WORKSPACE}/net"
export DONBOX_SPEED_SECONDS=1

network() {
    "${NETWORK}" "$@"
}

assert_equal "public reports the v4 address as a pair" \
    "$(network public | sed -n 's/^ipv4=//p')" "${STUB_V4}"

assert_equal "public reports the v6 address as a pair" \
    "$(network public | sed -n 's/^ipv6=//p')" "${STUB_V6}"

speed=$(network speed)

assert_equal "speed reports both directions" \
    "$(printf '%s\n' "${speed}" | wc -l)" "2"

assert_equal "an idle line measures zero rather than nothing" \
    "$(printf '%s\n' "${speed}" | sed -n 's/^down=//p')" "0.0"

assert_equal "the upload direction reads the same way" \
    "$(printf '%s\n' "${speed}" | sed -n 's/^up=//p')" "0.0"

rm -rf "${WORKSPACE}/net"
assert_status "a missing counter fails loudly" 1 network speed

assert_status "an unknown verb fails" 1 network nonesuch
assert_status "no verb fails" 1 network
