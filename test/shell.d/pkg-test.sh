#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

readonly PKG="${BIN_DIR}/donbox-pkg"

workspace

stub() {
    printf '#!/usr/bin/env bash\n%s\n' "$2" >"${WORKSPACE}/$1"
    chmod +x "${WORKSPACE}/$1"
}

readonly CALLS="${WORKSPACE}/calls"
readonly MANIFEST="${WORKSPACE}/packages.json"

cat >"${MANIFEST}" <<'JSON'
{
  "repos": {
    "example": {
      "name": "Example",
      "baseurl": "https://example.com/repo",
      "gpgcheck": "1"
    }
  },
  "coprs": ["someone/something"],
  "dnf": ["btop", "ripgrep"],
  "flatpak": ["com.example.Thing"]
}
JSON

# sudo is the seam the transaction goes through, so recording it
# records the transaction without one ever running.
stub sudo "printf '%s\n' \"\$*\" >>'${CALLS}'
case \" \$* \" in *' fails '*) exit 1 ;; esac"
# git diff reports a difference with a non-zero status, which is
# exactly what record() reads to decide there is anything to
# commit.
stub git "printf 'git %s\n' \"\$*\" >>'${CALLS}'
case \" \$* \" in *' diff '*) exit 1 ;; esac"
# shellcheck disable=SC2016
stub fzf 'query=""
for arg in "$@"; do
    case "${arg}" in --query=*) query="${arg#--query=}" ;; esac
done
if [ -n "${query}" ]; then
    chosen=$(grep -- "${query}" || true)
else
    chosen=$(head -n 1)
fi
[ -n "${chosen}" ] || exit 1
printf "%s\n" "${chosen}"'

export PATH="${WORKSPACE}:${PATH}"
export DONBOX_MANIFEST="${MANIFEST}"
export DONBOX_PKG_WINDOW=1

pkg() {
    "${PKG}" "$@"
}

listed() {
    jq -r --arg kind "$1" '.[$kind][]' "${MANIFEST}"
}

assert_equal "list reads the manifest" \
    "$(pkg list | tr '\n' ' ')" "btop ripgrep "

assert_equal "list answers for flatpaks too" \
    "$(pkg list flatpak)" "com.example.Thing"

assert_status "list refuses a kind that is not in the manifest" \
    1 pkg list nonesuch

pkg add dnf fd-find >/dev/null

assert_equal "add installs through the package manager" \
    "$(grep -c '^dnf install fd-find$' "${CALLS}")" "1"

assert_equal "add records what it installed" \
    "$(listed dnf | tr '\n' ' ')" "btop fd-find ripgrep "

assert_equal "add commits the manifest on its own path" \
    "$(grep -c 'commit .* packaging: add fd-find' "${CALLS}")" "1"

pkg add dnf btop >/dev/null
assert_equal "adding what is already listed does not list it twice" \
    "$(listed dnf | grep -c '^btop$')" "1"

pkg add flatpak com.example.Other >/dev/null
assert_equal "the flatpak kind goes to the right manager" \
    "$(grep -c 'flatpak install -y flathub com.example.Other' "${CALLS}")" "1"

assert_equal "a flatpak is recorded as a flatpak" \
    "$(listed flatpak | tr '\n' ' ')" "com.example.Other com.example.Thing "

# A manager that fails must leave the manifest alone, or the
# next machine built from it installs something that never
# worked here.
pkg add dnf fails >/dev/null || true
assert_equal "a failed transaction changes nothing" \
    "$(listed dnf | grep -c '^fails$' || true)" "0"

pkg remove ripgrep >/dev/null
assert_equal "remove takes it out of the manifest" \
    "$(listed dnf | tr '\n' ' ')" "btop fd-find "

assert_equal "remove commits too" \
    "$(grep -c 'packaging: drop ripgrep' "${CALLS}")" "1"

: >"${CALLS}"
pkg remove >/dev/null
assert_equal "remove without a name asks the chooser" \
    "$(grep -c '^dnf remove btop$' "${CALLS}")" "1"

# The query is what a search is made of, so nothing matches
# until this says otherwise.
stub dnf "printf 'dnf %s\n' \"\$*\" >>'${CALLS}'"
stub term "printf 'term %s\n' \"\$*\" >>'${CALLS}'"

assert_status "a search matching nothing still fails" \
    1 pkg search nonesuch

# Redirected on purpose: without a terminal on either side the
# search has nowhere to prompt, which is the menu's case.
: >"${CALLS}"
env -u DONBOX_PKG_WINDOW DONBOX_TERMINAL="${WORKSPACE}/term" \
    DONBOX_APPS_FILE="${ROOT}/.config/donbox/apps.lua" \
    "${PKG}" search ripgrep >/dev/null 2>&1 </dev/null || true
assert_equal "a search without a terminal opens one for itself" \
    "$(grep -c 'term .* DONBOX_PKG_WINDOW=1 .* search ripgrep' \
        "${CALLS}")" "1"

assert_status "an unknown verb fails" 1 pkg nonesuch
assert_status "no verb fails" 1 pkg
