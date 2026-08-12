#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STOW_DIR="$(dirname "$REPO")"
PACKAGE="$(basename "$REPO")"

die() {
    printf 'bootstrap: %s\n' "$1" >&2
    exit 1
}

command -v stow >/dev/null 2>&1 || die "GNU Stow is not installed"

[ "$STOW_DIR" = "$HOME" ] ||
    die "repo must sit directly in \$HOME, found $REPO"

stow --dir "$STOW_DIR" --target "$HOME" --restow --verbose "$PACKAGE"
