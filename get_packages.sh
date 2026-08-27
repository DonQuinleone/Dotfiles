#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR
set -euo pipefail

REPO=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
readonly REPO
readonly MANIFEST="${REPO}/packages.json"
readonly LIBRARY="${REPO}/packages.sh"

readonly FLATHUB_URL=https://dl.flathub.org/repo/flathub.flatpakrepo
readonly NERD_FONT_TAG=v3.5.0
NERD_FONT_URL=https://github.com/ryanoasis/nerd-fonts
NERD_FONT_URL+=/releases/download/${NERD_FONT_TAG}/JetBrainsMono.tar.xz
readonly NERD_FONT_URL
readonly FONT_DIR=${HOME}/.local/share/fonts/JetBrainsMonoNerd
readonly FONT_STAMP=${FONT_DIR}/.installed-${NERD_FONT_TAG}

assume_yes=0
plan_only=0

die() {
    printf 'get_packages: %s\n' "$1" >&2
    exit 1
}

say() {
    printf 'get_packages: %s\n' "$1"
}

usage() {
    cat <<'EOF'
usage: get_packages.sh [--yes] [--plan]

Reconciles the machine against packages.json: adds what is
declared, removes what is not, and reports what it will do
before doing it.

  --yes    apply without asking
  --plan   show the plan and exit
EOF
}

parse_arguments() {
    local argument
    for argument in "$@"; do
        case "${argument}" in
            --yes) assume_yes=1 ;;
            --plan) plan_only=1 ;;
            -h | --help) usage; exit 0 ;;
            *) usage >&2; die "unknown argument ${argument}" ;;
        esac
    done
}

preflight() {
    command -v dnf >/dev/null 2>&1 || die "dnf not found"
    command -v curl >/dev/null 2>&1 || die "curl not found"
    command -v flatpak >/dev/null 2>&1 || die "flatpak not found"
    # The manifest is JSON, so its reader has to be on the machine
    # before the machine can be built from it.
    command -v jq >/dev/null 2>&1 || {
        say "installing jq to read the manifest"
        sudo dnf -y -q install jq
    }
}

validate() {
    local duplicates missing
    duplicates=$(manifest_duplicates)
    [[ -z "${duplicates}" ]] ||
        die "duplicated entries:"$'\n'"${duplicates}"
    missing=$(unknown_packages)
    [[ -z "${missing}" ]] ||
        die "not in any enabled repo:"$'\n'"${missing}"
}

