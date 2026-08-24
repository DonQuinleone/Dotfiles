#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR

set -euo pipefail

here=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
source "${here}/base-test.sh"

readonly HTTPATH="${BIN_DIR}/httpath"

require_command luajit

workspace

stub() {
    local name="$1"
    shift
    printf '#!/usr/bin/env bash\n%s\n' "$*" >"${WORKSPACE}/${name}"
    chmod +x "${WORKSPACE}/${name}"
}

# One redirect from http to https, then a 200 fronted by
# Cloudflare. The combined -sSI asks for headers, -w for the
# status line.
stub curl "case \" \$* \" in
    *I*http://example.com*)
        printf 'HTTP/1.1 301 Moved\r\nServer: nginx\r\n' ;;
    *I*https://example.com*)
        printf 'HTTP/1.1 200 OK\r\nServer: cloudflare\r\n'
        printf 'CF-RAY: abc\r\n' ;;
    *http://example.com*)
        printf 'code=301\nurl=http://example.com/\n'
        printf 'redirect=https://example.com/\nip=203.0.113.1\n'
        printf 'time=0.10\nscheme=http\n' ;;
    *https://example.com*)
        printf 'code=200\nurl=https://example.com/\n'
        printf 'redirect=\nip=203.0.113.9\n'
        printf 'time=0.20\nscheme=https\n' ;;
    *) exit 0 ;;
esac"
stub dig "exit 0"

export PATH="${WORKSPACE}:${PATH}"

assert_status "help exits zero" 0 "${HTTPATH}" --help
assert_status "missing argument is a usage error" 64 "${HTTPATH}"

report=$("${HTTPATH}" http://example.com)
assert "first hop is the 301" \
    grep -Eq "1 .* 301" <<<"${report}"
assert "second hop is the 200" \
    grep -Eq "2 .* 200" <<<"${report}"
assert "final server header is shown" \
    grep -q "cloudflare" <<<"${report}"
assert "cdn fronting is detected" \
    grep -q "Cloudflare" <<<"${report}"

encoded=$("${HTTPATH}" --json http://example.com)
assert_equal "json records both hops" \
    "$(jq '.hops | length' <<<"${encoded}")" "2"
assert_equal "json carries the final scheme" \
    "$(jq -r '.hops[1].scheme' <<<"${encoded}")" "https"
assert_equal "json carries the detected cdn" \
    "$(jq -r '.hops[1].cdn' <<<"${encoded}")" "Cloudflare"

stub curl "exit 0"
assert_status "an unreachable url fails" 1 \
    "${HTTPATH}" http://nothing.example
