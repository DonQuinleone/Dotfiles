#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STOW_DIR="$(dirname "$REPO")"
# shellcheck source=private.sh
source "$REPO/private.sh"

die() {
    printf 'bootstrap: %s\n' "$1" >&2
    exit 1
}

command -v stow >/dev/null 2>&1 || die "GNU Stow is not installed"

[ "$STOW_DIR" = "$HOME" ] ||
    die "repo must sit directly in \$HOME, found $REPO"

# GnuPG refuses a home directory it can read at 755.
install -d -m 700 "$HOME/.local/share/gnupg"

# Stow 2.4 skips the whole package when its stow directory is also the
# target, so the repo itself is the stow directory and "." the package.
# Without --no-folding, stow turns a directory holding only
# stowed files into a link to the repo, and anything written
# there afterwards, rendered themes among them, lands in git.
# Restowing only tidies folders the package still has, so a link
# left by a file whose whole folder has gone would block the stow.
# Podman's storage is unreadable to its owner, and an unreadable
# folder elsewhere only means a dead link may survive.
find "$HOME" -xdev -path "$HOME/.local/share/containers" -prune \
    -o -xtype l \( -lname '.dotfiles/*' -o -lname '*/.dotfiles/*' \
    -o -lname '.dotfiles-priv/*' -o -lname '*/.dotfiles-priv/*' \) \
    -print -exec rm -- {} + ||
    printf 'bootstrap: some dead links may remain\n' >&2

stow --dir "$REPO" --target "$HOME" --restow --no-folding --verbose .

[ -d "$PRIVATE_REPO" ] || exit 0
stow --dir "$PRIVATE_REPO" --target "$HOME" \
    --restow --no-folding --verbose .
