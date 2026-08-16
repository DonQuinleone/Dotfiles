#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR/.local/share/donbox/lib
set -euo pipefail

REPO=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
readonly REPO
readonly MANIFEST="${REPO}/packages.json"
readonly LIBRARY="${REPO}/.local/share/donbox/lib/packages.sh"

die() {
    printf 'get_packages: %s\n' "$1" >&2
    exit 1
}

say() {
    printf 'get_packages: %s\n' "$1"
}

command -v dnf >/dev/null 2>&1 || die "dnf not found"
command -v curl >/dev/null 2>&1 || die "curl not found"
sudo -v || die "sudo authentication required"

# The manifest is JSON, so its reader has to be on the machine
# before the machine can be built from it. Everything else this
# installs is named in the manifest itself.
command -v jq >/dev/null 2>&1 || {
    say "installing jq to read the manifest"
    sudo dnf -y -q install jq
}

# shellcheck source=.local/share/donbox/lib/packages.sh
source "${LIBRARY}"
manifest_require

FLATHUB_URL=https://dl.flathub.org/repo/flathub.flatpakrepo

NERD_FONT_TAG=v3.5.0
NERD_FONT_URL=https://github.com/ryanoasis/nerd-fonts
NERD_FONT_URL+=/releases/download/$NERD_FONT_TAG
NERD_FONT_URL+=/JetBrainsMono.tar.xz
FONT_DIR=$HOME/.local/share/fonts/JetBrainsMonoNerd
FONT_STAMP=$FONT_DIR/.installed-$NERD_FONT_TAG

# Rewritten when it differs rather than skipped when it exists,
# or a machine installed before a repo definition changed would
# never see the change.
ensure_repo() {
    local name=$1 content=$2
    local path=/etc/yum.repos.d/$name.repo
    [ -f "$path" ] && [ "$(cat "$path")" = "$content" ] && return 0
    say "writing repo $name"
    printf '%s\n' "$content" | sudo tee "$path" >/dev/null
}

install_repos() {
    local name
    while read -r name; do
        ensure_repo "$name" "$(repo_render "$name")"
    done < <(repo_names)
}

enable_coprs() {
    local copr
    while read -r copr; do
        say "enabling copr $copr"
        sudo dnf -y -q copr enable "$copr"
    done < <(manifest_list coprs)
}

install_packages() {
    local packages=()
    mapfile -t packages < <(manifest_list dnf)
    say "installing ${#packages[@]} packages"
    sudo dnf -y install "${packages[@]}"
}

# flatpak install returns a failure for an app that is already
# there on some versions and a success on others, so the set is
# narrowed to what is missing rather than trusting either.
install_flatpaks() {
    sudo flatpak remote-add --if-not-exists flathub "$FLATHUB_URL"
    local missing=() app
    while read -r app; do
        flatpak info "$app" >/dev/null 2>&1 || missing+=("$app")
    done < <(manifest_list flatpak)
    [ ${#missing[@]} -eq 0 ] && return 0
    say "installing ${#missing[@]} flatpaks"
    sudo flatpak install -y flathub "${missing[@]}"
}

install_nerd_font() {
    [ -f "$FONT_STAMP" ] && return 0
    say "installing JetBrains Mono Nerd Font $NERD_FONT_TAG"
    local tmp
    tmp=$(mktemp -d)
    curl -fsSL -o "$tmp/JetBrainsMono.tar.xz" "$NERD_FONT_URL"
    mkdir -p "$FONT_DIR"
    tar -xJf "$tmp/JetBrainsMono.tar.xz" -C "$FONT_DIR"
    rm -rf "$tmp"
    fc-cache -f "$FONT_DIR" >/dev/null
    touch "$FONT_STAMP"
}

# qt6ct rewrites this file itself and demands an absolute
# path to the palette, so it is generated here rather than
# tracked.
write_qt6ct_config() {
    local config=$HOME/.config/qt6ct/qt6ct.conf
    [ -f "$config" ] && return 0
    say "writing qt6ct configuration"
    mkdir -p "$(dirname "$config")"
    cat > "$config" <<EOF
[Appearance]
color_scheme_path=$HOME/.config/qt6ct/colors/current.conf
custom_palette=true
standard_dialogs=default
style=Fusion
EOF
}

install_repos
enable_coprs
install_packages
install_flatpaks
install_nerd_font
write_qt6ct_config

say "done"
