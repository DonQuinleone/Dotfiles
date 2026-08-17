#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

readonly OPEN="${BIN_DIR}/donbox-open"

workspace

stub() {
    printf '#!/usr/bin/env bash\n%s\n' "$2" >"${WORKSPACE}/$1"
    chmod +x "${WORKSPACE}/$1"
}

readonly CALLS="${WORKSPACE}/calls"

stub firefox "printf 'firefox %s\n' \"\$*\" >>'${CALLS}'"
stub donbox-browser \
    "printf 'pad %s\n' \"\$*\" >>'${CALLS}'"

export PATH="${WORKSPACE}:${PATH}"

opened() {
    : >"${CALLS}"
    "${OPEN}" "$1" >/dev/null 2>&1 || true
    cat "${CALLS}"
}

assert_equal "mail goes to the pad" \
    "$(opened https://mail.google.com/mail/u/0/)" \
    "pad mail https://mail.google.com/mail/u/0/"

assert_equal "calendar goes to the pad" \
    "$(opened https://calendar.google.com/calendar/r)" \
    "pad mail https://calendar.google.com/calendar/r"

assert_equal "a sign-in goes to the pad" \
    "$(opened https://accounts.google.com/signin)" \
    "pad mail https://accounts.google.com/signin"

assert_equal "everything else goes to Firefox" \
    "$(opened https://example.com/page)" \
    "firefox https://example.com/page"

# The host is what decides, so a pad host appearing anywhere else
# in the URL must not drag the link into the pad with it.
assert_equal "a pad host in the query decides nothing" \
    "$(opened 'https://example.com/r?u=mail.google.com')" \
    "firefox https://example.com/r?u=mail.google.com"

assert_equal "a port does not hide the host" \
    "$(opened https://mail.google.com:443/mail/)" \
    "pad mail https://mail.google.com:443/mail/"

assert_equal "credentials do not hide the host" \
    "$(opened https://user@mail.google.com/mail/)" \
    "pad mail https://user@mail.google.com/mail/"

assert_equal "a lookalike host is not the pad" \
    "$(opened https://mail.google.com.evil.test/)" \
    "firefox https://mail.google.com.evil.test/"

# The pad hands a link out wrapped in a scheme of ours, and what
# comes back has to route exactly as the bare URL would.
assert_equal "a wrapped link is unwrapped and sent out" \
    "$(opened donbox:https://example.com/page)" \
    "firefox https://example.com/page"

assert_equal "a wrapped pad link still goes to the pad" \
    "$(opened donbox:https://mail.google.com/mail/)" \
    "pad mail https://mail.google.com/mail/"

assert_status "something that is not a URL fails" 1 "${OPEN}" notaurl
assert_status "no argument fails" 1 "${OPEN}"
assert_status "two arguments fail" 1 "${OPEN}" one two
