# shellcheck shell=bash

# The manifest is the only list. get_packages.sh renders a
# machine from it, and donbox-pkg keeps it true as things are
# installed and removed, so neither can drift from the other.
readonly MANIFEST_KINDS=(dnf flatpak coprs)
readonly REPO_EXPIRY_KEY=metadata_expire
# A repo naming no expiry inherits dnf's default of 48 hours, so
# a release published this morning stays invisible until Tuesday.
# Fedora's own updates repo asks for six.
readonly REPO_EXPIRY_VALUE=6h

manifest_require() {
    command -v jq >/dev/null 2>&1 ||
        die "jq is required to read ${MANIFEST}"
    [[ -r "${MANIFEST}" ]] || die "no manifest at ${MANIFEST}"
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
