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
busy image under 3x magnification is noise. Every accent is
contrast-checked against its background,
and where a palette cannot reach a comfortable ratio with its own
authentic colours, a high-contrast sibling ships beside it rather
than the palette being quietly falsified.

## Requirements

- Fedora 44
- GNU Stow
- Hyprland 0.56 and Quickshell 0.3 (from COPRs, see below)

`get_packages.sh` enables every repository and installs
everything, including the fonts. It is idempotent, so re-running
it after an update is safe.

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

    donbox install mozilla theme

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
| Slack, Yubico Authenticator | Flathub |
| JetBrains Mono Nerd Font | upstream release, pinned |

`get_packages.sh` installs all of it, adds the Flathub remote
and skips any flatpak already present, so re-running it after a
pull costs nothing.

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
| Notifications | Own daemon, history, sounds |
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

    donbox motion get
    donbox motion set scale 0.5
    donbox motion set drift off
    donbox motion reduced on

`reduced` collapses the whole scheme to around forty
milliseconds without switching it off, so direction is still
readable when a full-speed desktop is too much.

Idle behaviour follows the dock. Docked, the screen dims at five
minutes, the screensaver takes over at eight and the screens go
off at twelve, and the machine never suspends itself. Undocked it
dims at two, locks at three, blanks at four and suspends at
fifteen.

Dimming and waking ask the shell to hold its brightness readout
down first, so only a brightness key raises it; the request
lapses after a second, so a missed call cannot silence it.

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

## The panels

The pills sit in one row at the right of the bar, in this order:
notifications, updates, VPN, network, Bluetooth, microphone,
sound and battery. Each is an icon alone, because the row is
shared with the tray and horizontal space is scarce; only the
battery percentage, the notification count and the update count
earn text beside their glyph. A pill with nothing to say hides
itself, so the updates pill appears only when DNF has something
pending and the VPN pill only when there is a tunnel to show.

Every pill opens its own panel, the way the clock opens its
dropdown. Each panel is capped against the height of the screen
and scrolls inside itself, so none of them can run off the
display:

| Pill | Panel |
| --- | --- |
| Notifications | opens the notification centre; right-click silences |
| Updates | none; the count is the whole message |
| VPN | NetBird with its peers and address, and any NetworkManager tunnel, each with a connect and disconnect |
| Network | throughput, latency and loss to router and internet, addresses and DNS with copy buttons, a provider picker, and the networks in range |
| Bluetooth | the radio, the paired devices with the charge of every cell they report, and whatever is in pairing range |
| Microphone | live or muted, the input level, and which device records |
| Sound | a per-application mixer to 150%, and which device plays |
| Battery | health against design capacity, charge cycles, time to empty or full, and the power profile |

The power profile is remembered separately for AC and battery, so
plugging in restores the profile last chosen on AC and unplugging
restores the one chosen on battery.

Bluetooth discovery runs only while its pane is open, since it
costs power and airtime and can disturb a connected headset. A
device advertising itself appears within a second or two of
opening the pane. Anything that does not name itself is left
out: a scan turns up far more privacy addresses and beacons than
peripherals, and BlueZ names those after their own address.

Pairing needs a second thing that is easy to miss. BlueZ will
not complete one without an agent registered to answer for the
passkey, and it refuses in the log rather than to the person who
pressed the button, so pairing appears to do nothing at all.
Quickshell has no agent of its own, so `bt-agent` runs for the
same span as discovery. Its capability is `NoInputNoOutput`,
which accepts without asking: there is nothing here to compare a
passkey on, and since the adapter is never made discoverable,
the only pairings it can ever answer for are the ones started
from the pane.

BlueZ reports one percentage per device, which is not enough for
a split keyboard that meters each half. `donbox bluetooth battery`
reads the Battery Level characteristics straight out of GATT
instead, so every cell a device exposes is listed and warned
about separately: normal at twenty per cent, critical at five.
Devices reporting a single figure keep coming through BlueZ or
UPower as before. Apple's headsets report over a protocol of
their own that BlueZ does not implement, so they pair and
connect but show no charge.

