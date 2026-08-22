# Git and releases

- Always use `master` as the default git branch name, never
  `main`.
- Add the intended remote immediately after `git init`, before
  the first commit: my git identity and signing key resolve from
  the remote URL (includeIf), so verify with
  `git config user.email` before committing anything.
- Sign everything published: commits and tags carry my GPG
  signature.
- Commit locally whenever the work is green, but never push
  without my explicit go-ahead; one authorisation covers one
  push, not a session.
- Commit messages follow Conventional Commits
  (conventionalcommits.org): `type(scope): subject`, with the
  area touched as the scope and `!` for breaking changes. Write
  them the way a human developer does: short, plain subjects that
  read as release notes, and no body at all in the ordinary case.
  Reach for a body only when the reasoning genuinely cannot be
  inferred from the diff, and keep it to a line or two. Never
  sign a commit with a co-author or assistant attribution
  trailer.
- Never commit assistant or session artefacts (HANDOFF.md,
  `.claude/`, session notes) to a repository: gitignore them
  before the first commit.
- Never put my real personal data (name, e-mail addresses,
  domains, client or project names) in committed files: defaults,
  fixtures, seeds, mock content and docs use obviously dummy data
  (example.com, invented names). My public repos are
  pseudonymous; anything traceable to me is a leak, and it must
  be purged from history, not just the tip.
- Pin dependencies to immutable refs (release tags or commit
  hashes), never moving branches; bump deliberately and record
  why.
- Versions come from git, once: derive version strings from the
  tag at build or package time; never hardcode copies of the
  version anywhere else.
