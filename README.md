# donbox

```
 (        *
     .          *
        ╲     ╱
         ╲   ╱
          ╲ ╱
           *
          ╱ ╲
         ╱   ╲
        ╱     ╲
      ▄████████▄
      ██████████
      ██████████
      ██████████
   ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀

▄▄█ █▀█ █▀█ █▄▄ █▀█ ▀▄▀
█▄█ █▄█ █ █ █▄█ █▄█ ▄▀▄
```

My Fedora desktop kept as a single GNU Stow package: a Hyprland
session under a Quickshell desktop, seventeen themes that switch
the whole system at once, and kitty, Neovim and fish beneath
it. A fresh machine is one clone and one command away.

I am visually impaired, and that decides the design. The
magnifier comes before everything else, the shell is typeset
larger than a rice usually is, wallpapers are chosen calm and
low-detail because a busy image under 3x magnification is noise,
and every accent is contrast-checked against its background. A
palette that cannot reach a comfortable ratio with its own
authentic colours ships a high-contrast sibling beside it rather
than being quietly falsified.

## What goes where

The repository mirrors `$HOME`, so every path here lands on disk
exactly where it appears.

| Path | Holds |
| --- | --- |
| `.config/hypr` | the session, written in Lua |
| `.config/quickshell` | bar, launcher, notifications |
| `.config/nvim` | the editor |
| `.config/fish` | the shell |
| `.config/kitty` | the terminal |
| `.config/donbox` | the applications the desktop reaches for |
| `.local/bin` | `donbox` and its subcommands, the netkit tools |
| `.local/lib/netkit` | the netkit network-diagnosis library |
| `.local/share/donbox` | theme modules and templates |
| `Pictures/walls` | the wallpapers |
| `packages.json` | the manifest for the machine |
| `migrations` | one script per rename, run once each |
| `test/shell.d` | one suite per area |
| `test/qml.d` | the same, for the shell's own logic |

Nothing generated is kept here. Applying a theme rewrites a file
for every tool that takes one, and applications write settings of
their own, so all of it goes to `~/.local/state/donbox/current`,
symlinked back for the few that will only read from a path of
their own choosing: lsd, fastfetch and fish's universal
variables. Versioned configuration lives under `~/.config/donbox`
instead. Without that split stow folds a directory into a link to
the repository, and every file written there afterwards lands in
the working tree.

Anything that can be told to live under `$XDG_*` does, so `$HOME`
holds this repository, the links stow makes and very little else.
Two directories cannot move: NSS compiles `~/.pki` into
`libnsssysinit.so`, and flatpak hardcodes `~/.var`.

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

A theme is one JSON file under `.config/quickshell/themes`
carrying palette, fonts, sizes, radii, spacing and timings.
Applying it regenerates every surface from that single source, so
a tool that hardcodes its own colours is a bug. Zathura and imv
are themed around their content rather than through it: the
chrome takes the palette while the page and the picture are left
as they were drawn.

The clock in the bar opens the month, the weather, the hours the
sun keeps and the moon drawn as it actually looks tonight,
terminator and all, from Meeus rather than from counting whole
months off a remembered new moon. Where the desktop stands is
asked for once, by name or as plain coordinates, and kept in
`$XDG_STATE_HOME/donbox` rather than here, since coordinates say
where somebody lives; Open-Meteo answers both the search and the
forecast without an account or a key, and nothing else is asked
anything. Alarms are set by typing a time, or a distance from
now such as `+15`, and ring until the notification is dismissed.

Push to talk is `Super+~`. Holding the key opens the TeamSpeak
microphone for as long as it is down; tapping it leaves the
microphone latched open until the next press, and a filled pill
appears in the bar, breathing while it is latched, with a sound
at each end. TeamSpeak's own hotkeys are an X11 key grab, and
XWayland only feeds those while a TeamSpeak window holds focus,
so a synthesised key would arrive from behind a browser without
the release that closes it again. `donbox ptt` speaks to the
client's ClientQuery socket instead, which answers whatever is
in front, and the pill can be clicked to shut the microphone.

`Super+F` opens yazi, which lays a directory out in the columns a
Finder does, from the COPR the manifest names since Fedora does
not package it.

Monitors are arranged by dragging them about in nwg-displays,
which writes the same `hl.monitor` Lua this configuration is
written in. `donbox monitor arrange <profile>` opens it, holds
off the profile that would otherwise be reapplied by the reload
it triggers, and saves the layout it leaves behind. The firewall
is firewalld, and `firewall-cmd` is the whole of its interface:
manafirewall is the only text front end packaged for it, and it
connects and then never draws what it read.

Both scripts are idempotent, so re-running either after a pull is
safe. `bootstrap.sh` restows the package and clears away links
that no longer belong, and refuses to run unless the repo sits
directly in `$HOME`, since the symlinks are relative to that.

Code arrives by pull, but the state it expects does not, so a
second machine would meet new code over old state and need
repairing by hand. `migrations/` holds one script per rename or
move, named for the second it was written, and `donbox migrate`
runs whichever this machine has not seen yet, recording each in
`~/.local/state/donbox/migrations`. `bootstrap.sh` calls it once
the links are in place. Every migration is idempotent and stops
the run if it fails, so nothing later builds on a half-move.

    ./test/shell
    ./test/qml

Each `test/shell.d/*-test.sh` is an independent suite; the first
failed assertion ends its file and the runner carries on, so one
broken area cannot hide the rest. New behaviour lands with a
suite beside it.

The shell's own logic is tested the same way. Anything that is a
function rather than a surface lives in
`.config/quickshell/donbox/services/logic`, importing nothing but
QtQuick, and the Quickshell singleton above it is a facade over
that. `./test/qml` runs the `tst_*.qml` cases against those with
Qt's own runner, headless, so no compositor is needed and nothing
opens on screen.

## Installing

Fedora 44 and GNU Stow, with Hyprland 0.56 and Quickshell 0.3
coming from the COPRs the manifest names.

    git clone \
      ssh://git@forge.example.com/user/donbox.git \
      ~/.dotfiles
    ~/.dotfiles/get_packages.sh
    ~/.dotfiles/bootstrap.sh

One optional step, and the only one needing root, without which
Firefox picks up a theme change at its next launch rather than
immediately:

    donbox install mozilla theme
