# fedora-dots

My Fedora and COSMIC desktop configuration, kept as a single GNU
Stow package so a fresh machine is one clone and one command away
from the setup I actually work in: Ghostty, Neovim, fish, lsd,
git, and the whole COSMIC settings tree, wallpaper included.

The repository mirrors `$HOME`, so every path below appears in
the repo exactly where it lands on disk.

## Requirements

- Fedora with the COSMIC desktop (built against COSMIC 1.5)
- GNU Stow
- Ghostty, fish, fzf, Neovim, lsd, most, GnuPG, Hack Nerd Font

## Usage

    git clone \
      ssh://git@forge.example.com/user/fedora-dots.git \
      ~/.dotfiles
    ~/.dotfiles/bootstrap.sh

`bootstrap.sh` restows the package, so re-running it after a pull
is safe and clears away links that no longer belong. It refuses
to run unless the repo sits directly in `$HOME`, since the
symlinks are relative to that position.

## What is included

| Path | Contents |
| --- | --- |
| `.bashrc`, `.bash_profile` | Login shell, XDG paths, prompt, aliases |
| `.config/cosmic` | Panel, dock, theme, shortcuts, input |
| `.config/environment.d` | Cursor theme for systemd user services |
| `.config/fish` | Interactive shell, prompt, colours, abbreviations |
| `.config/ghostty` | Terminal, themed from the COSMIC palette |
| `.config/git` | Identity, signing, editor |
| `.config/lsd` | `ls` replacement and its colours |
| `.config/nvim` | Neovim and lazy.nvim plugin set |
| `.local/share/claude/CLAUDE.md` | Working rules for Claude Code |
| `Pictures/Orange-Nebula.png` | Desktop wallpaper |

Colours come from the COSMIC dark theme (background `#1B1B1B`,
foreground `#E7E7E7`, accent `#DC6F00`) for Ghostty and the shell
prompt, so the terminal sits flush with the desktop. Everything
drawn inside it takes Kanagawa Wave: Neovim, running with a
transparent background over the terminal, and fish's syntax
highlighting, completion pager and fzf overlay, which name their
colours after the same palette entries kanagawa.nvim uses.

## Shell

fish is the interactive shell and bash is the login shell. The
split is deliberate rather than half-finished.

`start-cosmic` execs `$SHELL` as a login shell to collect the
environment it hands to `cosmic-comp`:

    exec bash -c "exec -l '${SHELL}' -c '${0} --in-login-shell'"

`~/.bash_profile` is where `XCURSOR_THEME` and `XCURSOR_SIZE` are
exported, so leaving bash as the login shell keeps the cursor
size correct and keeps shell configuration out of the graphical
login path, where a bad edit costs a session. Ghostty starts fish
through its `command` setting, which covers every terminal
actually opened. The two shells therefore repeat the same
environment block, and both copies have to move together.

To promote fish to the login shell, first move those two exports
into the fish configuration behind a `status is-login` guard,
then:

    chsh -s /usr/bin/fish

Skipping the first step drops cosmic-comp back to a 24px cursor.

## Known rough edges

Ghostty's `background-blur` does nothing under COSMIC. Ghostty
speaks `org_kde_kwin_blur_manager` and cosmic-comp offers only
`ext_background_effect_manager_v1`. The setting is left in place
so it starts working when either side closes the gap.

`com.system76.CosmicBackground` stores the wallpaper as an
absolute path, so restoring under a different username needs that
one value repointed at the copy in `Pictures/`.

## Contributing

Personal configuration rather than a general-purpose framework,
so it is unlikely to suit anyone else unmodified. Patches to
`user` if something here is plainly broken.
