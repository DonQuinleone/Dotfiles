#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR

set -euo pipefail

here=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
source "${here}/base-test.sh"

readonly HOSTINFO="${BIN_DIR}/hostinfo"
readonly STUB_V4=203.0.113.42

require_command luajit

lua_eval() {
    luajit -e "package.path='${ROOT}/.local/lib/?.lua;'..package.path
        local net = require('netkit.net')
        io.write($1)"
}

assert_equal "url strips scheme, userinfo, port and path" \
    "$(lua_eval "net.normalise_target(
        'https://Admin@WWW.Example.COM:8443/x?q=1')")" \
    "www.example.com"

assert_equal "bracketed ipv6 url yields the literal" \
    "$(lua_eval "net.normalise_target(
        'https://[2001:db8::1]:443/')")" \
    "2001:db8::1"

assert_equal "ipv4-mapped ipv6 collapses to the ipv4" \
    "$(lua_eval "net.normalise_target('::ffff:192.0.2.1')")" \
    "192.0.2.1"

assert_equal "ipv4 literal is recognised" \
    "$(lua_eval "tostring(net.is_ipv4('${STUB_V4}'))")" "true"

assert_equal "ipv6 literal is recognised" \
    "$(lua_eval "tostring(net.is_ipv6('2001:db8::1'))")" "true"

assert_equal "empty label is rejected" \
    "$(lua_eval "tostring(net.plausible_host('a..b'))")" "false"

assert_equal "leading dash is rejected" \
    "$(lua_eval "tostring(net.plausible_host('-x'))")" "false"

assert_equal "ordinary hostname is accepted" \
    "$(lua_eval "tostring(net.plausible_host('example.com'))")" \
    "true"

assert_equal "split txt strings join without the shown space" \
    "$(lua_eval "net.unquote_txt('\"v=spf1 a\" \"b -all\"')")" \
    "v=spf1 ab -all"

quoted=$(lua_eval "net.quote([[a'b \$(x)]])")
assert_equal "quote survives a shell round trip" \
    "$(eval "printf '%s' ${quoted}")" "a'b \$(x)"

workspace

stub() {
    local name="$1"
    shift
    printf '#!/usr/bin/env bash\n%s\n' "$*" >"${WORKSPACE}/${name}"
    chmod +x "${WORKSPACE}/${name}"
}

stub dig "case \" \$* \" in
    *' -x '*) exit 0 ;;
    *) printf 'example.com.\t300\tIN\tA\t${STUB_V4}\n' ;;
esac"
stub curl "exit 1"
stub openssl "exit 1"

export PATH="${WORKSPACE}:${PATH}"

assert_status "help exits zero" 0 "${HOSTINFO}" --help
assert_status "missing argument is a usage error" 64 "${HOSTINFO}"
assert_status "unparseable target fails" 1 "${HOSTINFO}" 'a..b'

unparseable=$("${HOSTINFO}" 'a..b' 2>&1 || true)
assert_equal "unparseable target dies with a message" \
    "${unparseable}" "hostinfo: could not parse a host from 'a..b'"

report=$("${HOSTINFO}" example.com)
assert "stubbed lookup reports the address" \
    grep -q "${STUB_V4}" <<<"${report}"
assert "stubbed lookup reports clean blacklists" \
    grep -q "clean" <<<"${report}"
assert "no tls stub degrades to a no tls row" \
    grep -q "no TLS" <<<"${report}"
assert "resolution shows the record ttl" \
    grep -q "300" <<<"${report}"

tls_only=$("${HOSTINFO}" --tls example.com)
assert "tls flag keeps the tls section" \
    grep -q "TLS (port 443)" <<<"${tls_only}"
assert "tls flag drops the addresses section" \
    bash -c "! grep -q '^Addresses' <<<'${tls_only}'"

encoded=$("${HOSTINFO}" --json --net example.com)
assert_equal "json reports the address" \
    "$(jq -r '.addresses[0].address' <<<"${encoded}")" \
    "${STUB_V4}"
assert_equal "json omits unselected sections" \
    "$(jq -r '.tls' <<<"${encoded}")" "null"

stub dig "case \" \$* \" in
    *' -x '*) exit 0 ;;
    *dbl.spamhaus.org*)
        printf 'x.\t60\tIN\tA\t127.0.1.2\n' ;;
    *multi.surbl.org*) exit 0 ;;
    *' NS '*)
        printf 'example.com.\t300\tIN\tNS\tns1.example.com.\n' ;;
    *' SOA '*|*' DNSKEY '*|*' DS '*|*' MX '*) exit 0 ;;
    *' TXT '*|*' CAA '*) exit 0 ;;
    *) printf 'example.com.\t300\tIN\tA\t${STUB_V4}\n' ;;
esac"

zone_report=$("${HOSTINFO}" --dns example.com)
assert "delegation is reported consistent" \
    grep -q "consistent (1 NS)" <<<"${zone_report}"
assert "domain blacklist listing is reported" \
    grep -q "dbl.spamhaus.org 127.0.1.2" <<<"${zone_report}"

stub dig "exit 0"
assert_status "hostname without answers does not resolve" 1 \
    "${HOSTINFO}" nothing.example
