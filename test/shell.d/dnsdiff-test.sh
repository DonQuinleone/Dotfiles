#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR

set -euo pipefail

here=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
source "${here}/base-test.sh"

readonly DNSDIFF="${BIN_DIR}/dnsdiff"
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
    *@ns2.example.com*' SOA '*)
        printf 'e.\t300\tIN\tSOA\tns1. h. 2026010100 1 1 1 1\n' ;;
    *' SOA '*)
        printf 'e.\t300\tIN\tSOA\tns1. h. 2026010101 1 1 1 1\n' ;;
    *' www.example.com NS '*) exit 0 ;;
    *' NS '*)
        printf 'e.\t300\tIN\tNS\tns1.example.com.\n'
        printf 'e.\t300\tIN\tNS\tns2.example.com.\n' ;;
    *' AAAA '*) exit 0 ;;
    *' A '*)
        printf 'w.\t300\tIN\tA\t${STUB_V4}\n' ;;
    *) exit 0 ;;
esac"
stub curl "exit 1"
stub openssl "exit 1"

export PATH="${WORKSPACE}:${PATH}"

assert_status "help exits zero" 0 "${DNSDIFF}" --help
assert_status "missing argument is a usage error" 64 "${DNSDIFF}"
assert_status "dangling type flag is a usage error" 64 \
    "${DNSDIFF}" example.com --type

report=$("${DNSDIFF}" www.example.com)
assert "stale serial is flagged" \
    grep -q "authoritative serials differ" <<<"${report}"
assert "matching answers are reported" \
    grep -q "answers agree everywhere" <<<"${report}"
assert "public resolvers are queried" \
    grep -q "Cloudflare" <<<"${report}"

encoded=$("${DNSDIFF}" --json www.example.com)
assert_equal "json holds one row per server" \
    "$(jq '.rows | length' <<<"${encoded}")" "6"
assert_equal "json records the disagreement" \
    "$(jq '.serials_agree' <<<"${encoded}")" "false"

# A server that returns NS but no SOA counts as not responding;
# with none answering, there is no serial verdict to give.
stub dig "case \" \$* \" in
    *' www.example.com NS '*) exit 0 ;;
    *' NS '*)
        printf 'e.\t300\tIN\tNS\tns1.example.com.\n'
        printf 'e.\t300\tIN\tNS\tns2.example.com.\n' ;;
    *' A '*) printf 'w.\t300\tIN\tA\t${STUB_V4}\n' ;;
    *) exit 0 ;;
esac"
silent=$("${DNSDIFF}" www.example.com)
assert "no serial verdict when nothing answers SOA" \
    grep -q "too few nameservers answered" <<<"${silent}"

# ns2 responds (has SOA) but serves no A for the name, which is a
# genuine discrepancy, not something to bless as agreement.
stub dig "case \" \$* \" in
    *@ns2.example.com*' www.example.com A '*) exit 0 ;;
    *' www.example.com NS '*) exit 0 ;;
    *' SOA '*)
        printf 'e.\t300\tIN\tSOA\tns1. h. 2026010101 1 1 1 1\n' ;;
    *' NS '*)
        printf 'e.\t300\tIN\tNS\tns1.example.com.\n'
        printf 'e.\t300\tIN\tNS\tns2.example.com.\n' ;;
    *' A '*) printf 'w.\t300\tIN\tA\t${STUB_V4}\n' ;;
    *) exit 0 ;;
esac"
gap=$("${DNSDIFF}" www.example.com)
assert "a responding ns missing the record disagrees" \
    grep -q "answers differ" <<<"${gap}"
