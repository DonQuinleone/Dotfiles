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
the whole system at once, and Ghostty, Neovim and fish beneath
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
| `.config/ghostty` | the terminal |
| `.local/bin` | `donbox` and its subcommands |
| `.local/share/donbox` | theme modules and templates |
| `Pictures/walls` | the wallpapers |
| `packages.json` | the manifest for the machine |
| `test/shell.d` | one suite per area |

Anything that can be told to live under `$XDG_*` does, so `$HOME`
holds this repository, the links stow makes and very little else.
Two directories cannot move: NSS compiles `~/.pki` into
`libnsssysinit.so`, and flatpak hardcodes `~/.var`.

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

`Super+F` opens yazi, which lays a directory out in the columns a
Finder does, from the COPR the manifest names since Fedora does
not package it.

Both scripts are idempotent, so re-running either after a pull is
safe. `bootstrap.sh` restows the package and clears away links
that no longer belong, and refuses to run unless the repo sits
directly in `$HOME`, since the symlinks are relative to that.

    ./test/shell

Each `test/shell.d/*-test.sh` is an independent suite; the first
failed assertion ends its file and the runner carries on, so one
broken area cannot hide the rest. New behaviour lands with a
suite beside it.

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
