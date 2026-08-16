# shellcheck shell=bash

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    printf 'base-test.sh is a library, not a suite\n' >&2
    exit 1
fi

ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)
readonly ROOT
export ROOT

BIN_DIR="${ROOT}/.local/bin"
readonly BIN_DIR
export BIN_DIR

pass() {
    printf 'ok - %s\n' "$1"
}

# The first failure ends the file, so later assertions cannot
# report against state the failure already invalidated.
fail() {
    [[ $# -lt 2 ]] || printf '%s\n' "$2" >&2
    printf 'not ok - %s\n' "$1" >&2
    exit 1
}

assert() {
    "${@:2}" || fail "$1"
    pass "$1"
}

assert_equal() {
    [[ "$2" == "$3" ]] ||
        fail "$1" "expected '$3', got '$2'"
    pass "$1"
}

assert_status() {
    local description="$1" expected="$2" status=0
    shift 2
    "$@" >/dev/null 2>&1 || status=$?
    [[ "${status}" == "${expected}" ]] ||
        fail "${description}" \
            "expected exit ${expected}, got ${status}"
    pass "${description}"
}

require_command() {
    command -v "$1" >/dev/null 2>&1 ||
        fail "$1 is required but not installed"
}

# Sets WORKSPACE rather than printing it: a trap armed inside a
# command substitution belongs to the subshell and fires before
# the caller has used the directory.
workspace() {
    WORKSPACE=$(mktemp -d)
    trap 'rm -rf "${WORKSPACE}"' EXIT
}
