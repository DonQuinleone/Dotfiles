# fedora-dots

My Fedora and COSMIC desktop configuration, kept as a single GNU
Stow package so a fresh machine is one clone and one command away
from the setup I actually work in: Ghostty, Neovim, bash, lsd,
git, and the whole COSMIC settings tree, wallpaper included.

The repository mirrors `$HOME`, so every path below appears in
the repo exactly where it lands on disk.

## Requirements

- Fedora with the COSMIC desktop (built against COSMIC 1.5)
- GNU Stow
- Ghostty, Neovim, lsd, most, GnuPG, Hack Nerd Font

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
| `.bashrc`, `.bash_profile` | Shell, XDG paths, prompt, aliases |
| `.config/cosmic` | Panel, dock, theme, shortcuts, input |
| `.config/environment.d` | Cursor theme for systemd user services |
| `.config/ghostty` | Terminal, themed from the COSMIC palette |
| `.config/git` | Identity, signing, editor |
| `.config/lsd` | `ls` replacement and its colours |
| `.config/nvim` | Neovim and lazy.nvim plugin set |
| `.local/share/claude/CLAUDE.md` | Working rules for Claude Code |
| `Pictures/Orange-Nebula.png` | Desktop wallpaper |

Colours come from the COSMIC dark theme (background `#1B1B1B`,
foreground `#E7E7E7`, accent `#DC6F00`) for Ghostty and the shell
prompt, and from Kanagawa Wave for Neovim, which runs with a
transparent background over the terminal.

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
