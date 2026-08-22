---
paths: ["**/.builds/**"]
---

# SourceHut

- Use the `hut` CLI (e.g. `hut builds show <id>`, `hut todo`,
  `hut pages publish`, `hut git artifact`) or
  `ssh -t builds@<runner>.builds.sr.ht connect <job>` to read
  build logs and debug; do not scrape sr.ht web pages (they sit
  behind an anti-bot challenge and will refuse).
- SourceHut runs at most four builds per push, so a fifth
  manifest in `.builds/` is silently starved: keep it to four, or
  submit the extra one with `hut builds submit`.
- A push is not a publish: pages sites (`hut pages publish`), tag
  artefacts and mirrors are separate steps, so verify the live
  result rather than assuming the push deployed it.
