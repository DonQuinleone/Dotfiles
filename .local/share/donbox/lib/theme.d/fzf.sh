# shellcheck shell=bash

readonly FZF_OPTS_FILE="${STATE_DIR}/fzf-opts"

# shellcheck disable=SC2034 # read by name in colour_pairs
readonly -a FZF_SURFACES=(
    "fg:fgDim"
    "fg+:fg"
    "bg+:surface"
    "hl:accent"
    "hl+:accent"
    "info:fgDim"
    "border:border"
    "prompt:accent"
    "pointer:accent"
    "marker:good"
    "spinner:accentSoft"
    "header:fgDim"
)

# bg is left to the terminal so the translucency shows through.
write_fzf_opts() {
    local pairs name colour
    pairs="bg:-1"
    while IFS=$'\t' read -r name colour; do
        pairs+=",${name}:${colour}"
    done < <(colour_pairs FZF_SURFACES)
    printf -- '--color=%s\n' "${pairs}" >"${FZF_OPTS_FILE}"
}

apply_fzf() {
    mkdir -p "${STATE_DIR}"
    write_fzf_opts
}