The shell warns as the charge falls, once each time it crosses
a line rather than repeatedly while it sits below one: a normal
notification at twenty per cent and a critical one at ten, which
carries through do not disturb. Neither fires while the machine
is charging, and each rearms only once the charge has climbed
back over its line.

Plugging in sounds a short cue, the freedesktop device-added
tone the shell already bundles, on the crossing from battery to
mains rather than on every reading of it: a machine that starts
up already plugged in stays silent, and unplugging says nothing.

The clock in the middle of the bar opens a dropdown of its own,
carrying the month, alarms and the time elsewhere. Alarms are set
with steppers rather than typing, since a dropdown never takes
keyboard focus, and ring as a critical notification, which stays
on screen until it is dismissed. Other time zones are picked by
region and city from the system database, and their times are
read from the zone rules on every sample, so they follow daylight
saving without anything being told about it. Both are kept in
`$XDG_STATE_HOME/donbox`.

Panels answer the keyboard as well as the mouse, since a surface
only a pointer can reach is no use under magnification:

    qs -c donbox ipc call panels toggle network

One name says which panel is open, so opening one closes any
other by construction rather than by arrangement, and clicking
away closes whatever is showing.

A dropdown never takes keyboard focus, which is why two things
stay out of the panels: joining an unsaved secured network,
which would need a password field, and reading the clipboard
through Qt, so copying goes through `wl-copy` instead.

## Commands

Everything the desktop can be told to do is one command, on the
path as `donbox`:

    donbox                     what there is
    donbox theme set dracula
    donbox nightshift toggle
    donbox motion reduced on
    donbox menu emoji          SUPER+CTRL+E
    donbox menu clipboard      SUPER+CTRL+V

There is no registry behind it. Every executable
`.local/bin/donbox-*` is a command and its filename is its
route, so `donbox theme set dracula` runs `donbox-theme-set` if
that exists and otherwise hands `set dracula` to `donbox-theme`.
A `# donbox:summary=` header is what the listing prints, and
`donbox commands --check` fails on a command that lacks one.

The keybindings, hypridle and the shell all call through it, so
a command can be renamed without hunting for the places that
knew where it used to live.

The two pickers both end in the clipboard rather than typing,
since a chooser holds the keyboard while it is open and there is
nothing to type into by the time it closes. Emoji come from
Unicode's own published list at
`/usr/share/unicode/emoji/emoji-test.txt`, so the repository
carries no copy of it, and the clipboard history is `cliphist`,
fed by a watcher the session starts.

## Web apps

A page that earns a window of its own gets one:

    donbox webapp install "Forgejo" forge.example.com
    donbox webapp list
    donbox webapp remove

Brave Origin draws it, since Chromium's app mode is the only one
that gives a window with no browser around it, and Firefox stays
the default for everything else. The icon comes from the site's
own favicon rather than an icon service, so asking for it tells
nobody but the site. Each window arrives with a class of its
own, `brave-<host>__-Default`, which is what a rule in
`rules.lua` can match on to place it.

Entries live in `~/.local/share/applications` and carry
`X-Donbox-Webapp=true`, which is what `remove` goes by, so
nothing else in that directory can be deleted by mistake.

## Shortcuts

Each modifier carries one meaning, so a binding can be guessed
rather than looked up:

| Modifier | Meaning |
| --- | --- |
| `Super` | go to or open something |
| `Super+Shift` | act on the focused window |
| `Super+Ctrl` | adjust |
| `Super+Alt` | hardware and the session |

`Super+H` moves the focus, `Super+Shift+H` moves the window,
`Super+Ctrl+H` resizes it. Layouts and gaps sit with the window
actions because they arrange windows; theme, accent and wallpaper
sit with the adjustments; volume and brightness are on
`Super+Alt` with the arrow keys.

