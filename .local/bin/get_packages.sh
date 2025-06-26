#!/usr/bin/env bash

if ! command -v brew &> /dev/null; then
    echo "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" && echo "Homebrew installed."
    # Add Homebrew to PATH if it was just installed
    if [[ -d /opt/homebrew/bin ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -d /usr/local/bin ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
fi


echo "Installing cask packages..."
brew install --cask \
    librewolf \
    bitwarden \
    ente-auth \
    thunderbird \
    veracrypt \
    ghostty \
    cryptomator \
    nextcloud \
    gpg-suite \
    keepingyouawake \
    hammerspoon \
    discord \
    microsoft-teams \
    microsoft-office \
    zoom \
    loopback \
    vlc \
    dropbox \
    openaudible \
    spotify \
    clipy \
    rectangle \
    steam \
    minecraft \
    keymapp \
    hiddenbar \
    mullvadvpn \
    slack \
    1password \
    appcleaner \
    whatsapp

echo "Installing non-cask packages..."
brew install \
    neovim \
    mpv \
    most \
    lsd \
    hugo \
    cyberduck \
    tlrc \          #TLDR
    fastfetch \
    mas \
    nmap \
    git-filter-repo \
    tree

echo "Installing App Store packages..."
mas install \
    497799835 # Xcode
    937984704 # Amphetamine

echo "Cleaning up and optimising brew..."
brew cleanup
brew doctor

echo "Upgrading outdated packages..."
brew upgrade

echo "Checking for any missing dependencies..."
brew missing
