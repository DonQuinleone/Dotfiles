---
paths: ["**/*.sh", "**/*.bash", "**/bin/**", "**/.bashrc", "**/*.fish"]
---

# Shell scripts

- New shell scripts use `#!/usr/bin/env bash`, never
  `#!/bin/bash`.
- Every new or edited shell script passes shellcheck before the
  work is done.
- Fail fast and loudly: scripts use `set -euo pipefail`, validate
  inputs early, and error with messages naming the actual
  problem.
- Provisioning and state-changing scripts must be idempotent:
  safe to re-run.
- The rules in `rules/style.md` apply to scripts as much as to
  code: guard clauses instead of nested ifs, named constants
  instead of magic numbers, data tables instead of repeated
  branches, and no comments beyond a genuine non-obvious why.
