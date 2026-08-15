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

My Fedora desktop, kept as a single GNU Stow package so a fresh
machine is one clone and one command away from the setup I
actually work in: a Hyprland session with a Quickshell desktop
built for a magnifier, seventeen themes that switch the whole
system at once, Ghostty, Neovim, fish, lsd and fastfetch.

I go by DonQuinleone online, a portmanteau of Don Quixote and
Corleone, and the logo above is the nod: a windmill for the Don
tilting at giants, standing on the box the whole desktop ships
in, under a sky that carries the rest of the magic.

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
      ssh://git@forge.example.com/user/donbox.git \
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

## Logging in

There is no graphical greeter. `greetd` runs `tuigreet` on VT 1,
and the session it starts is `start-hyprland` rather than
`Hyprland` itself: the watchdog Fedora ships beside the
compositor, which restarts it if it exits uncleanly. Hyprland
warns at startup when it is launched without it.

Starting a compositor straight from a greeter means nothing pulls
in `graphical-session.target`, which refuses a manual start and
which `xdg-desktop-portal` treats as a requisite. Hyprland starts
`donbox-session.target` to reach it. Without that the portal
never runs, and GTK applications have nobody to ask whether the
palette is dark.

The console font matters more here than it would elsewhere,
because the login prompt is the one screen the magnifier cannot
reach. `setfont` caps out at 32 pixels, so a readable size comes
from doubling a Terminus face rather than from a larger one:
`ter-v28b` drawn with `-d` is 28 pixels wide by 56 tall.
`vconsole.conf` cannot express the doubling, so a small unit
applies it to the first three VTs before greetd starts.

The greeter does not remember the username.

These three files sit outside the stow package, since they live
under `/etc` rather than `$HOME`:

| File | What it does |
| --- | --- |
| `/etc/greetd/config.toml` | runs tuigreet, picks the session |
| `/etc/vconsole.conf` | names the console font |
| `/etc/systemd/system/console-font-large.service` | doubles it |

## Packages

Hyprland left the official Fedora repositories at Fedora 43, so
the compositor and its ecosystem come from a COPR, and Quickshell
from another. Both are personal repositories, which is a real
risk: the previously standard one was abandoned mid-lifecycle and
stranded its users. There is no second desktop to fall back on
any more, so the safety net is a text console: a broken update
costs a graphical session, and `Ctrl+Alt+F3` still gets a login
and a shell.

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

`.config/quickshell/donbox` is the shell: a bar on every monitor,
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
| Screensaver | Lava lamp, windmill or code rain, docked only |

Layouts are per workspace: master stack, monocle and scrolling,
each remembered by the workspace it belongs to. Monocle stacks
the windows into one group and shows their titles as an
accordion, so a workspace of ten windows still reads as a list.
Any single window can be floated on top wherever it sits, which
is what a floating mode would have been for.

Motion is treated as information rather than decoration. The
focused window's border is a gradient that turns once every ten
seconds, a second always-on signal of where focus sits; switching
workspace slides the way the eye expects, and a scratchpad drops
over the workspace instead of sliding beside it. Every shell
surface enters from the edge it lives on. All of it answers one
control, which the shell drives too:

    motion get
    motion set scale 0.5
    motion set drift off
    motion reduced on

`reduced` collapses the whole scheme to around forty
milliseconds without switching it off, so direction is still
readable when a full-speed desktop is too much.

Idle behaviour follows the dock. Docked, the screen dims at five
minutes, the screensaver takes over at eight and the screens go
off at twelve, and the machine never suspends itself. Undocked it
dims at two, locks at three, blanks at four and suspends at
fifteen.

Three screensavers ship, every one coloured from the active
palette, kept dim and incapable of strobing because the primary
display is an OLED: the lava lamp, a metaball shader that never
stops moving; the donbox windmill turning under the stars, which
every so often dissolves into glyphs and resolves back; and a
field of code rain in the register the lock screen uses. The
windmill saver is a native rebuild of the terminal-text
screensaver Omarchy ships (MIT, by David Heinemeier Hansson);
the idea is borrowed with credit, the code is not, so it can
follow the palette and hold still under reduced motion. One
command chooses, and the choice persists in the shell's settings
store:

    screensaver list
    screensaver set windmill
    screensaver set cycle

`cycle` draws one at random each time the saver starts, and
`off` disables idle starts entirely. `loginctl lock-session`
reaches the same locker, which
authenticates against the login PAM stack rather than checking a
password itself, so whatever that stack accepts, an enrolled
fingerprint included, unlocks the screen.

## Night shift

`night-shift` warms the display through `hyprsunset`, ramping
over ninety minutes rather than stepping, and `Super+Shift+W`
overrides it either way until the next scheduled change. Times
come from a local sunrise and sunset worked out offline by the
NOAA solar algorithm, so it needs no network and no address in a
committed file.

Everything is set in `~/.config/night-shift.conf`, which is not
part of this repository:

| Key | Default | What it does |
| --- | --- | --- |
| `ENABLED` | `1` | `0` disables warming entirely |
| `NIGHT_TEMPERATURE` | `5800` | Kelvin at full night |
| `DAY_TEMPERATURE` | `6500` | Kelvin by day, unwarmed |
| `TRANSITION_MINUTES` | `90` | Length of each ramp |
| `NIGHT_START`, `NIGHT_END` | unset | Fixed `HH:MM` times, replacing the sun; set both, and the start must fall later in the day than the end |
| `LATITUDE`, `LONGITUDE` | London | Where the sun is worked out for |

