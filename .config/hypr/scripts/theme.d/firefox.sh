# shellcheck shell=bash

readonly FIREFOX_ROOTS=(
    "${CONFIG_HOME}/mozilla/firefox"
    "${HOME}/.mozilla/firefox"
)
readonly FIREFOX_PROFILE_INDEX="profiles.ini"
readonly FIREFOX_CHROME_DIR="chrome"
readonly FIREFOX_CHROME_SHEET="theme.css"
readonly FIREFOX_CONTENT_SHEET="theme-content.css"
readonly FIREFOX_USER_PREFS="user.js"
readonly FIREFOX_STYLESHEET_PREF=\
"toolkit.legacyUserProfileCustomizations.stylesheets"

firefox_profile_paths() {
    local root="$1"
    awk -v root="${root}" -F= '
        /^\[/ { relative = 1; next }
        $1 == "IsRelative" { relative = ($2 == "1") }
        $1 == "Path" {
            print relative ? root "/" $2 : $2
        }
    ' "${root}/${FIREFOX_PROFILE_INDEX}"
}

prepend_line() {
    local file="$1" line="$2" target
    target=$(mktemp "${file}.XXXXXX")
    printf '%s\n' "${line}" >"${target}"
    if [[ -f "${file}" ]]; then
        grep -vxF "${line}" "${file}" >>"${target}" || true
    fi
    mv "${target}" "${file}"
}

append_user_pref() {
    local file="$1" pref="$2" value="$3" target
    target=$(mktemp "${file}.XXXXXX")
    if [[ -f "${file}" ]]; then
        grep -vF "\"${pref}\"" "${file}" >"${target}" || true
    fi
    printf 'user_pref("%s", %s);\n' "${pref}" "${value}" \
        >>"${target}"
    mv "${target}" "${file}"
}

write_firefox_stylesheets() {
    local profile="$1" chrome="$1/${FIREFOX_CHROME_DIR}"
    mkdir -p "${chrome}"
    render_template "${TEMPLATE_DIR}/firefox-chrome.css.in" \
        "${chrome}/${FIREFOX_CHROME_SHEET}" \
        "scheme=$(light_or_dark)"
    render_template "${TEMPLATE_DIR}/firefox-content.css.in" \
        "${chrome}/${FIREFOX_CONTENT_SHEET}"
    prepend_line "${chrome}/userChrome.css" \
        "@import url(\"${FIREFOX_CHROME_SHEET}\");"
    prepend_line "${chrome}/userContent.css" \
        "@import url(\"${FIREFOX_CONTENT_SHEET}\");"
    append_user_pref "${profile}/${FIREFOX_USER_PREFS}" \
        "${FIREFOX_STYLESHEET_PREF}" true
}

theme_firefox_root() {
    local root="$1" profile themed=0
    while read -r profile; do
        [[ -d "${profile}" ]] || continue
        write_firefox_stylesheets "${profile}"
        themed=1
    done < <(firefox_profile_paths "${root}")
    ((themed == 1)) ||
        warn "no usable profile in ${root}/${FIREFOX_PROFILE_INDEX}"
}

apply_firefox() {
    local root
    for root in "${FIREFOX_ROOTS[@]}"; do
        [[ -f "${root}/${FIREFOX_PROFILE_INDEX}" ]] || continue
        theme_firefox_root "${root}"
    done
}
