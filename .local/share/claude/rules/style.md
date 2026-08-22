# Code style

- Follow clean code practices: prioritise readability and
  simplicity, so code reads clearly without needing explanation.
- Opening curly braces go on the same line as the statement,
  never the line below.
- Avoid nested ifs at all costs: flatten with guard clauses,
  early returns or case statements instead.
- No large monolithic files: separate code logically into
  smaller, digestible files, with a hard limit of 500 lines per
  source file; split a file before it crosses the limit, and
  refactor any that has.
- When splitting an oversized file, keep the original as a thin
  facade that re-exports the moved items, so external callers
  keep their existing paths and the change stays small and
  reviewable; only rename call sites when the new structure is
  the point.
- Functions do one thing: a name that needs an "and" means it
  should be two functions.
- Meaningful names: words over abbreviations; single letters only
  as loop indices.
- No magic numbers: tunable values become named constants whose
  name conveys the unit or effect; add a comment only when the
  name cannot carry it.
- Don't repeat yourself: extract shared logic rather than
  duplicating it; keep one source of truth for every fact or
  value.
- Prefer tables to repeated branches: when statements or branches
  repeat with only the data varying (flag parsing, key bindings,
  menu items), put the varying parts in a dwm-style data table
  and loop over it; if entries still need wrapper boilerplate
  (e.g. adapter lambdas), reshape the handlers to share one
  signature so rows are plain data.
- Prefer absolute paths over relative ones: reference code from
  the crate or project root, never with relative hops.
  `super::super::` is banned outright, and even a single
  `super::` for a cross-module reference gives way to the
  absolute path; absolute paths read unambiguously and survive a
  file being moved. The one tolerated relative form is the
  idiomatic `use super::*;` inside a test submodule.
- Comments are a last resort, not a default: write none unless
  one is genuinely necessary, a non-obvious constraint, gotcha,
  or rationale the code itself cannot carry. Never restate what
  the code does, label sections, or decorate structure. Default
  to zero comments; when in doubt, leave it out. This applies to
  every file type alike: CI workflows, configs and scripts as
  much as code. The one legitimate exception is a version
  annotation on a hash-pinned action or dependency, since the
  hash cannot carry it.
- Global rules are never restated in code: no comments citing
  process or policy ("dummy data only", "per the standards");
  comments stay about the code's own why.
- No speculative scaffolding: never commit placeholder or stub
  files (crates, modules, configs, "coming soon" artefacts) ahead
  of need. A file is created in the commit that first gives it
  real behaviour, and files that stop earning their place are
  deleted.
- Code wraps at 72 columns like everything else; see
  `rules/writing.md` for the rule and its exceptions.
