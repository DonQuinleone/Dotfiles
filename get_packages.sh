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

CLAUDE_CODE_REPO='[claude-code]
name=Claude Code
baseurl=https://downloads.claude.ai/claude-code/rpm/latest
enabled=1
gpgcheck=1
repo_gpgcheck=0
gpgkey=https://downloads.claude.ai/keys/claude-code.asc'

NETBIRD_REPO='[netbird]
name=netbird
baseurl=https://pkgs.netbird.io/yum/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.netbird.io/yum/repodata/repomd.xml.key
repo_gpgcheck=1'

COPRS=(
    donquinleone/claude-desktop
    scottames/ghostty
    lionheartp/Hyprland
    errornointernet/quickshell
)

PACKAGES=(
    NetworkManager-tui
    ShellCheck
    ansible
    brightnessctl
    btop
    claude-code
    claude-desktop
    fastfetch
    firefox
    fprintd-pam
    gcr3
    ghostty
    git
    gnupg2
    golang
    greetd
    grim
    htop
    inotify-tools
    hypridle
    hyprland
    hyprland-guiutils
    hyprsunset
    ibm-plex-sans-fonts
    jetbrains-mono-fonts-all
    libsecret
    lsd
    mpv
    nautilus
    neovim
    netbird
    nmap
    obs-studio
    openssh-clients
    pinentry-gnome3
    pipx
    playerctl
    kvantum
    qt6-qtimageformats
    qt6-qtmultimedia
    qt6-qtshadertools
    qt6-qtsvg
    qt6ct
    quickshell-git
    rbw
    slurp
    stow
    terminus-fonts-console
    thunderbird
    tldr
    tree
    tuigreet
    wiremix
    wireshark
    wl-clipboard
    xdg-desktop-portal-hyprland
)

NERD_FONT_TAG=v3.5.0
NERD_FONT_URL=https://github.com/ryanoasis/nerd-fonts
NERD_FONT_URL+=/releases/download/$NERD_FONT_TAG
NERD_FONT_URL+=/JetBrainsMono.tar.xz
FONT_DIR=$HOME/.local/share/fonts/JetBrainsMonoNerd
FONT_STAMP=$FONT_DIR/.installed-$NERD_FONT_TAG

ensure_repo() {
    local name=$1 content=$2
    local path=/etc/yum.repos.d/$name.repo
    [ -f "$path" ] && return 0
    say "adding repo $name"
    printf '%s\n' "$content" | sudo tee "$path" >/dev/null
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

install_nerd_font
write_qt6ct_config

say "done"
