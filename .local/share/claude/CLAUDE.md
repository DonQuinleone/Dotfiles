# Global rules

- Always use `master` as the default git branch name, never `main`.
- Commit locally whenever the work is green, but never push without my explicit go-ahead; one authorisation covers one push, not a session.
- Sign everything published: commits and tags carry my GPG signature.
- Add the intended remote immediately after `git init`, before the first commit: my git identity and signing key resolve from the remote URL (includeIf), so verify with `git config user.email` before committing anything.
- Never commit assistant or session artefacts (HANDOFF.md, `.claude/`, session notes) to a repository: gitignore them before the first commit.
- Never put my real personal data (name, e-mail addresses, domains, client or project names) in committed files: defaults, fixtures, seeds, mock content and docs use obviously dummy data (example.com, invented names). My public repos are pseudonymous; anything traceable to me is a leak, and it must be purged from history, not just the tip.
- Global rules are never restated in code: no comments citing process or policy ("dummy data only", "per the standards"); comments stay about the code's own why.
- Commit messages follow Conventional Commits (conventionalcommits.org): `type(scope): subject`, with the area touched as the scope and `!` for breaking changes. Subjects double as release notes (user-facing, derived automatically); bodies explain why.
- Refactor in green checkpoints: tag or note a known-good restore point first, then one verified commit per slice (build, tests and a visual check between each).
- Never leave a long-running process silent: report what is running and where its output goes, then check on it at least every two minutes (progress lines, log growth, process still alive) instead of only waiting for it to finish. A hung process must be noticed, not discovered.
- Pin dependencies to immutable refs (release tags or commit hashes), never moving branches; bump deliberately and record why.
- Versions come from git, once: derive version strings from the tag at build/package time; never hardcode copies of the version anywhere else.
- Images in docs must survive dark themes: flatten transparent backgrounds and check them rendered where they are actually published. Check every forge the repo is mirrored to, not just one: absolute git.sr.ht blob URLs render on SourceHut but break on GitHub (its camo proxy refuses external SVGs and mishandles the attachment content-disposition sr.ht sets on PNG/GIF), while relative paths render on GitHub but not on SourceHut. No single scheme is automatic; verify each forge's rendered result.
- Do not use em-dashes in any writing. Use commas, colons, semicolons or parentheses instead.
- Always write in British English.
- Spell "e-mail" with a hyphen, never "email" (except in code, commands, addresses and domain names, e.g. `git send-email`).
- Ask every question with the AskUserQuestion tool, never as plain prose, including open-ended ones: offer best-guess options (with a recommended first option where you have a view) and rely on the built-in Other field for free text.
- Interview before building: for any non-trivial feature or design decision, ask me clarifying questions first rather than building on assumptions.
- Verify visually: check UI and document work by rendering the result (screenshots, rasterised PDFs), never by reading the code alone.
- Look it up, don't guess: verify claims against documentation or real behaviour before asserting them, and say clearly when something is unverified.
- For SourceHut, use the `hut` CLI (e.g. `hut builds show <id>`, `hut todo`, `hut pages publish`, `hut git artifact`) or `ssh -t builds@<runner>.builds.sr.ht connect <job>` to read build logs and debug; do not scrape sr.ht web pages (they sit behind an anti-bot challenge and will refuse). SourceHut runs at most four builds per push, so a fifth manifest in `.builds/` is silently starved: keep it to four, or submit the extra one with `hut builds submit`. A push is not a publish: pages sites (`hut pages publish`), tag artefacts and mirrors are separate steps, so verify the live result rather than assuming the push deployed it.
- When work on a project spans many tasks, or the user is giving rapid multi-threaded feedback that keeps forcing context switches, propose a single backlog and work it top-down instead of reacting per message: for SourceHut projects the project's todo.sr.ht tracker driven via `hut todo`. Suggest it when it would help, and ask before adopting a tracker; once adopted, load the outstanding threads into it and surface only genuine decisions, batched. Keep the tracker live rather than write-once: label every ticket for filtering, open or closed, applying at least one type label on creation and never leaving one blank (`bug`, `feature`, `ux`, `docs`, `refactor`, `ci`, `packaging`, `release`); give each label a Kanagawa Wave background with a solid black or white foreground so it stays legible (muted Kanagawa foregrounds read as low-contrast), and recolour a label by recreating it (`hut todo label delete` then `create -b -f`) since `hut todo label update` silently no-ops on colours; comment progress on them as work moves (`hut todo ticket comment`), and resolve each with the right status and resolution when it lands (`hut todo ticket update-status`) instead of leaving it open. The tracker, not the chat scrollback, is the source of truth for what is done and what remains.
- A long-running process (daemon, dev server) outlives the code it was built from: while iterating on one across a session, the running process silently goes stale against the rebuilt binary. Before diagnosing surprising behaviour as a code bug, check the running process's build age against the current binary and restart it; better, give the client a version health-check that reconciles a mismatched daemon on launch. When restarting a process that holds a mounted or locked resource (a vault, a socket), wait for the old one to fully exit and release it before starting the new one, or the two race.
- Avoid nested ifs at all costs: flatten with guard clauses, early returns or case statements instead.
- No large monolithic files: separate code logically into
  smaller, digestible files, with a hard limit of 500 lines per
  source file; split a file before it crosses the limit, and
  refactor any that has.
