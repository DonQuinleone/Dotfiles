# dotfiles

Personal configuration for a Fedora machine, kept as a single GNU
Stow package: a Hyprland session, the shells, the editor, the
terminals, the network-diagnosis tools and the package manifest.
A fresh machine is one clone and two commands away.

The desktop is assembled from packaged parts rather than a shell
of its own. Hyprland tiles, waybar draws the status bar, rofi is
the launcher and every menu, mako shows notifications, swaybg
paints the background, hyprlock locks and hypridle decides when.
One `theme` command recolours the lot.

## What goes where

The repository mirrors `$HOME`, so every path here lands on disk
exactly where it appears.

| Path | Holds |
| --- | --- |
| `.bashrc`, `.config/fish` | the shells |
| `.config/nvim` | the editor |
| `.config/ghostty`, `.config/kitty` | the terminals |
| `.config/git` | identity by includes, never inline |
| `.config/tmux`, `.config/lsd`, `.config/fastfetch` | the small tools |
| `.config/environment.d` | session environment |
| `.config/hypr` | the Hyprland session, lock and idle |
| `.config/waybar`, `.config/rofi` | the bar and the launcher |
| `.config/theme` | the palettes and their templates |
| `.config/systemd/user` | the session target and its daemons |
| `.local/bin`, `.local/lib/netkit` | the commands and netkit |
| `.local/share/claude` | assistant rules and skills |
| `packages.json` | the manifest for the machine |

Nothing generated is kept here. `theme` renders each template
into `~/.local/state/theme` and links the result where the tool
expects it; the few generated lines inside these configs are the
include each tool needs to find its colours. Every rendered path
is listed in `.gitignore` rather than committed, and
`bootstrap.sh` stows with `--no-folding` so a directory holding
only stowed files stays a real directory: folded, the next render
would land inside this repository.

## The desktop

Seven palettes live in `.config/theme/themes`, one file each, and
every tool that takes colour is a template beside them. `theme`
renders the set and reloads whatever is running, so a switch is
one command and no restart.

    theme list
    theme set gruvbox-dark
    theme pick

`wallpaper` works the same way over `~/Pictures/walls`, which is
kept out of the repository because it is images.

    wallpaper pick
    wallpaper random

The rest are small commands the session binds to keys:
`focus-monitor` and `send-window-to-monitor` step the screens in
position order rather than trusting a compass direction,
`keep-awake` holds an inhibitor, `power-menu`, `screenshot`,
`clipboard-history` and `keybind-help` each do the one thing they
are named for.

Monitors are stated absolutely in `.config/hypr/lua/monitors.lua`,
keyed by description rather than connector, and each screen owns a
fixed run of nine workspaces. Opening or closing the lid therefore
adds or removes one screen and moves nothing else.

The bar is waybar, one flat strip across the top of every screen
carrying only what is worth a glance: the workspaces, the time,
tailscale, the battery and the system tray. Since each screen owns
its own run, the bar labels a workspace by its slot rather than
its number, so what it shows is what `Super+N` presses.
`Super+Shift+B` hides and restores it. `tailscale-status` feeds
the tailnet module, which names the exit node in use, connects or
disconnects on a click and copies this machine's tailnet address
on a right-click.

## The netkit tools

Five network-diagnosis commands for a hosting engineer, sharing
one LuaJIT library under `.local/lib/netkit`. Each takes a single
target, renders box tables coloured only when writing to a
terminal, and grows a `--json` form for scripting. They shell out
to `dig`; individually they also need `curl`, `jq`, `openssl`,
`timeout` or bash's `/dev/tcp`, and each checks only the tools it
uses.

- `hostinfo`: the resolution chain, rDNS, ASN and prefix, abuse
  contact, IP and domain blacklists, TLS with SNI and a protocol
  matrix, DNSSEC, delegation, the zone and registration.
- `maildiag`: SPF, DMARC, MTA-STS and TLS-RPT, DKIM selectors,
  and each MX host's reverse DNS, banner, STARTTLS certificate,
  DANE and blacklists.
- `dnsdiff`: SOA serials and answers across every authoritative
  nameserver, three public resolvers and the local one, so stale
  nameservers and unpropagated changes stand out.
- `portpeek`: which hosting-relevant TCP ports accept a
  connection, with banners, including the cPanel and WHM set.
- `httpath`: the redirect chain hop by hop with status, timing,
  address and ASN, then the final server, transport and any CDN
  or WAF fronting the origin.

`hostinfo` reads optional highlight rules from
`~/.config/hostinfo/highlights.lua`, a Lua file returning a list
of `{ label, asns, patterns }` rules that tag matching networks
in its output.

## Maintaining it

`packages.json` is the only list. It names the repositories, the
COPRs, the packages, the flatpaks and which application opens
which kind of file. `get_packages.sh` renders a machine from it,
so a package installed by hand belongs in the manifest too.

File associations are stated rather than left to whichever
package registered last, because a browser claims far more than
browsing on the way in. Pages go to Firefox, documents to
Zathura, images to imv and anything that plays to mpv. A
`mailto:` goes to Firefox rather than a mail client that is not
installed, and Gmail is registered there as the handler for it,
which is also what encodes an address carrying a subject or a
body. 1Password comes from its own repository rather
than Flathub for a related reason: flatpak hands a sandboxed
application a filtered Wayland socket with the clipboard
protocols withheld, and its copy buttons fail with nothing to
fall back on.

Both scripts are idempotent, so re-running either after a pull is
safe. `bootstrap.sh` restows the package and clears away links
that no longer belong, and refuses to run unless the repo sits
directly in `$HOME`, since the symlinks are relative to that.

## Installing

Fedora 44 and GNU Stow.

    git clone \
      ssh://git@forge.example.com/user/dotfiles.git \
      ~/.dotfiles
    ~/.dotfiles/get_packages.sh
    ~/.dotfiles/bootstrap.sh
    theme set ember