The magnifier breaks the rule on purpose. `Super` with `=`, `-`,
`0`, `z` and the scroll wheel is the shortest reach on the
keyboard, and it is the control this desktop exists to make
usable.

Two families use `Shift` and `Ctrl` as variants of their own
action rather than in the sense above, because neither has a
window to act on: screenshots (`Shift` for a region, `Ctrl` to
save) and notifications (`Shift` for do not disturb, `Ctrl` to
dismiss everything).

Quitting is `Super+Alt+E`. It used to be `Super+Shift+E`, one
modifier from the mail scratchpad on `Super+E`, which is too
close for something that cannot be undone.

## Settings

`Super+Ctrl+C` opens a picker of everything the desktop can be
told. Choosing an entry opens the file that owns it in Neovim, in
a floating terminal sized to hold a 72-column file at the reading
font size, or hands over to the tool that owns it instead:

| Entry | What it opens |
| --- | --- |
| Shortcuts | `hypr/lua/binds.lua` |
| Input and gestures | `hypr/lua/input.lua` |
| Magnifier and cursor | `quickshell/settings.json` |
| Layout and decoration | `hypr/lua/look.lua` |
| Motion | `hypr/lua/motion.lua` |
| Window rules | `hypr/lua/rules.lua` |
| Monitors | `hypr/lua/monitors.lua` |
| Workspaces | `hypr/lua/workspaces.lua` |
| Notifications | `quickshell/notifications.json` |
| Night shift | `night-shift.conf` |
| Session startup | `hypr/lua/autostart.lua` |
| Network connections | `nmtui` |
| Audio routing | `wiremix` |

Paths are relative to `~/.config`, and the picker shows each one
under its entry, so what is about to be edited is never a guess.
`night-shift.conf` is not tracked here, so the picker writes the
defaults out before opening it rather than dropping you into an
empty buffer.

Closing the editor applies what changed, and only if something
did: the compositor is reloaded for its own configuration, the
night shift schedule is re-applied for its, and the shell watches
the two files it owns and re-reads them itself. Hand-editing
`quickshell/settings.json` therefore lands live, magnifier step
and cursor size included.

There is no entry for Bluetooth, network status, volume or power,
because the bar's panels already do all of that live and a second
route would only be a second thing to keep true. `nmtui` and
`wiremix` earn their places by reaching what the panels cannot:
editing saved connection profiles, and routing individual streams
between devices.

## Night shift

`donbox nightshift` warms the display through `hyprsunset`, ramping
over ninety minutes rather than stepping, and `Super+Alt+W`
overrides it either way until the next scheduled change. Times
come from a local sunrise and sunset worked out offline by the
NOAA solar algorithm, so it needs no network and no address in a
committed file.

Everything is set in `~/.config/night-shift.conf`, which is not
part of this repository; `donbox nightshift defaults` prints it, and
the settings picker writes it out that way before opening it for
the first time:

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

    donbox theme list
    donbox theme set kanagawa-wave
    donbox theme accent gold
    donbox theme wallpaper

Ember is the default, and the rest are Kanagawa Wave, Catppuccin
Mocha, Dracula, Solarised Dark and Light, Tokyo Night and Storm,
Rosé Pine with Moon and Dawn, Gruvbox Dark and Light, Osaka Jade,
and high-contrast variants of Solarised Dark, Solarised Light and
Rosé Pine Dawn.

A theme is one JSON file carrying palette, fonts, sizes, radii,
spacing, opacities and animation timings. Applying it regenerates
Hyprland's colours, the shell, Ghostty, GTK 3 and 4, Qt, the bash
and fish prompts, Neovim, btop, lsd, fastfetch, TeamSpeak,
Firefox and Thunderbird from that single source. Most surfaces
update live; Qt applications read their palette at launch, and
TeamSpeak needs its style selected once.

