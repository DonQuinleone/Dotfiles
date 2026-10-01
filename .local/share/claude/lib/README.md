# Claude Code hooks

Three hooks for the global Claude Code configuration. They keep
written files shellcheck-clean and on-house-style, and put a
desktop notification on the two events worth interrupting for.

Each hook is a standalone bash script that reads the hook event
JSON on stdin, so it can be run by hand with a payload piped
into it. `lib/style-check.sh` is also a normal command line
linter: give it paths and it reports on them.

## What the style linter ignores

The linter is deliberately quiet in the places where its rules
do not apply:

- Fenced code blocks, opened with three backticks or three
  tildes, are skipped whole, delimiters included.
- Inline code spans are removed before the prose checks run, so
  a dash or an identifier inside backticks is never reported.
- Lines containing a URL are exempt from the width, spelling and
  `email` checks.
- Markdown table rows (a line whose first non-space character is
  a pipe) are exempt from the width and spelling checks.
- The width check does not run on `.html`, `.json`, `.qml` or
  `.go` files, where wrapping is the formatter's business.
- The width check does not run on an aligned data table written
  as comments: a line whose first non-space character is `#` and
  which holds a run of two or more spaces between two columns.
- `email` is only reported as prose. Next to an identifier
  character (a letter, digit, `_`, `.`, `/`, `-` or `@`) it is
  taken as code, so `user.email`, `git send-email` and
  `emailAddress` pass.
- An en-dash between digits is a numeric range and passes; used
  as a dash next to a letter or a space it is reported.
- `license` is skipped after the word `to`, where it is the
  verb, and the verb forms `licensed` and `licensing` are never
  reported.
- Files whose extension is not one of `.md`, `.txt`, `.html`,
  `.lua`, `.qml`, `.sh`, `.go`, `.py`, `.toml`, `.json`, and
  files with no extension at all, are not read.

## The hooks

### `shellcheck-on-write`

`PostToolUse`, matching `Write|Edit|MultiEdit`. When the written
file is a shell script, by `.sh` or `.bash` extension or by a
`bash`/`sh` shebang, it runs `shellcheck -x` over it. Findings
go to stderr and the hook exits 2, which shows them to Claude so
they get fixed in the same turn. It is silent when the file is
not a shell script and when shellcheck is not installed.

### `style-lint`

`PostToolUse`, matching `Write|Edit`. It runs
`lib/style-check.sh` over the written file and exits 2 when
there are findings. Each finding is one `file:line: message`
line on stderr. The checks are em-dashes and en-dashes used as
dashes, `email` in prose, American spellings, and lines over 72
columns, all subject to the exceptions above.

| American | British | American | British |
|---|---|---|---|
| color | colour | organize | organise |
| behavior | behaviour | center | centre |
| license (noun) | licence | favorite | favourite |
| analyze | analyse | catalog | catalogue |
| initialize | initialise | optimize | optimise |
| customize | customise | gray | grey |
| program | program (kept) | | |

### `notify`

`Notification` and `Stop`. It sends the notification through
`donbox notify "<title>" "<body>"` when `donbox` is on `PATH`,
and `notify-send` otherwise. A `Notification` event is sent with
its own message text; a `Stop` event is sent as "Claude
finished" with the basename of the session directory. It does
nothing when both `DISPLAY` and `WAYLAND_DISPLAY` are unset, and
it always exits 0, so a broken notifier can never fail a turn.

## Installation

Copy the scripts into the configuration directory and merge
`hooks.json` into `settings.json`:

```sh
cp -r hooks lib "$CLAUDE_CONFIG_DIR/"
```

The commands in `hooks.json` are absolute paths under `$HOME`.
A `command` hook without `args` is run through `sh -c`, so the
variable is expanded by the shell at execution time. The `lib`
directory has to sit beside `hooks`: each hook resolves its own
directory and sources `lib/hook-input.sh` from there.

`jq` is required. `shellcheck` is optional: without it the
shellcheck hook stays silent.

## Running the checker by hand

```sh
lib/style-check.sh README.md hooks/notify
```

It exits 0 when clean, 1 when it has findings, and 2 on a usage
error, which is why the hook only blocks on 1.

## Tests

```sh
test/run
```

The runner drives every hook with crafted stdin payloads over
fixture files in a temporary directory, asserting exit status
and stderr. The notify tests put stub `notify-send` and `donbox`
scripts on `PATH` and read the log they write, so nothing is
ever shown on screen. The last case runs `shellcheck -x` over
every script in the tree, the runner included.

## Layout

```
hooks/shellcheck-on-write   PostToolUse: Write|Edit|MultiEdit
hooks/style-lint            PostToolUse: Write|Edit
hooks/notify                Notification, Stop
lib/hook-input.sh           stdin payload helpers
lib/style-check.sh          the prose and width checker
hooks.json                  the settings.json fragment
test/run                    the test runner
```
