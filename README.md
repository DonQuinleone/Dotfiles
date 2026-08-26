# dotfiles

Personal configuration for a Fedora machine, kept as a single GNU
Stow package that mirrors `$HOME`: a Hyprland session, the shells,
the editor, the terminal, the network-diagnosis tools and the
package manifest the machine is built from.

## Installing

Fedora 44 and GNU Stow.

    git clone \
      ssh://git@forge.example.com/user/dotfiles.git \
      ~/.dotfiles
    ~/.dotfiles/get_packages.sh
    ~/.dotfiles/bootstrap.sh
    theme set ember

`get_packages.sh` renders the machine from `packages.json` and
`bootstrap.sh` stows the package into `$HOME`. Both are
idempotent, so re-running either after a pull is safe.
