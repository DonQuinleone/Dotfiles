# shellcheck shell=bash

readonly NVIM_STATE_FILE="${STATE_DIR}/nvim.lua"
readonly NVIM_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
readonly NVIM_APPLY_EXPR="luaeval('require(\"donquinleone.theme\").apply()')"

declare -rA NVIM_COLOURSCHEMES=(
    [ember]="ember"
    [kanagawa-wave]="kanagawa-wave"
    [catppuccin-mocha]="catppuccin-mocha"
    [dracula]="dracula"
    [solarised-dark]="solarized"
    [solarised-light]="solarized"
    [tokyo-night]="tokyonight-night"
    [tokyo-night-storm]="tokyonight-storm"
    [rose-pine]="rose-pine-main"
    [rose-pine-moon]="rose-pine-moon"
    [rose-pine-dawn]="rose-pine-dawn"
    [gruvbox-dark]="gruvbox"
    [gruvbox-light]="gruvbox"
    [osaka-jade]="bamboo-vulgaris"
)

nvim_background() {
    if theme_is_dark; then
        printf 'dark\n'
        return
    fi
    printf 'light\n'
}

nvim_colourscheme() {
    local slug="$1"
    while [[ -z "${NVIM_COLOURSCHEMES[${slug}]:-}" ]]; do
        [[ "${slug}" == *-* ]] || return 1
        slug="${slug%-*}"
    done
    printf '%s\n' "${NVIM_COLOURSCHEMES[${slug}]}"
}

write_nvim_state() {
    local colourscheme
    colourscheme=$(nvim_colourscheme "${THEME_SLUG}") || true
    if [[ -z "${colourscheme}" ]]; then
        warn "no Neovim colourscheme mapped for ${THEME_SLUG}"
        return 1
    fi
    cat >"${NVIM_STATE_FILE}" <<EOF
return {
    colourscheme = "${colourscheme}",
    background = "$(nvim_background)",
}
EOF
}

reload_running_nvim() {
    local socket
    for socket in "${NVIM_RUNTIME_DIR}"/nvim.*; do
        [[ -S "${socket}" ]] || continue
        nvim --server "${socket}" \
            --remote-expr "${NVIM_APPLY_EXPR}" \
            >/dev/null 2>&1 || true
    done
}

apply_nvim() {
    mkdir -p "${STATE_DIR}"
    write_nvim_state || return 0
    reload_running_nvim
}
