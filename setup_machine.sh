#!/usr/bin/env bash

if ! command -v brew &> /dev/null; then
  echo "Homebrew not found. Installing..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo "Homebrew is already installed."
fi

echo "Installing GNU Stow..."
/opt/homebrew/bin/brew install stow

echo "Stowing dotfiles..."
cd ~/.dotfiles
/opt/homebrew/bin/stow .

echo "Installing packages..."
chmod +x $HOME/.local/bin/get_packages.sh && bash $HOME/.local/bin/get_packages.sh

echo "Switching to Bash..."
chsh -s '/bin/bash'
