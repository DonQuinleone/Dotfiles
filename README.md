# dotfiles

Personal configuration for a Fedora machine, kept as a single GNU
Stow package that mirrors `$HOME`: a Hyprland session, the shells,
the editor, the terminal, the network-diagnosis tools and the
package manifest the machine is built from.

## Installing

Fedora 44 and GNU Stow.

    git clone git@github.com:DonQuinleone/Dotfiles.git ~/.dotfiles
    ~/.dotfiles/get_packages.sh
    ~/.dotfiles/bootstrap.sh
    theme set ember
    sudo ~/.dotfiles/etc/install.sh

`bootstrap.sh` stows the package into `$HOME`, then stows a
private companion repo on top when one is cloned to
`~/.dotfiles-priv`. Clone that first, since `get_packages.sh`
reads the packages it must never remove from it. Both scripts
are idempotent, so re-running either after a pull is safe.

`etc/install.sh` is the one step that needs root, and the only
part of the repo that is not stowed: it installs the greeter's
config into `/etc/greetd`, its session wrapper into
`/usr/local/bin`, and creates the directory the greeter reads
its colours and wallpaper from, since greetd runs as its own
user and cannot reach `$HOME`. It wants a theme already chosen
and is idempotent as well. A live greeter is left alone and
picks the change up at the next login; a stopped one is
started.

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

Software that ships as neither an rpm nor a flatpak is declared
under `opt`, where each entry names the `format` it arrives in.
An `appimage` is extracted into `~/.local/opt` and gets a
launcher in `~/.local/bin` and its own desktop entry, rewritten
to point at both. ClickUp is one: an AppImage served from a URL
that always hands back the current release, so the entry pins a
version and a sha256 and the install refuses anything else,
which is also how a new release announces itself. A `binary` is
a command-line tool, downloaded either bare or as a tar.gz with
one executable inside, and gets the same directory and launcher
but no desktop entry. An entry marked `"managed": false` is declared
only so the sweep of `~/.local/opt` leaves it alone, which is how
TeamSpeak, installed by hand long before any of this, survives.

Nothing is applied before you have seen it. Both commands print
the plan and wait:

    packages --plan           # look, change nothing
    packages --yes            # reconcile without confirming
    packages --help           # what the flags do

    get_packages.sh --plan    # the reconciler on its own
    get_packages.sh --yes

`packages --plan` opens no editor and commits nothing, so it is
the one to reach for when you only want to know where the
machine stands.

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
packages not yet claimed, COPRs supplying nothing, opt entries
an upstream release has left behind, orphaned packages, broken
stowed links, and theme templates that render for nobody.
