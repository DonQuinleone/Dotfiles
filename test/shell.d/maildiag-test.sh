#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR

set -euo pipefail

here=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
source "${here}/base-test.sh"

readonly MAILDIAG="${BIN_DIR}/maildiag"
readonly STUB_V4=203.0.113.42

require_command luajit

workspace

stub() {
    local name="$1"
    shift
    printf '#!/usr/bin/env bash\n%s\n' "$*" >"${WORKSPACE}/${name}"
    chmod +x "${WORKSPACE}/${name}"
}

stub dig "case \" \$* \" in
    *' -x '*)
        printf 'x.\t300\tIN\tPTR\tmail.example.com.\n' ;;
    *' MX '*)
        printf 'e.\t300\tIN\tMX\t10 mail.example.com.\n'
        printf 'e.\t300\tIN\tMX\t20 backup.example.com.\n' ;;
    *_dmarc.*)
        printf 'x.\t300\tIN\tTXT\t\"v=DMARC1; p=quarantine; '
        printf 'rua=mailto:d@example.com\"\n' ;;
    *default._domainkey.*)
        printf 'x.\t300\tIN\tTXT\t\"v=DKIM1; k=rsa; p=abc\"\n' ;;
    *_domainkey.*|*_mta-sts.*|*_smtp._tls.*) exit 0 ;;
    *' TXT '*)
        printf 'x.\t300\tIN\tTXT\t\"v=spf1 ~all\"\n' ;;
    *' TLSA '*) exit 0 ;;
    *) printf 'x.\t300\tIN\tA\t${STUB_V4}\n' ;;
esac"
stub curl "exit 1"
stub openssl "exit 1"
stub timeout "exit 1"

export PATH="${WORKSPACE}:${PATH}"

assert_status "help exits zero" 0 "${MAILDIAG}" --help
assert_status "missing argument is a usage error" 64 "${MAILDIAG}"
assert_status "an ip address is refused" 1 "${MAILDIAG}" 1.2.3.4

report=$("${MAILDIAG}" example.com)
assert "primary mx is listed" \
    grep -q "mail.example.com" <<<"${report}"
assert "backup mx is listed" \
    grep -q "backup.example.com" <<<"${report}"
assert "spf record is shown" grep -q "v=spf1" <<<"${report}"
assert "dmarc policy is shown" \
    grep -q "quarantine" <<<"${report}"
assert "dkim selector is found" \
    grep -Eq "Selectors +default" <<<"${report}"

encoded=$("${MAILDIAG}" --json --mx example.com)
assert_equal "json lists the primary exchange" \
    "$(jq -r '.mx[0].exchange' <<<"${encoded}")" \
    "mail.example.com"
assert_equal "json lists both exchanges" \
    "$(jq '.mx | length' <<<"${encoded}")" "2"

stub dig "case \" \$* \" in
    *' MX '*|*' -x '*|*' AAAA '*) exit 0 ;;
    *) printf 'x.\t300\tIN\tA\t${STUB_V4}\n' ;;
esac"
implicit=$("${MAILDIAG}" --mx example.com)
assert "implicit mx falls back to the domain" \
    grep -q "(implicit)" <<<"${implicit}"

assert "address parsing keeps only the domain" \
    bash -c "'${MAILDIAG}' --mx someone@example.com |
        grep -q 'Mail for example.com'"
