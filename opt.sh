# shellcheck shell=bash

readonly OPT_STAGE=${OPT_ROOT}/.stage
readonly LAUNCHER_DIR=${HOME}/.local/bin
readonly DESKTOP_DIR=${HOME}/.local/share/applications

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
    write_launcher "${name}"
    write_desktop_entry "${name}"
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
    local name=$1 flag
    local launcher=${LAUNCHER_DIR}/${name}
    mkdir -p "${LAUNCHER_DIR}"
    {
        printf '#!/usr/bin/env bash\n'
        printf 'exec "%s/AppRun"' "$(opt_directory "${name}")"
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
