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
    *\" ${STUB_V4} 25 \"*)
        printf '220 \033[31mgreet\033[0m'; exit 0 ;;
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
assert "the smtp banner keeps its printable text" \
    grep -q "220 .*greet" <<<"${report}"
escape=$(printf '\033')
if grep -q "${escape}" <<<"${report}"; then
    fail "an escape sequence is stripped from a banner"
fi
pass "an escape sequence is stripped from a banner"

encoded=$("${PORTPEEK}" --json --ports 80,443 example.com)
assert_equal "json marks the open port" \
    "$(jq -r '.rows[] | select(.port==80) | .open' \
        <<<"${encoded}")" "true"
assert_equal "json marks the closed port" \
    "$(jq -r '.rows[] | select(.port==443) | .open' \
        <<<"${encoded}")" "false"

assert_status "an ip target needs no resolver" 0 \
    "${PORTPEEK}" --ports 80 "${STUB_V4}"

# An address target must probe even where dig is absent, since it
# never needs to resolve anything.
rm -f "${WORKSPACE}/dig"
assert "an ip target probes without dig present" \
    grep -Eq "80 .* open" \
    < <("${PORTPEEK}" --ports 80 "${STUB_V4}")
stub dig "printf 'x.\t300\tIN\tA\t${STUB_V4}\n'"

# When mktemp fails the batch falls back to serial probing and
# must still return the right verdicts in order.
stub mktemp "exit 1"
serial=$("${PORTPEEK}" --ports 80,22,2083 "${STUB_V4}")
assert "serial fallback keeps the open http port" \
    grep -Eq "80 .* open" <<<"${serial}"
assert "serial fallback keeps the silent cpanel port" \
    grep -Eq "2083 .* open" <<<"${serial}"
assert "serial fallback drops the refused port" \
    bash -c "! grep -Eq '22 .* open' <<<'${serial}'"
rm -f "${WORKSPACE}/mktemp"

# A hostile hostname must reach bash as data, never spliced into
# the script it runs. This stub captures the timeout arguments
# and executes nothing, so the check is hermetic: no bash, no
# resolver, no socket. The payload must appear as its own
# trailing argument, and the script must reference "$1", not the
# payload text.
arglog="${WORKSPACE}/timeout.args"
stub timeout "printf '%s\n' \"\$*\" >>'${arglog}'; exit 1"
stub dig "printf 'x.\t300\tIN\tA\t\$(touch /pwned)x\n'"
: >"${arglog}"
"${PORTPEEK}" --ports 80 evil.example >/dev/null 2>&1 || true
# shellcheck disable=SC2016  # literal $(...) and $1 are the point
assert "the hostile host is passed as a bash argument" \
    grep -qF 'netkit-tcp $(touch /pwned)x 80' "${arglog}"
# shellcheck disable=SC2016
assert "the script interpolates positional args, not the host" \
    grep -qF '/dev/tcp/"$1"/"$2"' "${arglog}"
# shellcheck disable=SC2016
assert "the payload is never spliced into the script text" \
    bash -c "! grep -qF '/dev/tcp/\$(touch' '${arglog}'"
