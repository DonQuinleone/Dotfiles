#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

readonly SOURCE="${ROOT}/.local/share/donbox/linkout"
readonly ADDONS="${ROOT}/.local/share/donbox/addons"
readonly ADDON="${ADDONS}/linkout@donbox.invalid.xpi"
readonly PACKED=(manifest.json background.js handoff.html handoff.js)

workspace

carries_signature() {
    unzip -l "${ADDON}" | grep -q 'META-INF/mozilla.rsa'
}

# Compared as text rather than byte for byte: packing drops the
# newline every file here ends with, and both sides of a command
# substitution lose it alike.
packed_matches() {
    [[ "$(unzip -p "${ADDON}" "$1")" == "$(cat "${SOURCE}/$1")" ]]
}

assert "the signed add-on ships beside its source" \
    test -f "${ADDON}"

assert "the package carries Mozilla's signature" carries_signature

# Signing needs an account this repository does not carry, so the
# package cannot be rebuilt from a checkout and has to be checked
# against the source instead of trusted to have kept up with it.
# A file edited without re-signing fails here rather than being
# installed over the version that was signed.
for name in "${PACKED[@]}"; do
    assert "the signed ${name} is the source ${name}" \
        packed_matches "${name}"
done

assert "the add-on is not packed inside its own source" \
    test ! -e "${SOURCE}/linkout@donbox.invalid.xpi"
