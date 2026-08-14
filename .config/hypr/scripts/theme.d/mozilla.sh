# shellcheck shell=bash

readonly MOZILLA_PROFILE_INDEX="profiles.ini"
readonly MOZILLA_CHROME_DIR="chrome"
readonly MOZILLA_CHROME_SHEET="theme.css"
readonly MOZILLA_CONTENT_SHEET="theme-content.css"
readonly MOZILLA_CONTENT_TEMPLATE="mozilla-content.css.in"
readonly MOZILLA_USER_PREFS="user.js"
readonly MOZILLA_STYLESHEET_PREF=\
"toolkit.legacyUserProfileCustomizations.stylesheets"

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

mozilla_theme_app() {
    local template="$1" root
    shift
    for root in "$@"; do
        [[ -f "${root}/${MOZILLA_PROFILE_INDEX}" ]] || continue
        mozilla_theme_root "${root}" "${template}"
    done
}
