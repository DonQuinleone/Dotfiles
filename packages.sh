# shellcheck shell=bash

# The manifest is the only list: get_packages.sh reconciles the
# machine against it, adding what is declared and removing what
# is not, so the file and the machine cannot drift apart.
readonly MANIFEST_KINDS=(dnf flatpak coprs)
readonly REPO_EXPIRY_KEY=metadata_expire
# A repo naming no expiry inherits dnf's default of 48 hours, so
# a release published this morning stays invisible until Tuesday.
# Fedora's own updates repo asks for six.
readonly REPO_EXPIRY_VALUE=6h

# Removal only ever considers packages dnf records as directly
# wanted, and never these. Without the floor a manifest that
# simply does not mention the kernel would offer to remove it.
readonly PROTECTED_PATTERNS=(
    'kernel' 'kernel-*'
    'filesystem' 'setup' 'glibc' 'rpm' 'bash' 'coreutils'
    'fedora-release*' 'fedora-repos*'
    'grub2*' 'grubby' 'shim*'
    'dnf' 'dnf5' 'dnf5-*' 'python3-dnf*'
    'systemd' 'systemd-udev' 'systemd-resolved' 'systemd-oomd*'
    'selinux-policy*' 'sudo' 'authselect*'
)

# Software that ships as neither an rpm nor a flatpak is
# extracted here rather than run from an installer, so every
# file it leaves behind is one the manifest can account for.
readonly OPT_ROOT=${HOME}/.local/opt
readonly OPT_VERSION_STAMP=.version

# Endpoint and remote-management agents are mandated on this
# machine and are not the manifest's to remove.
readonly PROTECTED_AGENTS=(endpoint-agent rmm-agent)

manifest_require() {
    command -v jq >/dev/null 2>&1 ||
        die "jq is required to read ${MANIFEST}"
    [[ -r "${MANIFEST}" ]] || die "no manifest at ${MANIFEST}"
    jq -e . "${MANIFEST}" >/dev/null 2>&1 ||
        die "${MANIFEST} is not valid JSON"
}

manifest_kind_valid() {
    local kind
    for kind in "${MANIFEST_KINDS[@]}"; do
        [[ "${kind}" == "$1" ]] && return 0
    done
    return 1
}

manifest_list() {
    jq -r --arg kind "$1" '.[$kind][]' "${MANIFEST}"
}

manifest_has() {
    jq -e --arg kind "$1" --arg name "$2" \
        '.[$kind] | index($name)' "${MANIFEST}" >/dev/null
}

manifest_duplicates() {
    local kind
    for kind in "${MANIFEST_KINDS[@]}"; do
        jq -r --arg kind "$kind" \
            '.[$kind] | group_by(.)[] | select(length > 1)
             | "\($kind): \(.[0])"' "${MANIFEST}"
    done
}

# Written through a temporary file in the same directory, so an
# interrupted write cannot leave the manifest half rewritten.
manifest_write() {
    local temporary
    temporary=$(mktemp "${MANIFEST}.XXXXXX")
    cat >"${temporary}"
    mv "${temporary}" "${MANIFEST}"
}

manifest_add() {
    jq --arg kind "$1" --arg name "$2" \
        '.[$kind] = (.[$kind] + [$name] | unique)' \
        "${MANIFEST}" | manifest_write
}

manifest_drop() {
    jq --arg kind "$1" --arg name "$2" \
        '.[$kind] = (.[$kind] - [$name])' \
        "${MANIFEST}" | manifest_write
}

opt_names() {
    jq -r '(.opt // {}) | keys[]' "${MANIFEST}"
}

# An entry marked unmanaged is declared only so the sweep knows
# it was meant to be there; nothing installs or verifies it.
opt_managed_names() {
    jq -r '(.opt // {}) | to_entries[]
           | select(.value.managed != false) | .key' "${MANIFEST}"
}

opt_field() {
    jq -r --arg name "$1" --arg field "$2" \
        '.opt[$name][$field] // ""' "${MANIFEST}"
}

opt_flags() {
    jq -r --arg name "$1" '.opt[$name].flags // [] | .[]' \
        "${MANIFEST}"
}

opt_directory() {
    printf '%s/%s\n' "${OPT_ROOT}" "$1"
}