The default of 5800K is deliberately mild, and the reason is
contrast rather than taste. Warming multiplies the colour
channels unevenly, so it lowers every ratio the palettes were
checked against. Measured across all seventeen, the tightest
accent that still clears WCAG AA in daylight is Osaka Jade's,
and it stops clearing it below 5750K; Ember survives all the way
to 3150K. Warm it further and the accents go first, which on
this desktop means the focus border and the highlights, while
body text keeps a great deal more headroom.

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

Icons are generated rather than configured. Adwaita writes its
folder blue into each drawing, so applying a theme re-shades
every blue to the accent at its own lightness and writes the
result to `~/.local/share/icons/donbox`, which inherits Adwaita
for everything it does not touch. Applications already running
keep the old icons until they restart.

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

## Keys

Signing and SSH run through one agent. gpg-agent serves the SSH
socket as well as its own, so a single passphrase, a single cache
and a single prompt cover a `git commit` and a `git push` alike.
`pam_gnome_keyring` exports `SSH_AUTH_SOCK` whether or not there
is an agent behind it, and gnome-keyring's own ssh component
autostarts only under GNOME, Unity and MATE, so on this session
nothing ever served that socket: which is why every push asked
for the passphrase again and no agent ever held the key. Both
shells and `~/.config/environment.d` now override it with the
path `gpgconf --list-dirs agent-ssh-socket` reports.

Hand the SSH key to that agent once per working day:

    ssh-add ~/.ssh/id_ed25519

gpg-agent reads its configuration once at start and outlives a
logout, so `gpgconf --kill gpg-agent` is what makes it pick up a
change. Prompts come from `pinentry-gnome3`, a real window the
magnifier reaches, rather than a curses prompt inside whichever
terminal happened to ask. The cache holds for eight hours, so a
working day costs one prompt per key and a session left overnight
asks again.

The passphrases are deliberately not stored. A mechanism that
unlocked both keys at login was built and then removed: it worked,
but it left the passphrase readable in clear by anything running
as me, which turns a stolen session into permanent theft of the
signing key rather than its use while I am there. The signing key
is going to a hardware token instead.

The fingerprint answers the login, the lock screen and `sudo`,
which `authselect`'s `with-fingerprint` feature already provides.
It cannot answer for a key. fprintd reports a match or no match
and derives no key material, so nothing it does can decrypt a
passphrase; a fingerprint in front of signing would only be a
helper holding the passphrase and releasing it on a match, which
stops somebody at the keyboard and stops nothing at all running
as me. A smartcard is the only thing that would make a signature
need hardware present.

## What that costs

Worth stating plainly, because it is a real reduction. Anyone who
reaches the unlocked session can sign as me and reach whatever
the SSH key opens, without knowing a passphrase. The passphrase
itself sits in `~/.local/share/keyrings/login.keyring`, encrypted
at rest under the login password, readable by anything running as
me once the session is up. The keys themselves stay encrypted on
disk, and a suspended machine is worth exactly what its lock
screen is worth.

The fingerprint answers the login, the lock screen and `sudo`,
which `authselect`'s `with-fingerprint` feature already provides.
It cannot answer for a key. fprintd reports a match or no match
and derives no key material, so nothing it does can decrypt a
passphrase; a fingerprint in front of signing would only be a
helper holding the passphrase and releasing it on a match, which
stops somebody at the keyboard and stops nothing at all running
as me. A smartcard is the only thing that would make a signature
genuinely need the hardware.

## Fetch

`fastfetch` shows the windmill logo beside system information.
The logo, its eight rotation frames and a small cycling script
live under `.config/fastfetch/logo`.

I tried playing an animated GIF of the windmill through the
kitty graphics protocol (`fastfetch`'s `kitty-icat` logo type,
which `fastfetch --logo-type kitty-icat` documents as supported
by Kitty and iTerm). In a real Ghostty window it only ever drew
the first frame: two screenshots a second apart were pixel
identical. Ghostty's graphics protocol support doesn't yet cover
the animation frame extension that playback needs, so the logo
falls back to `.config/fastfetch/logo/animate`, a small script
that redraws the eight text frames in place with `tput`:

    ~/.config/fastfetch/logo/animate

Run it directly for the full spinning windmill; `fastfetch`
itself shows the static logo, since it prints its report once
and exits.

The logo follows the active theme. `theme set` regenerates
`~/.config/fastfetch/config.jsonc` from the palette the way it
already does for Ghostty, GTK and the rest, so the generated
config is not part of this repository, and `animate` reads the
same palette on every run. Before the first `theme set` the
fetch falls back to fastfetch's stock look; `theme-daemon`
applies the active theme at login, so in practice the config is
always there.

## Known rough edges

Firefox and Thunderbird only restyle live once the Mozilla loader
is installed, and an application update removes it. The theme
module notices and says so.

Qt applications read their palette at launch, so a theme change
reaches them when they next start. Fedora 44 has no `qt5ct`, so
Qt 5 applications carrying their own toolkit, TeamSpeak among
them, are covered by their own stylesheet instead.

The locker rejects a wrong password and offers a retry, both
checked. A successful unlock and a real finger scan are not yet
verified.

Caret tracking follows the text cursor in Neovim, which reports
its position directly. Applications that expose a caret through
the accessibility bus are unreliable, and a terminal shell prompt
reports nothing at all.

## Contributing

Personal configuration rather than a general-purpose framework,
so it is unlikely to suit anyone else unmodified. Patches to
`user` if something here is plainly broken.
