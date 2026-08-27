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

`bootstrap.sh` stows the package into `$HOME`. Both it and
`get_packages.sh` are idempotent, so re-running either after a
pull is safe.

## Managing packages

`packages.json` is the truth about this machine, and `packages`
is the one command that acts on it. It opens the manifest in your
editor, reconciles the machine against what you saved, checks the
result, then commits and offers to push.

    packages

Reconciling means both directions. Anything declared is installed
and claimed as wanted; anything installed by hand and left
undeclared is offered for removal. Repositories, COPRs and
flatpaks follow the same rule. Two things are never touched: a
floor of base-system packages, and the endpoint agents this
machine is required to run.

Nothing is applied before you have seen it. `get_packages.sh`
prints the plan and waits:

    get_packages.sh --plan    # print the plan and stop
    get_packages.sh --yes     # apply it without asking

Claiming packages as wanted is what keeps them safe: dnf removes
anything it believes is a spare dependency, and a declared
package it has never been told about is exactly that.

Only packages dnf records as directly wanted are reconciled.
Anything that arrived as a dependency or a recommendation is
invisible to the manifest: the foot terminal came in with a Sway
config nobody asked for, and no amount of editing this file
would have removed it. Take those out by hand once and they
stay out.

The health check that follows a run reports what has drifted:
packages not yet claimed, COPRs supplying nothing, orphaned
packages, broken stowed links, and theme templates that render
for nobody.
