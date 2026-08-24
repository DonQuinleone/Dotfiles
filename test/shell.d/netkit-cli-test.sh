#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR

set -euo pipefail

here=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
source "${here}/base-test.sh"

require_command luajit

workspace

# A script file lets luajit populate the global arg table the way
# the real bins see it. The spec has one section flag and one
# value flag; the probe prints target|json|sections|value, and
# relies on cli.parse to os.exit(64) on a usage error and 0 on
# --help.
probe="${WORKSPACE}/cli-probe.lua"
cat >"${probe}" <<LUA
package.path = "${ROOT}/.local/lib/?.lua;" .. package.path
local cli = require("netkit.cli")
local spec = {
    name = "t", usage = "usage",
    sections = { ["--net"] = "net", ["--dns"] = "dns" },
    values = {
        ["--type"] = function(o, v)
            if not v:match("^%u+\$") then return false end
            o.type = v
            return true
        end,
    },
}
local o = cli.parse(spec)
local secs = {}
for k in pairs(o.sections) do secs[#secs + 1] = k end
table.sort(secs)
io.write((o.target or "nil") .. "|" ..
    tostring(o.json or false) .. "|" ..
    table.concat(secs, ",") .. "|" .. (o.type or "-"))
LUA

parse() {
    luajit "${probe}" "$@"
}

assert_equal "a bare target selects every section" \
    "$(parse example.com)" "example.com|false|dns,net|-"
assert_equal "a section flag limits the sections" \
    "$(parse --net example.com)" "example.com|false|net|-"
assert_equal "--json sets the json option" \
    "$(parse --json --dns example.com)" \
    "example.com|true|dns|-"
assert_equal "a value flag consumes the next argument" \
    "$(parse --type MX example.com)" \
    "example.com|false|dns,net|MX"

assert_status "no argument is a usage error" 64 parse
assert_status "an unknown flag is a usage error" 64 \
    parse --nope example.com
assert_status "a second positional is a usage error" 64 \
    parse a.com b.com
assert_status "a value flag with no value is a usage error" 64 \
    parse example.com --type
assert_status "a rejected value is a usage error" 64 \
    parse --type lower example.com
assert_status "--help exits zero" 0 parse --help
