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
