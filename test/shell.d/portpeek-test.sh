#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR

set -euo pipefail

here=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
source "${here}/base-test.sh"

readonly PORTPEEK="${BIN_DIR}/portpeek"
readonly STUB_V4=203.0.113.42

require_command luajit

workspace

stub() {
    local name="$1"
    shift
    printf '#!/usr/bin/env bash\n%s\n' "$*" >"${WORKSPACE}/${name}"
    chmod +x "${WORKSPACE}/${name}"
}

stub dig "printf 'x.\t300\tIN\tA\t${STUB_V4}\n'"

# Stands in for the real connect: net.tcp_probe invokes
# 'timeout N bash -c SCRIPT netkit-tcp HOST PORT', so the host
# and port arrive as trailing arguments. Port 80 answers with a
# banner, 2083 opens silently, everything else is refused.
stub timeout "case \" \$* \" in
    *\" ${STUB_V4} 80 \"*)
        printf 'HTTP/1.1 200 OK'; exit 0 ;;
    *\" ${STUB_V4} 2083 \"*) exit 0 ;;
    *) exit 1 ;;
esac"

export PATH="${WORKSPACE}:${PATH}"

assert_status "help exits zero" 0 "${PORTPEEK}" --help
assert_status "missing argument is a usage error" 64 "${PORTPEEK}"
assert_status "bad port list is a usage error" 64 \
    "${PORTPEEK}" --ports nope example.com

report=$("${PORTPEEK}" example.com)
assert "open http port is listed" \
    grep -Eq "80 .* http .* open" <<<"${report}"
assert "http banner is shown" \
    grep -q "HTTP/1.1 200 OK" <<<"${report}"
assert "silent cpanel port is listed open" \
    grep -Eq "2083 .* cpanel-ssl .* open" <<<"${report}"
assert "refused port is not listed" \
    bash -c "! grep -Eq '22 .* ssh .* open' <<<'${report}'"

encoded=$("${PORTPEEK}" --json --ports 80,443 example.com)
assert_equal "json marks the open port" \
    "$(jq -r '.rows[] | select(.port==80) | .open' \
        <<<"${encoded}")" "true"
assert_equal "json marks the closed port" \
    "$(jq -r '.rows[] | select(.port==443) | .open' \
        <<<"${encoded}")" "false"

assert_status "an ip target needs no resolver" 0 \
    "${PORTPEEK}" --ports 80 "${STUB_V4}"

# A hostile hostname must reach bash as data, never as code. The
# real timeout and bash run here (the payload only touches a
# local file, no socket), and the stub dig hands back an address
# carrying a substitution; the marker must not appear.
rm -f "${WORKSPACE}/timeout"
marker="${WORKSPACE}/pwned"
stub dig "printf 'x.\t300\tIN\tA\t\$(touch ${marker})x\n'"
"${PORTPEEK}" --ports 80 evil.example >/dev/null 2>&1 || true
assert "a substitution in a resolved address does not run" \
    bash -c "[[ ! -e '${marker}' ]]"
