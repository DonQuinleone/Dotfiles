#!/usr/bin/env bash

hook_field() {
  local -r payload=$1 field=$2
  printf '%s' "$payload" | jq -r "$field // empty"
}

has_command() {
  command -v "$1" >/dev/null 2>&1
}
