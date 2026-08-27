#!/usr/bin/env bash
set -euo pipefail

readonly GREETD=/etc/greetd
readonly LOCAL_BIN=/usr/local/bin
readonly THEME_DIR=/var/lib/greeter-theme
readonly THEME_BIN=.local/bin/theme
readonly SETTLE_SECONDS=3
readonly SUPERSEDED=(hyprland.conf background.jpg
                     config.toml.before-gtkgreet
                     start-hyprland-quiet)

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

# greetd is confined to xdm_t, which may read a file labelled for
# /etc but never execute one, so the wrapper has to live where
# SELinux labels it bin_t.
install -m 755 "${REPO}/bin/start-hyprland-quiet" "$LOCAL_BIN/"

install -d -m 755 "$GREETD"
install -m 644 "${REPO}/greetd/config.toml" "$GREETD/"
install -m 644 "${REPO}/greetd/hyprland.lua" "$GREETD/"
ln -sfn "${THEME_DIR}/style.css" "${GREETD}/style.css"

for stale in "${SUPERSEDED[@]}"; do
    rm -f "${GREETD}/${stale}"
done

if command -v restorecon >/dev/null; then
    restorecon -F "${LOCAL_BIN}/start-hyprland-quiet"
fi

if [ "$(systemctl is-active greetd || true)" = active ]; then
    printf 'install: greetd is live; it takes effect at next login.\n'
    exit 0
fi

systemctl reset-failed greetd
systemctl start greetd
sleep "$SETTLE_SECONDS"
[ "$(systemctl is-active greetd || true)" = active ] ||
    die "greetd did not stay up; see journalctl -u greetd -b"
printf 'install: greeter running on vt1.\n'
