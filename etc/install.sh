#!/usr/bin/env bash
set -euo pipefail

readonly GREETD=/etc/greetd
readonly THEME_DIR=/var/lib/greeter-theme
readonly THEME_BIN=.local/bin/theme
readonly SUPERSEDED=(hyprland.conf background.jpg
                     config.toml.before-gtkgreet)

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO

die() {
    printf 'install: %s\n' "$1" >&2
    exit 1
}

[ "$(id -u)" -eq 0 ] || die "must run as root"

owner="${SUDO_USER:-}"
[ -n "$owner" ] || die "SUDO_USER is unset; run this through sudo"
home="$(getent passwd "$owner" | cut -d: -f6)" ||
    die "no such user: $owner"
theme="${home}/${THEME_BIN}"
[ -x "$theme" ] || die "no theme tool at ${theme}"

install -d -m 755 -o "$owner" -g "$owner" "$THEME_DIR"

current="$(runuser -u "$owner" -- "$theme" current)"
[ "$current" != none ] ||
    die "no theme selected; run 'theme set <name>' first"
runuser -u "$owner" -- "$theme" set "$current"

install -d -m 755 "$GREETD"
install -m 644 "${REPO}/greetd/config.toml" "$GREETD/"
install -m 644 "${REPO}/greetd/hyprland.lua" "$GREETD/"
install -m 755 "${REPO}/greetd/start-hyprland-quiet" "$GREETD/"
ln -sfn "${THEME_DIR}/style.css" "${GREETD}/style.css"

for stale in "${SUPERSEDED[@]}"; do
    rm -f "${GREETD}/${stale}"
done

printf 'install: greetd updated; it takes effect at next login.\n'
