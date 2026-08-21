#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STOW_DIR="$(dirname "$REPO")"
GENERATED="${XDG_STATE_HOME:-$HOME/.local/state}/donbox/current"

# Applications that read only from a path of their own choosing,
# rather than one that can be given to them.
LINKS=(
    "lsd-colors.yaml:$HOME/.config/lsd/colors.yaml"
    "fastfetch.jsonc:$HOME/.config/fastfetch/config.jsonc"
    "fish_variables:$HOME/.config/fish/fish_variables"
)

die() {
    printf 'bootstrap: %s\n' "$1" >&2
    exit 1
}

command -v stow >/dev/null 2>&1 || die "GNU Stow is not installed"

[ "$STOW_DIR" = "$HOME" ] ||
    die "repo must sit directly in \$HOME, found $REPO"

# The wallpapers live in their own repository, so a fresh clone
# has an empty directory here until it is populated.
git -C "$REPO" submodule update --init --recursive

# Stow folds a directory that does not exist yet into a link to
# the repo, and GnuPG refuses a home directory it can read at 755.
install -d -m 700 "$HOME/.local/share/gnupg"

# Runs before the links are laid down, since it is what clears
# the old copies out of their way.
"$REPO/.local/bin/donbox" migrate

install -d "$GENERATED"

# A directory left empty here would be folded away by stow, and
# the generated file would land in the working tree.
for link in "${LINKS[@]}"; do
    target="${link#*:}"
    parent="$(dirname "$target")"
    [ ! -L "$parent" ] || rm -- "$parent"
    install -d "$parent"
    ln -sfn "$GENERATED/${link%%:*}" "$target"
done

# Stow 2.4 skips the whole package when its stow directory is also the
# target, so the repo itself is the stow directory and "." the package.
stow --dir "$REPO" --target "$HOME" --restow --verbose .
