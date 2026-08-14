# fedora-dots

My Fedora desktop, kept as a single GNU Stow package so a fresh
machine is one clone and one command away from the setup I
actually work in: a Hyprland session with a Quickshell desktop
built for a magnifier, seventeen themes that switch the whole
system at once, Ghostty, Neovim, fish and lsd.

The repository mirrors `$HOME`, so every path below appears in
the repo exactly where it lands on disk.

## Why it looks like this

I am visually impaired, and that decides most of the design. The
magnifier comes before everything else: it animates in 150ms
because a slow zoom is unusable, the pointer can be steered by
the text caret, and the whole shell is typeset larger than a rice
usually is. Wallpapers are chosen calm and low-detail, because a
busy image under 3x magnification is noise. Notifications can
speak. Every accent is contrast-checked against its background,
and where a palette cannot reach a comfortable ratio with its own
authentic colours, a high-contrast sibling ships beside it rather
than the palette being quietly falsified.

## Requirements

- Fedora 44
- GNU Stow
- Hyprland 0.56 and Quickshell 0.3 (from COPRs, see below)

`get_packages.sh` enables every repository and installs
everything, including the fonts and the Piper voice. It is
idempotent, so re-running it after an update is safe.

## Usage

    git clone \
      ssh://git@forge.example.com/user/fedora-dots.git \
      ~/.dotfiles
    ~/.dotfiles/get_packages.sh
    ~/.dotfiles/bootstrap.sh

`bootstrap.sh` restows the package, so re-running it after a pull
is safe and clears away links that no longer belong. It refuses
to run unless the repo sits directly in `$HOME`, since the
symlinks are relative to that position.

One optional step, and the only one needing root: installing the
Mozilla theme loader, without which Firefox and Thunderbird pick
up a theme change at their next launch rather than immediately.

    ~/.config/hypr/scripts/mozilla-theme-loader

## Packages

Hyprland left the official Fedora repositories at Fedora 43, so
the compositor and its ecosystem come from a COPR, and Quickshell
from another. Both are personal repositories, which is a real
risk: the previously standard one was abandoned mid-lifecycle and
stranded its users. COSMIC remains installed and appears at the
greeter, so a broken update costs a session rather than a
machine.

| Component | Source |
| --- | --- |
| `hyprland`, `hypridle`, portal | COPR `lionheartp/Hyprland` |
| `quickshell-git` | COPR `errornointernet/quickshell` |
| `piper-tts` | pipx, no RPM exists |
| JetBrains Mono Nerd Font | upstream release, pinned |

## The desktop

`.config/hypr` is a Lua configuration, which Hyprland has used
since 0.55. Keybindings live in one declarative table, so the
whole scheme reads at a glance and the cheat sheet is generated
from the same source.

`.config/quickshell/ember` is the shell: a bar on every monitor,
launcher, notification centre, on-screen display, and a picker
that any script can drive. Nothing in it hardcodes a colour or a
size; every value comes from the active theme.

| Surface | What it does |
| --- | --- |
| Bar | Workspaces, layout, clock, tray, vitals |
| Launcher | Fuzzy search, plus a scriptable picker |
| Notifications | Own daemon, history, sounds, speech |
| Display | Volume and brightness, foot of the screen |
| Wallpaper | Per-theme, crossfaded |
| Lock | PAM or fingerprint, on every monitor |
| Screensaver | Themed lava lamp, docked only |

Layouts are per workspace: master stack, monocle, scrolling and
floating, each remembered by the workspace it belongs to.

Idle behaviour follows the dock. Docked, the screen dims at five
minutes, the lava lamp takes over at eight and the screens go off
at twelve, and the machine never suspends itself; the lamp is a
metaball shader coloured from the active palette, kept dim and
always moving because the primary display is an OLED. Undocked it
dims at two, locks at three, blanks at four and suspends at
fifteen. `loginctl lock-session` reaches the same locker, which
authenticates against PAM, so an enrolled fingerprint unlocks as
readily as a typed password.

## Themes

Seventeen, switched with one command that reaches the whole
system:

    theme list
    theme set kanagawa-wave
    theme accent gold
    theme wallpaper

Ember is the default, and the rest are Kanagawa Wave, Catppuccin
Mocha, Dracula, Solarised Dark and Light, Tokyo Night and Storm,
Rosé Pine with Moon and Dawn, Gruvbox Dark and Light, Osaka Jade,
and high-contrast variants of Solarised Dark, Solarised Light and
Rosé Pine Dawn.

A theme is one JSON file carrying palette, fonts, sizes, radii,
spacing, opacities and animation timings. Applying it regenerates
Hyprland's colours, the shell, Ghostty, GTK 3 and 4, Qt, the bash
and fish prompts, Neovim, TeamSpeak, Firefox and Thunderbird from
that single source. Most surfaces update live; Qt applications
read their palette at launch, and TeamSpeak needs its style
selected once.

Palettes with more than one canonical accent expose all of them,
refusing any that falls below a readable contrast ratio, and each
theme ships six or more wallpapers under `Pictures/walls`.

`theme-daemon` applies the active theme at login and watches the
theme directory, so editing a palette by hand updates the desktop
without running anything.

## Shell

fish is the interactive shell and bash is the login shell. The
split is deliberate rather than half-finished: `~/.bash_profile`
exports the cursor theme and size that the graphical session
inherits, so keeping bash in the login path keeps shell
configuration out of a place where a bad edit costs a session.
Ghostty starts fish through its `command` setting, which covers
every terminal actually opened.

Both prompts colour the username from the active theme and
re-read it on every draw, so switching theme repaints the next
prompt without restarting the shell.

## Known rough edges

Firefox and Thunderbird only restyle live once the Mozilla loader
is installed, and an application update removes it. The theme
module notices and says so.

Qt applications read their palette at launch, so a theme change
reaches them when they next start. Fedora 44 has no `qt5ct`, so
Qt 5 applications carrying their own toolkit, TeamSpeak among
them, are covered by their own stylesheet instead.

Caret tracking follows the text cursor in Neovim, which reports
its position directly. Applications that expose a caret through
the accessibility bus are unreliable, and a terminal shell prompt
reports nothing at all.

## Contributing

Personal configuration rather than a general-purpose framework,
so it is unlikely to suit anyone else unmodified. Patches to
`user` if something here is plainly broken.
