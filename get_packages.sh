#!/usr/bin/env bash
set -euo pipefail

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

# A repo that names no expiry inherits dnf's default of 48
# hours, so a release published this morning stays invisible
# until Tuesday. Fedora's own updates repo asks for six.
REPO_EXPIRY='metadata_expire=6h'

CLAUDE_CODE_REPO="[claude-code]
name=Claude Code
baseurl=https://downloads.claude.ai/claude-code/rpm/latest
enabled=1
gpgcheck=1
repo_gpgcheck=0
${REPO_EXPIRY}
gpgkey=https://downloads.claude.ai/keys/claude-code.asc"

NETBIRD_REPO="[netbird]
name=netbird
baseurl=https://pkgs.netbird.io/yum/
enabled=1
gpgcheck=1
${REPO_EXPIRY}
gpgkey=https://pkgs.netbird.io/yum/repodata/repomd.xml.key
repo_gpgcheck=1"

COPRS=(
    donquinleone/claude-desktop
    scottames/ghostty
    lionheartp/Hyprland
    errornointernet/quickshell
)

PACKAGES=(
    ansible
    bluez-tools
    bolt
    brightnessctl
    btop
    claude-code
    claude-desktop
    fastfetch
    firefox
    fish
    flatpak
    fprintd-pam
    gcr3
    ghostty
    git
    git-filter-repo
    gnupg2
    gnupg2-scdaemon
    gnupg2-smime
    golang
    greetd
    grim
    htop
    hypridle
    hyprland
    hyprland-guiutils
    hyprsunset
    ibm-plex-sans-fonts
    iio-sensor-proxy
    inotify-tools
    jetbrains-mono-fonts-all
    kvantum
    libsecret
    lsd
    mpv
    nautilus
    neovim
    netbird
    NetworkManager-l2tp
    NetworkManager-libreswan
    NetworkManager-openconnect
    NetworkManager-openvpn
    NetworkManager-pptp
    NetworkManager-tui
    NetworkManager-vpnc
    nmap
    nss-tools
    obs-studio
    openssh-askpass
    openssh-clients
    perl-rdapper
    pinentry-gnome3
    pipx
    playerctl
    qt6ct
    qt6-qtimageformats
    qt6-qtmultimedia
    qt6-qtshadertools
    qt6-qtsvg
    quickshell-git
    rbw
    rpm-build
    ShellCheck
    slurp
    stow
    switcheroo-control
    system-config-printer
    telnet
    terminus-fonts-console
    thefuck
    thunderbird
    tldr
    tree
    tuigreet
    wiremix
    wireshark
    wl-clipboard
    xdg-desktop-portal-hyprland
)

FLATHUB_URL=https://dl.flathub.org/repo/flathub.flatpakrepo

FLATPAKS=(
    com.slack.Slack
    com.yubico.yubioath
)

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

# flatpak install returns a failure for an app that is already
# there on some versions and a success on others, so the set is
# narrowed to what is missing rather than trusting either.
install_flatpaks() {
    sudo flatpak remote-add --if-not-exists flathub "$FLATHUB_URL"
    local missing=() app
    for app in "${FLATPAKS[@]}"; do
        flatpak info "$app" >/dev/null 2>&1 || missing+=("$app")
    done
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

ensure_repo claude-code "$CLAUDE_CODE_REPO"
ensure_repo netbird "$NETBIRD_REPO"

for copr in "${COPRS[@]}"; do
    say "enabling copr $copr"
    sudo dnf -y -q copr enable "$copr"
done

say "installing ${#PACKAGES[@]} packages"
sudo dnf -y install "${PACKAGES[@]}"

install_flatpaks
install_nerd_font
write_qt6ct_config

say "done"
