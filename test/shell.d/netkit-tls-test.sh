#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR

set -euo pipefail

here=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
source "${here}/base-test.sh"

require_command luajit

workspace

stub() {
    local name="$1"
    shift
    printf '#!/usr/bin/env bash\n%s\n' "$*" >"${WORKSPACE}/${name}"
    chmod +x "${WORKSPACE}/${name}"
}

# timeout just runs the wrapped command so the openssl stub sees
# the real flags.
stub timeout 'shift; exec "$@"'

# One canned certificate for s_client, and matching x509 detail.
# TLS 1.0 and 1.1 return no certificate; 1.2, 1.3, the SNI probe
# and the bare probe all present it, so the matrix and the "same
# cert" SNI verdict are exercised.
read -r -d '' openssl_body <<'STUB' || true
case " $* " in
  *x509*)
    printf 'subject=CN=mail.example.com\n'
    printf 'issuer=C=US, O=Test CA, CN=Test Root\n'
    printf 'notAfter=Jan  1 00:00:00 2999 GMT\n'
    printf 'SHA256 Fingerprint=AA:BB:CC\n'
    printf 'X509v3 Subject Alternative Name: \n'
    printf '    DNS:mail.example.com, DNS:www.example.com\n'
    exit 0 ;;
  *-tls1\ *|*-tls1_1*)
    exit 0 ;;
  *s_client*)
    printf -- '-----BEGIN CERTIFICATE-----\nabc\n'
    printf -- '-----END CERTIFICATE-----\n'
    printf 'Verify return code: 0 (ok)\n'
    exit 0 ;;
esac
STUB
stub openssl "${openssl_body}"

export PATH="${WORKSPACE}:${PATH}"

survey() {
    NK_ROOT="${ROOT}" luajit -e '
        package.path = os.getenv("NK_ROOT") ..
            "/.local/lib/?.lua;" .. package.path
        local tls = require("netkit.tls")
        local r = tls.survey("203.0.113.9", "mail.example.com")
        local matrix = {}
        for _, p in ipairs(r.protocols) do
            matrix[#matrix + 1] = p.label .. "=" ..
                (p.supported and "y" or "n")
        end
        print(table.concat(matrix, " "))
        print("verify=" .. tls.verify_label(r.verify_code,
            r.verify_message))
        print("sni=" .. r.sni)
        print("subject=" .. (r.certificate.subject or "?"))
        print("sans=" .. #r.certificate.sans)'
}

out=$(survey)
assert "tls 1.2 and 1.3 are supported" \
    grep -q "1.2=y 1.3=y" <<<"${out}"
assert "tls 1.0 and 1.1 are not" \
    grep -q "1.0=n 1.1=n" <<<"${out}"
assert "the verify code maps to ok" \
    grep -q "verify=ok" <<<"${out}"
assert "matching sni and bare certs read as same" \
    grep -q "sni=same" <<<"${out}"
assert "the certificate subject is parsed" \
    grep -q "subject=CN=mail.example.com" <<<"${out}"
assert "both subject alternative names are parsed" \
    grep -q "sans=2" <<<"${out}"

# A verify code with no mapping falls back to its message.
assert_equal "an unmapped verify code shows its message" \
    "$(NK_ROOT="${ROOT}" luajit -e '
        package.path = os.getenv("NK_ROOT") ..
            "/.local/lib/?.lua;" .. package.path
        io.write(require("netkit.tls").verify_label(99, "weird"))')" \
    "weird"
