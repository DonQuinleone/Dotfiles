#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

workspace

readonly NIGHTSHIFT_RENAME=1787344709

apply() {
    "${ROOT}/migrations/$1.sh"
}

scenario() {
    export XDG_CONFIG_HOME="${WORKSPACE}/$1/config"
    export XDG_STATE_HOME="${WORKSPACE}/$1/state"
    mkdir -p "${XDG_CONFIG_HOME}" "${XDG_STATE_HOME}"
}

write() {
    mkdir -p "$(dirname "$1")"
    printf '%s\n' "$2" >"$1"
}

scenario legacy
write "${XDG_STATE_HOME}/night-shift/override" "4000"
write "${XDG_CONFIG_HOME}/night-shift.conf" "NIGHT_TEMPERATURE=4200"

apply "${NIGHTSHIFT_RENAME}" >/dev/null

assert_equal "the schedule keeps the temperature it was left at" \
    "$(cat "${XDG_STATE_HOME}/donbox/nightshift/override")" "4000"

assert_equal "the configuration comes across as it was written" \
    "$(cat "${XDG_CONFIG_HOME}/donbox/nightshift.conf")" \
    "NIGHT_TEMPERATURE=4200"

assert "the old state directory is gone" \
    [ ! -e "${XDG_STATE_HOME}/night-shift" ]

assert "the old configuration file is gone" \
    [ ! -e "${XDG_CONFIG_HOME}/night-shift.conf" ]

apply "${NIGHTSHIFT_RENAME}" >/dev/null

assert_equal "running it twice changes nothing" \
    "$(cat "${XDG_CONFIG_HOME}/donbox/nightshift.conf")" \
    "NIGHT_TEMPERATURE=4200"

scenario settled
write "${XDG_STATE_HOME}/donbox/nightshift/override" "3800"
write "${XDG_CONFIG_HOME}/donbox/nightshift.conf" "ENABLED=0"

apply "${NIGHTSHIFT_RENAME}" >/dev/null

assert_equal "a machine already moved keeps its own schedule" \
    "$(cat "${XDG_STATE_HOME}/donbox/nightshift/override")" "3800"

assert_equal "a machine already moved keeps its own settings" \
    "$(cat "${XDG_CONFIG_HOME}/donbox/nightshift.conf")" "ENABLED=0"

scenario contested
write "${XDG_CONFIG_HOME}/night-shift.conf" "ENABLED=1"
write "${XDG_CONFIG_HOME}/donbox/nightshift.conf" "ENABLED=0"

apply "${NIGHTSHIFT_RENAME}" 2>/dev/null

assert_equal "a file at the new name is never written over" \
    "$(cat "${XDG_CONFIG_HOME}/donbox/nightshift.conf")" "ENABLED=0"

assert "the file it declined to move is left where it was" \
    [ -e "${XDG_CONFIG_HOME}/night-shift.conf" ]

readonly GENERATED_STATE=1787345134

# Stow's fold: what the application writes to is a link into the
# working tree, so the tree is where the file really is.
fold() {
    mkdir -p "$(dirname "$1")"
    ln -sfn "$2" "$1"
}

scenario folded
readonly TREE="${WORKSPACE}/folded/tree"
readonly CURRENT="${XDG_STATE_HOME}/donbox/current"

write "${XDG_STATE_HOME}/theme/shell-colours.sh" "THEME_ACCENT=dc6f00"
write "${TREE}/lsd/colors.yaml" "user: 1"
write "${TREE}/quickshell/themes/current.json" '{"name":"ember"}'
fold "${XDG_CONFIG_HOME}/lsd" "${TREE}/lsd"
fold "${XDG_CONFIG_HOME}/quickshell" "${TREE}/quickshell"

apply "${GENERATED_STATE}" >/dev/null

assert_equal "what the theme generated comes across whole" \
    "$(cat "${CURRENT}/shell-colours.sh")" "THEME_ACCENT=dc6f00"

assert "the directory it was generated into is gone" \
    [ ! -e "${XDG_STATE_HOME}/theme" ]

assert_equal "a file written through the fold is taken out of it" \
    "$(cat "${CURRENT}/lsd-colors.yaml")" "user: 1"

assert "the working tree keeps none of it" \
    [ ! -e "${TREE}/lsd/colors.yaml" ]

assert_equal "the resolved theme is taken out too" \
    "$(cat "${CURRENT}/theme.json")" '{"name":"ember"}'

apply "${GENERATED_STATE}" >/dev/null

assert_equal "running it twice changes nothing" \
    "$(cat "${CURRENT}/lsd-colors.yaml")" "user: 1"

scenario moved
write "${XDG_STATE_HOME}/donbox/current/lsd-colors.yaml" "kept: 1"
write "${XDG_STATE_HOME}/donbox/current/shell-colours.sh" "kept=1"

apply "${GENERATED_STATE}" >/dev/null

assert_equal "a machine already moved keeps what it generated" \
    "$(cat "${XDG_STATE_HOME}/donbox/current/lsd-colors.yaml")" \
    "kept: 1"

scenario contested-state
write "${XDG_STATE_HOME}/theme/shell-colours.sh" "THEME_ACCENT=old"
write "${XDG_STATE_HOME}/donbox/current/shell-colours.sh" \
    "THEME_ACCENT=new"
write "${XDG_STATE_HOME}/theme/fzf-opts" "--height 40%"

apply "${GENERATED_STATE}" >/dev/null

assert_equal "the newer copy is never written over" \
    "$(cat "${XDG_STATE_HOME}/donbox/current/shell-colours.sh")" \
    "THEME_ACCENT=new"

assert_equal "what only the old directory had comes across" \
    "$(cat "${XDG_STATE_HOME}/donbox/current/fzf-opts")" "--height 40%"
