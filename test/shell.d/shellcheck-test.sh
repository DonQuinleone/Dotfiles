#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command shellcheck

# Only the entry points: a sourced fragment read on its own
# reports every variable its caller supplies, and -x already
# follows it from the script that sources it.
shell_scripts() {
    local path
    while IFS= read -r -d '' path; do
        [[ -f "${ROOT}/${path}" ]] || continue
        head -n 1 "${ROOT}/${path}" |
            grep -q '^#!.*\bbash\b' || continue
        printf '%s\0' "${path}"
    done < <(git -C "${ROOT}" ls-files -z \
        --cached --others --exclude-standard)
}

scripts=()
mapfile -t -d '' scripts < <(shell_scripts)

assert "the repository has shell scripts to check" \
    [ "${#scripts[@]}" -gt 0 ]

assert_status "shellcheck passes on all ${#scripts[@]} scripts" \
    0 shellcheck -x -- "${scripts[@]}"
