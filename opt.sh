# shellcheck shell=bash

readonly OPT_STAGE=${OPT_ROOT}/.stage
readonly LAUNCHER_DIR=${HOME}/.local/bin
readonly DESKTOP_DIR=${HOME}/.local/share/applications

declare -rA OPT_INSTALLERS=(
    [appimage]=install_appimage
    [binary]=install_binary
)

opt_format_valid() {
    [[ -v OPT_INSTALLERS["$1"] ]]
}

install_opt_entry() {
    local name=$1 format
    format=$(opt_field "${name}" format)
    "${OPT_INSTALLERS[${format}]}" "${name}"
}

# Extracted rather than run where it landed: an AppImage mounts
# itself through libfuse2, which Fedora no longer ships.
install_appimage() {
    local name=$1 directory image
    directory=$(opt_directory "${name}")
    image=${OPT_STAGE}/image
    rm -rf "${OPT_STAGE}"
    mkdir -p "${OPT_STAGE}"
    fetch_verified "${name}" "${image}"
    extract_appimage "${image}"
    opt_field "${name}" version \
        >"${OPT_STAGE}/squashfs-root/${OPT_VERSION_STAMP}"
    rm -rf "${directory}"
    mv "${OPT_STAGE}/squashfs-root" "${directory}"
    rm -rf "${OPT_STAGE}"
    write_launcher "${name}" "${directory}/AppRun"
    write_desktop_entry "${name}"
}

# A command-line release is either the executable itself or a
# tar.gz carrying it alongside its docs, and only the bytes say
# which; neither shape brings a desktop entry.
install_binary() {
    local name=$1 directory download staged root
    directory=$(opt_directory "${name}")
    download=${OPT_STAGE}/download
    root=${OPT_STAGE}/root
    rm -rf "${OPT_STAGE}"
    mkdir -p "${root}"
    fetch_verified "${name}" "${download}"
    staged=$(staged_executable "${name}" "${download}")
    install -m 755 "${staged}" "${root}/${name}"
    opt_field "${name}" version >"${root}/${OPT_VERSION_STAMP}"
    rm -rf "${directory}"
    mv "${root}" "${directory}"
    rm -rf "${OPT_STAGE}"
    write_launcher "${name}" "${directory}/${name}"
}

staged_executable() {
    local name=$1 download=$2 unpacked=${OPT_STAGE}/unpacked found
    is_tarball "${download}" || {
        printf '%s\n' "${download}"
        return 0
    }
    mkdir -p "${unpacked}"
    tar -xzf "${download}" -C "${unpacked}"
    found=$(find "${unpacked}" -type f -perm -u+x -print -quit)
    [[ -n "${found}" ]] || die "${name} archive holds no executable"
    printf '%s\n' "${found}"
}

is_tarball() {
    tar -tzf "$1" >/dev/null 2>&1
}

# The hash is the whole pin: the download URL serves whatever
# release is current, so a mismatch is upstream moving on rather
# than a damaged download.
fetch_verified() {
    local name=$1 target=$2 url expected actual
    url=$(opt_field "${name}" url)
    expected=$(opt_field "${name}" sha256)
    curl -fsSL -o "${target}" "${url}"
    actual=$(sha256sum "${target}" | cut -d' ' -f1)
    [[ "${actual}" == "${expected}" ]] && return 0
    die "${name} pins ${expected}, upstream serves ${actual}"
}

extract_appimage() {
    chmod +x "$1"
    (cd "${OPT_STAGE}" && "$1" --appimage-extract) >/dev/null
}

# Electron reaches for XWayland unless it is told otherwise, so
# the flags the manifest states are baked into the launcher.
write_launcher() {
    local name=$1 target=$2 flag
    local launcher=${LAUNCHER_DIR}/${name}
    mkdir -p "${LAUNCHER_DIR}"
    {
        printf '#!/usr/bin/env bash\n'
        printf 'exec "%s"' "${target}"
        while read -r flag; do
            [[ -z "${flag}" ]] && continue
            printf ' \\\n    %s' "${flag}"
        done < <(opt_flags "${name}")
        printf ' \\\n    "$@"\n'
    } >"${launcher}"
    chmod +x "${launcher}"
}

# The application's own entry, with the two lines that pointed
# inside the image rewritten to point at what was installed.
write_desktop_entry() {
    local name=$1 directory entry icon
    directory=$(opt_directory "${name}")
    entry=$(find "${directory}" -maxdepth 1 -name '*.desktop' |
        head -1)
    [[ -n "${entry}" ]] || die "${name} ships no desktop entry"
    icon=$(readlink -f "${directory}/.DirIcon")
    [[ -f "${icon}" ]] || die "${name} ships no icon"
    mkdir -p "${DESKTOP_DIR}"
    sed -e "s|^Exec=[^ ]*|Exec=${LAUNCHER_DIR}/${name}|" \
        -e "s|^Icon=.*|Icon=${icon}|" \
        "${entry}" >"${DESKTOP_DIR}/${name}.desktop"
}

remove_opt_entry() {
    local name=$1
    rm -rf "$(opt_directory "${name}")"
    rm -f "${LAUNCHER_DIR}/${name}" \
        "${DESKTOP_DIR}/${name}.desktop"
}
