# Desktop and dotfiles

- Every tool that supports colour follows the active desktop
  theme, applied by `theme set`: the shell, Hyprland, Ghostty,
  the bash prompt, GTK, Qt, TeamSpeak and Neovim all read the
  same palette, so a tool that hardcodes its own colours is a
  bug. Ember (background `#1B1B1B`, foreground `#E7E7E7`,
  accent `#DC6F00`) is the default of seventeen.
- Keep `$HOME` clean: configure tools to store config, cache and
  state in XDG locations whenever they allow it. `~/.claude` must
  not exist: `CLAUDE_CONFIG_DIR` already points at
  `~/.local/share/claude`.
- Shared dotfiles config must be portable: no hardcoded
  `/opt/homebrew` or `/Users/...` paths; OS-specific values live
  in the macos/linux stow packages.
- When a new CLI tool is adopted, add it to `get_packages.sh`
  (and the README's Linux tool list) as part of the same piece of
  work.
- A long-running process (daemon, dev server) outlives the code
  it was built from: while iterating on one across a session, the
  running process silently goes stale against the rebuilt binary.
  Before diagnosing surprising behaviour as a code bug, check the
  running process's build age against the current binary and
  restart it; better, give the client a version health-check that
  reconciles a mismatched daemon on launch. When restarting a
  process that holds a mounted or locked resource (a vault, a
  socket), wait for the old one to fully exit and release it
  before starting the new one, or the two race.
