# dotfiles

Personal configuration for a Fedora machine, kept as a single GNU
Stow package. The desktop itself is [Donbox], a Hyprland session
under a Quickshell shell with system-wide theming; this repository
holds what sits beneath and beside it: the shells, the editor, the
terminals, the network-diagnosis tools and the package manifest. A
fresh machine is one clone and two commands away.

[Donbox]: ssh://git@forge.example.com/user/donbox.git

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
| `.config/hypr/xdph.conf` | the screenshare portal's settings |
| `.config/systemd/user` | personal units, none of Donbox's |
| `.local/bin`, `.local/lib/netkit` | the netkit tools |
| `.local/share/claude` | assistant rules and skills |
| `packages.json` | the manifest for the machine |

Nothing generated is kept here. Donbox renders themed files into
`~/.local/state/donbox/current` and writes its own units, links
and completions into real directories; the few of its lines that
live in these configs are the include each tool needs to find its
themed colours. What Donbox writes through a stowed link is
listed in `.gitignore` rather than committed.

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
which kind of file. `get_packages.sh` renders a machine from it
and `donbox pkg` keeps it true as things are installed and
removed, so neither can drift from the other.

    donbox pkg search ripgrep
    donbox pkg add dnf ripgrep
    donbox pkg remove
    donbox pkg list flatpak
    donbox pkg drift

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

Then install [Donbox] on top, which lays its own links, units and
themes down beside these.
