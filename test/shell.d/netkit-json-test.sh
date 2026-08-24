#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR

set -euo pipefail

here=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
source "${here}/base-test.sh"

require_command luajit

# ROOT and the expression travel by environment so bash never
# reprocesses the snippet's quotes or backslashes.
encode() {
    NK_ROOT="${ROOT}" NK_EXPR="$1" luajit -e '
        package.path = os.getenv("NK_ROOT") ..
            "/.local/lib/?.lua;" .. package.path
        local json = require("netkit.json")
        local value = load("return " .. os.getenv("NK_EXPR"))()
        io.write(json.encode(value))'
}

assert_equal "a list encodes as an array" \
    "$(encode '{ 1, 2, 3 }')" "[1,2,3]"
assert_equal "an object sorts its keys" \
    "$(encode '{ b = 2, a = 1 }')" '{"a":1,"b":2}'
assert_equal "an empty table encodes as an array" \
    "$(encode '{}')" "[]"
assert_equal "booleans and strings encode" \
    "$(encode '{ ok = true, s = "hi" }')" \
    '{"ok":true,"s":"hi"}'

assert_equal "control characters are escaped" \
    "$(encode '{ s = string.char(97, 9, 98, 10, 99) }')" \
    '{"s":"a\tb\nc"}'
assert_equal "a high byte becomes a unicode escape" \
    "$(encode '{ s = string.char(255) }')" '{"s":"\u00ff"}'
assert_equal "a quote and backslash are escaped" \
    "$(encode '{ s = [[a"b\c]] }')" '{"s":"a\"b\\c"}'

assert_equal "not-a-number becomes null" \
    "$(encode '{ n = 0/0 }')" '{"n":null}'
assert_equal "infinity becomes null" \
    "$(encode '{ n = 1/0 }')" '{"n":null}'

# The output must survive a strict parser, not just lenient jq.
banner=$(encode '{ s = "220 " .. string.char(255, 27) .. "x" }')
printf '%s' "${banner}" |
    python3 -c 'import json,sys; json.load(sys.stdin)' ||
    fail "encoder output parses as strict json"
pass "encoder output parses as strict json"