- When splitting an oversized file, keep the original as a thin facade that re-exports the moved items, so external callers keep their existing paths and the change stays small and reviewable; only rename call sites when the new structure is the point.
- Opening curly braces go on the same line as the statement, never the line below.
- Wrap everything at 72 columns: code, comments, prose and commit messages alike.
- Follow clean code practices: prioritise readability and simplicity, so code reads clearly without needing explanation.
- READMEs and user-facing docs are written to the standard of a well-run open-source project, not generic boilerplate: lead with what it is and why, then concrete usage, where any images or artefacts are hosted, a configuration reference, and how to build and contribute. Reflect the actual project (real names, URLs, commands), never placeholder-generic text.
- Don't repeat yourself: extract shared logic rather than duplicating it; keep one source of truth for every fact or value.
- Prefer tables to repeated branches: when statements or branches repeat with only the data varying (flag parsing, key bindings, menu items), put the varying parts in a dwm-style data table and loop over it; if entries still need wrapper boilerplate (e.g. adapter lambdas), reshape the handlers to share one signature so rows are plain data.
- Comments are a last resort, not a default: write none unless one is genuinely necessary, a non-obvious constraint, gotcha, or rationale the code itself cannot carry. Never restate what the code does, label sections, or decorate structure. Default to zero comments; when in doubt, leave it out. This applies to every file type alike: CI workflows, configs and scripts as much as code (version annotations on hash-pinned actions are a legitimate exception, since the hash cannot carry them).
- No speculative scaffolding: never commit placeholder or stub files (crates, modules, configs, "coming soon" artefacts) ahead of need. A file is created in the commit that first gives it real behaviour, and files that stop earning their place are deleted.
- Parallelise with subagents: fan independent slices of work out to concurrent subagents (worktree isolation when they mutate files).
- Integrate parallel worktree agents by cherry-picking or rebasing their commits onto current master, never by merging the agent's branch wholesale: an agent branched from a base that master has since moved past will revert the newer work if merged. Commit anything an agent left uncommitted in its worktree first, then replay it onto the current tip and resolve conflicts there.
- Never sit idle while background tasks or subagents run, and never end a turn on "waiting for X". Before any pause, enumerate what does not conflict with work in flight (the next milestone item, tests, docs, tooling, review prep) and start it; treat "I'm blocked" as a claim requiring proof, since it has been wrong every time so far. A turn may end only on genuine user input being required, or when every remaining task would touch files an active agent owns.
- Research conventions before building standard infrastructure: when setting up CI pipelines, packaging, release flows and the like, first study how flagship projects in that ecosystem structure theirs and follow those conventions rather than inventing a shape.
- No magic numbers: tunable values become named constants whose name conveys the unit or effect; add a comment only when the name cannot carry it.
- Functions do one thing: a name that needs an "and" means it should be two functions.
- Meaningful names: words over abbreviations; single letters only as loop indices.
- Prefer absolute paths over relative ones: reference code from the crate or project root, never with relative hops. `super::super::` is banned outright, and even a single `super::` for a cross-module reference gives way to the absolute path; absolute paths read unambiguously and survive a file being moved. The one tolerated relative form is the idiomatic `use super::*;` inside a test submodule.
- Every new or edited shell script passes shellcheck before the work is done.
- Fail fast and loudly: scripts use `set -euo pipefail`, validate inputs early, and error with messages naming the actual problem.
- Provisioning and state-changing scripts must be idempotent: safe to re-run.
- Where a project has a test framework, new behaviour lands with a test.
- Tests never touch the real system: gate every side-effecting call (a system opener like `open`/`xdg-open`, desktop notifications, sound or speech, network requests, spawned subprocesses) to a no-op under test, so the suite never pops a window, plays a sound, hits the network or launches a process on the machine. A test that exercises such a path asserts the decision, not the effect.
- New shell scripts use `#!/usr/bin/env bash`, never `#!/bin/bash`.
- Every tool that supports colour follows the active desktop
  theme, applied by `theme set`: the shell, Hyprland, Ghostty,
  the bash and fish prompts, GTK, Qt, TeamSpeak and Neovim all
  read the same palette, so a tool that hardcodes its own
  colours is a bug. Ember (background `#1B1B1B`, foreground
  `#E7E7E7`, accent `#DC6F00`) is the default of seventeen.
- Keep `$HOME` clean: configure tools to store config, cache and state in XDG locations whenever they allow it.
- Never leave working state inside a repository: git worktrees belong under `$XDG_STATE_HOME/<project>-worktrees/`, created with `git worktree add` and entered by path, never in a `.claude/` directory inside the checkout. Remove each one the moment its work is integrated rather than letting them accumulate, since every worktree is a full checkout. `~/.claude` must not exist: `CLAUDE_CONFIG_DIR` already points at `~/.local/share/claude`.
- Shared dotfiles config must be portable: no hardcoded `/opt/homebrew` or `/Users/...` paths; OS-specific values live in the macos/linux stow packages.
- When a new CLI tool is adopted, add it to `get_packages.sh` (and the README's Linux tool list) as part of the same piece of work.

