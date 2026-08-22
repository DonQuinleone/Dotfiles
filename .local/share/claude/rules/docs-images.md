---
paths: ["**/*.md", "**/docs/**"]
---

# Images in docs

- Images in docs must survive dark themes: flatten transparent
  backgrounds and check them rendered where they are actually
  published.
- Check every forge the repo is mirrored to, not just one:
  absolute git.sr.ht blob URLs render on SourceHut but break on
  GitHub (its camo proxy refuses external SVGs and mishandles the
  attachment content-disposition sr.ht sets on PNG/GIF), while
  relative paths render on GitHub but not on SourceHut. No single
  scheme is automatic; verify each forge's rendered result.
