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
    mullvadvpn

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
    mas

echo "Cleaning up and optimising brew..."
brew cleanup
brew doctor

echo "Upgrading outdated packages..."
brew upgrade

echo "Checking for any missing dependencies..."
brew missing
