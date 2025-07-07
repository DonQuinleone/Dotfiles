#!/usr/bin/env bash

echo "Installing cask packages..."
brew install --cask \
    librewolf \
    bitwarden \
    ente-auth \
    thunderbird \
    veracrypt \
    ghostty \
    lulu \
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
    qlab \
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
