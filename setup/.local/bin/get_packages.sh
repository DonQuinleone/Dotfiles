#!/usr/bin/env bash

if ! command -v brew &> /dev/null; then
  echo "Homebrew not found. Installing..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo "Homebrew is already installed."
fi

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
  hammerspoon \
  steam \
  minecraft

echo "Installing non-cask packages..."
brew install \
  neovim \
  mpv \
  stow \
  most \
  lsd \
  hugo \
  cyberduck

echo "Cleaning up and optimising brew..."
brew cleanup
brew doctor

echo "Upgrading outdated packages..."
brew upgrade

echo "Checking for any missing dependencies..."
brew missing
