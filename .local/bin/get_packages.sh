#!/usr/bin/env bash

echo "Installing cask packages..."
brew install --cask \
    librewolf \
    bitwarden \
    thunderbird \
    ghostty \
    discord \
    microsoft-teams \
    microsoft-office \
    zoom \
    loopback \
    vlc \
    ente-auth \
    cryptomator \
    nextcloud \
    gpg-suite \
    dropbox \
    openaudible \
    spotify \
    clipy \
    rectangle \
    keepingyouawake \
    hammerspoon \
    steam \
    minecraft \
    keymapp \
    hiddenbar \
    mullvadvpn \
    slack \
    1password \
    appcleaner

echo "Installing non-cask packages..."
brew install \
    neovim \
    mpv \
    most \
    lsd \
    hugo \
    cyberduck \
    tlrc \
    fastfetch \
    mas \
    nmap \
    git-filter-repo

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
