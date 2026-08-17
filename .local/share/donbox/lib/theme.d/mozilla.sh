# shellcheck shell=bash

readonly MOZILLA_PROFILE_INDEX="profiles.ini"
readonly MOZILLA_CHROME_DIR="chrome"
readonly MOZILLA_CHROME_SHEET="theme.css"
readonly MOZILLA_CONTENT_SHEET="theme-content.css"
readonly MOZILLA_CONTENT_TEMPLATE="mozilla-content.css.in"
readonly MOZILLA_USER_PREFS="user.js"
readonly MOZILLA_STYLESHEET_PREF=\
"toolkit.legacyUserProfileCustomizations.stylesheets"
readonly MOZILLA_LOADER_CONFIG="mozilla-theme.cfg"
readonly MOZILLA_LOADER_PREFS="mozilla-autoconfig.js"
readonly MOZILLA_INSTALLED_PREFS="defaults/pref/autoconfig.js"
readonly MOZILLA_LOADER_INSTALLER="donbox install mozilla theme"
readonly MOZILLA_LOADER_STAMP="${STATE_DIR}/mozilla-loader"

declare -rA MOZILLA_INSTALL_ROOTS=(
    [firefox]="/usr/lib64/firefox /usr/lib/firefox"
)

mozilla_apps() {
    printf '%s\n' "${!MOZILLA_INSTALL_ROOTS[@]}"
}

mozilla_install_dir() {
    local candidates directory
    read -r -a candidates <<<"${MOZILLA_INSTALL_ROOTS[$1]:-}"
    for directory in "${candidates[@]}"; do
        [[ -d "${directory}" ]] || continue
        printf '%s\n' "${directory}"
        return
    done
}

mozilla_loader_files() {
    printf '%s\t%s\n' \
        "${TEMPLATE_DIR}/${MOZILLA_LOADER_CONFIG}" \
        "$1/${MOZILLA_LOADER_CONFIG}"
    printf '%s\t%s\n' \
        "${TEMPLATE_DIR}/${MOZILLA_LOADER_PREFS}" \
        "$1/${MOZILLA_INSTALLED_PREFS}"
}

mozilla_loader_installed() {
    local source target
    while IFS=$'\t' read -r source target; do
        cmp -s "${source}" "${target}" || return 1
    done < <(mozilla_loader_files "$1")
}

mozilla_report_loader() {
    local app="$1" directory stamp
    stamp="${MOZILLA_LOADER_STAMP}-${app}"
    directory=$(mozilla_install_dir "${app}")
    if [[ -n "${directory}" ]] &&
        mozilla_loader_installed "${directory}"; then
        rm -f "${stamp}"
        return
    fi
    if [[ -e "${stamp}" ]]; then
        return
    fi
    : >"${stamp}"
    warn "${app} restyles only at launch:" \
        "run ${MOZILLA_LOADER_INSTALLER}"
}

mozilla_profile_paths() {
    local root="$1"
    awk -v root="${root}" -F= '
        /^\[/ { relative = 1; next }
        $1 == "IsRelative" { relative = ($2 == "1") }
        $1 == "Path" {
            print relative ? root "/" $2 : $2
        }
    ' "${root}/${MOZILLA_PROFILE_INDEX}"
}

mozilla_prepend_line() {
    local file="$1" line="$2" target
    target=$(mktemp "${file}.XXXXXX")
    printf '%s\n' "${line}" >"${target}"
    if [[ -f "${file}" ]]; then
        grep -vxF "${line}" "${file}" >>"${target}" || true
    fi
    mv "${target}" "${file}"
}

mozilla_set_user_pref() {
    local file="$1" pref="$2" value="$3" target
    target=$(mktemp "${file}.XXXXXX")
    if [[ -f "${file}" ]]; then
        grep -vF "\"${pref}\"" "${file}" >"${target}" || true
    fi
    printf 'user_pref("%s", %s);\n' "${pref}" "${value}" \
        >>"${target}"
    mv "${target}" "${file}"
}

mozilla_write_profile() {
    local profile="$1" template="$2"
    local chrome="${profile}/${MOZILLA_CHROME_DIR}"
    mkdir -p "${chrome}"
    render_template "${TEMPLATE_DIR}/${template}" \
        "${chrome}/${MOZILLA_CHROME_SHEET}" \
        "scheme=$(light_or_dark)"
    render_template "${TEMPLATE_DIR}/${MOZILLA_CONTENT_TEMPLATE}" \
        "${chrome}/${MOZILLA_CONTENT_SHEET}"
    mozilla_prepend_line "${chrome}/userChrome.css" \
        "@import url(\"${MOZILLA_CHROME_SHEET}\");"
    mozilla_prepend_line "${chrome}/userContent.css" \
        "@import url(\"${MOZILLA_CONTENT_SHEET}\");"
    mozilla_set_user_pref "${profile}/${MOZILLA_USER_PREFS}" \
        "${MOZILLA_STYLESHEET_PREF}" true
}

mozilla_theme_root() {
    local root="$1" template="$2" profile themed=0
    while read -r profile; do
        [[ -d "${profile}" ]] || continue
        mozilla_write_profile "${profile}" "${template}"
        themed=1
    done < <(mozilla_profile_paths "${root}")
    ((themed == 1)) ||
        warn "no usable profile in ${root}/${MOZILLA_PROFILE_INDEX}"
}

mozilla_app_profiles() {
    local root profile
    for root in "$@"; do
        [[ -f "${root}/${MOZILLA_PROFILE_INDEX}" ]] || continue
        while read -r profile; do
            [[ -d "${profile}" ]] || continue
            printf '%s\n' "${profile}"
        done < <(mozilla_profile_paths "${root}")
    done
}

mozilla_theme_app() {
    local app="$1" template="$2" root found=0
    shift 2
    for root in "$@"; do
        [[ -f "${root}/${MOZILLA_PROFILE_INDEX}" ]] || continue
        mozilla_theme_root "${root}" "${template}"
        found=1
    done
    ((found == 1)) || return 0
    mozilla_report_loader "${app}"
}