opt_installed_version() {
    local stamp=${OPT_ROOT}/$1/${OPT_VERSION_STAMP}
    [[ -r "${stamp}" ]] || return 0
    cat "${stamp}"
}

opt_installed_names() {
    [[ -d "${OPT_ROOT}" ]] || return 0
    find "${OPT_ROOT}" -mindepth 1 -maxdepth 1 -type d \
        -not -name '.*' -printf '%f\n' | LC_ALL=C sort
}

# The download serves whatever release is current, so the only
# statement of its version is the attachment filename. A silent
# upstream is answered with silence rather than a failure, since
# the caller asking is a report, not an install.
opt_upstream_version() {
    curl -fsSI "$1" |
        grep -io 'filename="[^"]*"' |
        grep -oE '[0-9]+(\.[0-9]+)+' |
        head -1 || true
}

repo_names() {
    jq -r '.repos | keys[]' "${MANIFEST}"
}

default_apps() {
    jq -r '.defaults | keys[]' "${MANIFEST}"
}

default_types() {
    jq -r --arg app "$1" '.defaults[$app][]' "${MANIFEST}"
}

# Rendered rather than stored as a file, so the expiry every repo
# needs is stated once here instead of in each of them.
repo_render() {
    jq -r --arg name "$1" \
        --arg key "${REPO_EXPIRY_KEY}" \
        --arg expiry "${REPO_EXPIRY_VALUE}" '
        "[" + $name + "]",
        (.repos[$name] | to_entries[] | "\(.key)=\(.value)"),
        ($key + "=" + $expiry)
    ' "${MANIFEST}"
}

package_installed() {
    rpm -q "$1" >/dev/null 2>&1
}

# Only what dnf records as directly wanted; a dependency is the
# resolver's business, not the manifest's.
installed_wanted_packages() {
    dnf repoquery --installed --qf '%{name}|%{reason}\n' \
        2>/dev/null |
        awk -F'|' '$2 == "User" || $2 == "External User" {print $1}' |
        LC_ALL=C sort -u
}

package_protected() {
    local name=$1 pattern
    for pattern in "${PROTECTED_PATTERNS[@]}" \
        "${PROTECTED_AGENTS[@]}"; do
        # shellcheck disable=SC2053
        [[ "${name}" == ${pattern} ]] && return 0
    done
    protected_by_dnf "${name}"
}

protected_by_dnf() {
    grep -qxF "$1" /etc/dnf/protected.d/*.conf 2>/dev/null
}

enabled_coprs() {
    dnf copr list 2>/dev/null |
        sed 's/ (disabled)$//; s|^copr\.fedorainfracloud\.org/||' |
        LC_ALL=C sort -u
}

# Runtimes are the resolver's business the way dependencies are,
# so only applications are ever considered for removal.
installed_flatpak_apps() {
    flatpak list --app --columns=application 2>/dev/null |
        LC_ALL=C sort -u
}

manifest_packages_sorted() {
    manifest_list dnf | LC_ALL=C sort -u
}

ACCENT="" GOOD="" WARN="" BAD="" DIM="" RESET=""

THEME_PALETTE=${XDG_STATE_HOME:-${HOME}/.local/state}
THEME_PALETTE+=/theme/shell-colours.sh
readonly THEME_PALETTE

ansi() {
    local hex=${1#\#}
    printf '\033[38;2;%d;%d;%dm' \
        "0x${hex:0:2}" "0x${hex:2:2}" "0x${hex:4:2}"
}

# Colour follows whatever theme is live rather than being stated
# here, and only when a terminal is there to read it; a pipe gets
# plain text.
# shellcheck disable=SC2034  # the colours are read by callers
load_palette() {
    [[ -t 1 ]] || return 0
    [[ -r "${THEME_PALETTE}" ]] || return 0
    # shellcheck disable=SC1090
    source "${THEME_PALETTE}"
    ACCENT=$(ansi "${THEME_ACCENT:-7e9cd8}")
    GOOD=$(ansi "${THEME_GOOD:-98bb6c}")
    WARN=$(ansi "${THEME_WARN:-e6c384}")
    BAD=$(ansi "${THEME_BAD:-c34043}")
    DIM=$(ansi "${THEME_FG_DIM:-c8c093}")
    RESET=$'\033[0m'
}