# Only what is about to be installed is checked, since a package
# already on the machine is proof enough that it once existed.
unknown_packages() {
    ((${#PACKAGE_ADD[@]} > 0)) || return 0
    local known name
    known=$(dnf repoquery --qf '%{name}\n' "${PACKAGE_ADD[@]}" \
        2>/dev/null | LC_ALL=C sort -u)
    for name in "${PACKAGE_ADD[@]}"; do
        grep -qxF "${name}" <<<"${known}" ||
            printf '  %s\n' "${name}"
    done
}

declare -a REPO_WRITE=() COPR_ADD=() COPR_DROP=()
declare -a PACKAGE_ADD=() PACKAGE_DROP=() PACKAGE_MARK=()
declare -a FLATPAK_ADD=() FLATPAK_DROP=()
declare -a PACKAGE_HELD=()

# Rewritten when it differs rather than skipped when it exists,
# or a machine installed before a repo definition changed would
# never see the change.
plan_repos() {
    local name path
    while read -r name; do
        path=/etc/yum.repos.d/${name}.repo
        [[ -f "${path}" ]] &&
            [[ "$(cat "${path}")" == "$(repo_render "${name}")" ]] &&
            continue
        REPO_WRITE+=("${name}")
    done < <(repo_names)
}

plan_coprs() {
    local declared enabled name
    declared=$(manifest_list coprs | LC_ALL=C sort -u)
    enabled=$(enabled_coprs)
    while read -r name; do
        [[ -z "${name}" ]] && continue
        grep -qxF "${name}" <<<"${enabled}" || COPR_ADD+=("${name}")
    done <<<"${declared}"
    while read -r name; do
        [[ -z "${name}" ]] && continue
        grep -qxF "${name}" <<<"${declared}" || COPR_DROP+=("${name}")
    done <<<"${enabled}"
}

plan_packages() {
    local declared wanted name
    declared=$(manifest_packages_sorted)
    wanted=$(installed_wanted_packages)
    while read -r name; do
        [[ -z "${name}" ]] && continue
        if ! package_installed "${name}"; then
            PACKAGE_ADD+=("${name}")
        elif ! grep -qxF "${name}" <<<"${wanted}"; then
            PACKAGE_MARK+=("${name}")
        fi
    done <<<"${declared}"
    while read -r name; do
        [[ -z "${name}" ]] && continue
        grep -qxF "${name}" <<<"${declared}" && continue
        package_protected "${name}" && continue
        PACKAGE_DROP+=("${name}")
    done <<<"${wanted}"
}

plan_flatpaks() {
    local declared installed name
    declared=$(manifest_list flatpak | LC_ALL=C sort -u)
    installed=$(installed_flatpak_apps)
    while read -r name; do
        [[ -z "${name}" ]] && continue
        grep -qxF "${name}" <<<"${installed}" ||
            FLATPAK_ADD+=("${name}")
    done <<<"${declared}"
    while read -r name; do
        [[ -z "${name}" ]] && continue
        grep -qxF "${name}" <<<"${declared}" ||
            FLATPAK_DROP+=("${name}")
    done <<<"${installed}"
}

# dnf takes everything that depends on a package out with it, so
# a leaf something still needs is not the manifest's to remove.
# perl-Unicode-Normalize on its own would have taken git.
hold_depended_upon() {
    ((${#PACKAGE_DROP[@]} > 0)) || return 0
    local name kept=()
    for name in "${PACKAGE_DROP[@]}"; do
        if [[ -n "$(dnf repoquery --installed --whatrequires \
            "${name}" 2>/dev/null)" ]]; then
            PACKAGE_HELD+=("${name}")
        else
            kept+=("${name}")
        fi
    done
    PACKAGE_DROP=("${kept[@]}")
}

build_plan() {
    plan_repos
    plan_coprs
    plan_packages
    plan_flatpaks
    hold_depended_upon
}

plan_is_empty() {
    (( ${#REPO_WRITE[@]} + ${#COPR_ADD[@]} + ${#COPR_DROP[@]} +
       ${#PACKAGE_ADD[@]} + ${#PACKAGE_DROP[@]} +
       ${#PACKAGE_MARK[@]} + ${#FLATPAK_ADD[@]} +
       ${#FLATPAK_DROP[@]} == 0 ))
}

section() {
    local label=$1
    shift
    (($# > 0)) || return 0
    printf '\n  %s\n' "${label}"
    printf '    %s\n' "$@"
}

render_plan() {
    printf '\nplan against %s\n' "${MANIFEST#"${HOME}"/}"
    section "write repo" "${REPO_WRITE[@]}"
    section "enable copr" "${COPR_ADD[@]}"
    section "remove copr" "${COPR_DROP[@]}"
    section "install" "${PACKAGE_ADD[@]}"
    section "remove" "${PACKAGE_DROP[@]}"
    section "install flatpak" "${FLATPAK_ADD[@]}"
    section "remove flatpak" "${FLATPAK_DROP[@]}"
    section "claim as wanted" "${PACKAGE_MARK[@]}"
    section "held, something still needs it" "${PACKAGE_HELD[@]}"
    printf '\n'
}

confirm() {
    ((assume_yes == 0)) || return 0
    local reply=""
    read -r -p "apply this plan? [y/N] " reply || true
    [[ "${reply}" == [yY] ]]
}

apply_repos() {
    local name
    for name in "${REPO_WRITE[@]}"; do
        say "writing repo ${name}"
        repo_render "${name}" |
            sudo tee "/etc/yum.repos.d/${name}.repo" >/dev/null
    done
}

apply_copr_adds() {
    local name
    for name in "${COPR_ADD[@]}"; do
        say "enabling copr ${name}"
        sudo dnf -y -q copr enable "${name}"
    done
}

apply_copr_drops() {
    local name
    for name in "${COPR_DROP[@]}"; do
        say "removing copr ${name}"
        sudo dnf -y -q copr remove "${name}"
    done
}

# Claimed before anything is removed, so the sweep that follows a
# removal cannot decide a declared package was only ever a
# dependency and take it too.
apply_marks() {
    ((${#PACKAGE_MARK[@]} > 0)) || return 0
    say "claiming ${#PACKAGE_MARK[@]} packages as wanted"
    sudo dnf mark user "${PACKAGE_MARK[@]}"
}

apply_installs() {
    ((${#PACKAGE_ADD[@]} > 0)) || return 0
    say "installing ${#PACKAGE_ADD[@]} packages"
    sudo dnf -y install "${PACKAGE_ADD[@]}"
}

apply_removals() {
    ((${#PACKAGE_DROP[@]} > 0)) || return 0
    say "removing ${#PACKAGE_DROP[@]} packages"
    sudo dnf -y remove "${PACKAGE_DROP[@]}"
}

apply_flatpak_adds() {
    sudo flatpak remote-add --if-not-exists flathub "${FLATHUB_URL}"
    ((${#FLATPAK_ADD[@]} > 0)) || return 0
    say "installing ${#FLATPAK_ADD[@]} flatpaks"
    sudo flatpak install -y flathub "${FLATPAK_ADD[@]}"
}

apply_flatpak_drops() {
    ((${#FLATPAK_DROP[@]} > 0)) || return 0
    say "removing ${#FLATPAK_DROP[@]} flatpaks"
    sudo flatpak uninstall -y "${FLATPAK_DROP[@]}"
    sudo flatpak uninstall -y --unused
}

# Brave and Rhythmbox both claim types they are not wanted for
# the moment they are installed, so the association is stated
# here rather than left to whichever package registered last.
set_defaults() {
    local app type changed=0
    while read -r app; do
        while read -r type; do
            [[ "$(xdg-mime query default "${type}")" == "${app}" ]] &&
                continue
            xdg-mime default "${app}" "${type}"
            changed=$((changed + 1))
        done < <(default_types "${app}")
    done < <(default_apps)
    ((changed == 0)) ||
        say "pointed ${changed} types at their application"
}

install_nerd_font() {
    [[ -f "${FONT_STAMP}" ]] && return 0
    say "installing JetBrains Mono Nerd Font ${NERD_FONT_TAG}"
    local temporary
    temporary=$(mktemp -d)
    curl -fsSL -o "${temporary}/JetBrainsMono.tar.xz" "${NERD_FONT_URL}"
    mkdir -p "${FONT_DIR}"
    tar -xJf "${temporary}/JetBrainsMono.tar.xz" -C "${FONT_DIR}"
    rm -rf "${temporary}"
    fc-cache -f "${FONT_DIR}" >/dev/null
    touch "${FONT_STAMP}"
}

# qt6ct rewrites this file itself and demands an absolute path to
# the palette, so it is generated here rather than tracked.
write_qt6ct_config() {
    local config=${HOME}/.config/qt6ct/qt6ct.conf
    [[ -f "${config}" ]] && return 0
    say "writing qt6ct configuration"
    mkdir -p "$(dirname "${config}")"
    cat >"${config}" <<EOF
[Appearance]
color_scheme_path=${HOME}/.config/qt6ct/colors/current.conf
custom_palette=true
standard_dialogs=default
style=Fusion
EOF
}

apply_plan() {
    apply_repos
    apply_copr_adds
    apply_marks
    apply_installs
    apply_flatpak_adds
    apply_removals
    apply_flatpak_drops
    apply_copr_drops
}

main() {
    parse_arguments "$@"
    preflight
    # shellcheck source=packages.sh
    source "${LIBRARY}"
    manifest_require
    build_plan
    validate
    render_plan

    ((plan_only == 0)) || exit 0
    if plan_is_empty; then
        say "already in sync"
    else
        confirm || die "nothing applied"
        sudo -v || die "sudo authentication required"
        apply_plan
    fi

    set_defaults
    install_nerd_font
    write_qt6ct_config
    say "done"
}

main "$@"