The terminal tools take the palette at full depth rather than
rounded to a 256-colour index: lsd reads crossterm colours, which
accept a hex string, so `colors.yaml` is written straight from
the theme and is generated rather than tracked.

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

## Home directory

Anything that can be told to live under `$XDG_*` does, so `$HOME`
holds this repository, the links stow makes and very little else.
The variables are set twice on purpose: `~/.config/environment.d`
covers the systemd user session, and both shells set them again
because environment.d never reaches a TTY or an SSH login, which
would otherwise find the old defaults and recreate them.

Two of the moves have a catch worth recording.

Moving the GnuPG home moves its sockets with it, into a runtime
directory named after a hash of the new path. Nothing can spell
that out portably, so `gpg-agent-ssh-socket.service` asks
`gpgconf --list-dirs agent-ssh-socket` and publishes the answer
to the session; the shells ask the same question themselves, and
both set `GNUPGHOME` before they do.

`~/.mozilla` came back after every deletion. Fedora's Firefox and
Thunderbird launchers both `mkdir -p` an extensions directory
under it to hang langpack symlinks off, before either program
starts, and Firefox then prefers that directory over the XDG one
its profile already lives in. `MOZ_DISABLE_LANGPACKS=1` skips
that block in both launchers. The profile itself is untouched at
`$XDG_CONFIG_HOME/mozilla/firefox`.

Three directories stay where they are, each checked rather than
assumed:

| Directory | Why it cannot move |
| --- | --- |
| `~/.pki` | the path is compiled in |
| `~/.thunderbird` | the XDG patch is Firefox-only |
| `~/.var` | flatpak hardcodes it |

NSS carries `/.pki/nssdb` as a literal inside
`libnsssysinit.so`, so no variable reaches it. Thunderbird writes
`~/.thunderbird/profiles.ini` even when `$XDG_CONFIG_HOME` and a
`thunderbird` directory inside it both already exist, which a run
against a throwaway home confirms. Its profile can be pointed
somewhere else through an absolute `Path` in `profiles.ini`, but
that moves the mail without removing the directory, so it buys
nothing here.

`.var/app` is a literal in both `flatpak` and `libflatpak`, and
`FLATPAK_USER_DIR` is no help: it moves the installation, which
already defaults to `$XDG_DATA_HOME/flatpak`. The direction is
the other way round, since flatpak sets the four `XDG_*`
variables inside the sandbox to point at `~/.var/app/$APPID`, so
they are what that path produces rather than what places it.

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

The logo follows the active theme. `donbox theme set` regenerates
`~/.config/fastfetch/config.jsonc` from the palette the way it
already does for Ghostty, GTK and the rest, so the generated
config is not part of this repository, and `animate` reads the
same palette on every run. Before the first `donbox theme set` the
fetch falls back to fastfetch's stock look; `donbox theme daemon`
applies the active theme at login, so in practice the config is
always there.

## Known rough edges

Firefox and Thunderbird only restyle live once the Mozilla loader
is installed, and an application update removes it. The theme
module notices and says so.

Dark Reader follows the desktop, but has to be told to once.
Applying a theme sets `org.gnome.desktop.interface color-scheme`
and the portal serves it, which is the signal Dark Reader's
**Automation** setting reads, so turning on its system colour
scheme option makes every later theme change reach it. It cannot
be set from here: Dark Reader keeps its settings in compressed
IndexedDB inside the Firefox profile and reads no managed
storage, so there is no file to write and no policy to declare.

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

## Tests

    ./test/shell

Each `test/shell.d/*-test.sh` is an independent suite; the first
failed assertion ends its file and the runner carries on, so one
broken area cannot hide the rest. New behaviour lands with a
suite beside it.

## Contributing

Personal configuration rather than a general-purpose framework,
so it is unlikely to suit anyone else unmodified. Patches to
`user` if something here is plainly broken.
