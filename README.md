# dotfiles

My Fedora 44 desktop, kept as a GNU Stow package that mirrors
`$HOME`: a Hyprland session, the shells, editor and terminal, a set
of network-diagnosis tools, and the package manifest the machine is
built from. Private settings live in a separate repo that is stowed
on top when it is present.

## Installation

    git clone https://github.com/DonQuinleone/Dotfiles.git ~/.dotfiles
    ~/.dotfiles/get_packages.sh
    ~/.dotfiles/bootstrap.sh
    theme set ember
    sudo ~/.dotfiles/etc/install.sh

With access to the private repo, clone it before running
`get_packages.sh`, which reads the packages it must never remove
from it:

    git clone git@github.com:DonQuinleone/Dotfiles-Priv.git \
      ~/.dotfiles-priv

Every step is idempotent, so re-running one after a pull is safe.
`etc/install.sh` is the only part that needs root: it installs the
greeter, which cannot read `$HOME`.

## Contributing

Issues and pull requests are welcome at
<https://github.com/DonQuinleone/Dotfiles>. Commit messages follow
[Conventional Commits](https://www.conventionalcommits.org), shell
scripts pass `shellcheck`, and Hyprland changes pass
`Hyprland --verify-config`.
