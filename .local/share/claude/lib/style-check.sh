#!/usr/bin/env bash

set -euo pipefail
shopt -s nocasematch

readonly UTF8_LOCALE=C.UTF-8
export LC_ALL=$UTF8_LOCALE

readonly MAX_COLUMNS=72
readonly FINDINGS_STATUS=1
readonly USAGE_STATUS=2
readonly NO_EXTENSION=none
readonly NO_EXCLUSION=-
readonly SPELLING_KEEP=keep

readonly EM_DASH=$'—'
readonly EN_DASH=$'–'
readonly EN_DASH_PATTERN="([[:alpha:][:space:]])$EN_DASH\
|$EN_DASH([[:alpha:][:space:]])"
readonly URL_PATTERN='(https?://|www\.)'
readonly TABLE_ROW_PATTERN='^[[:space:]]*\|'
readonly FENCE_PATTERN='^[[:space:]]*(```|~~~)'
# shellcheck disable=SC2016
readonly INLINE_CODE_PATTERN='`[^`]*`'
readonly WORD_PREFIX='(^|[^[:alpha:]])'
readonly WORD_SUFFIX='([^[:alpha:]]|$)'
readonly IDENTIFIER_CHARS='[^[:alnum:]_./@-]'
readonly EMAIL_PATTERN="(^|$IDENTIFIER_CHARS)(emails?)\
($IDENTIFIER_CHARS|\$)"
readonly ALIGNED_COLUMNS='[^[:space:]][[:space:]]{2,}[^[:space:]]'

readonly CHECKED_EXTENSIONS=(
  md txt html lua qml sh go py toml json "$NO_EXTENSION"
)
readonly WRAP_EXEMPT_EXTENSIONS=(html json qml go)

readonly AMERICAN_SPELLINGS=(
  "color(s|ed|ing|ful|less)?;colour;$NO_EXCLUSION"
  "organiz(e|es|ed|ing|ation|ations|er|ers);organise;$NO_EXCLUSION"
  "behavior(s|al|ally)?;behaviour;$NO_EXCLUSION"
  "center(s|ed|ing)?;centre;$NO_EXCLUSION"
  "licen(se|ses);licence;to[[:space:]]+licen"
  "favorite(s)?;favourite;$NO_EXCLUSION"
  "analyz(e|es|ed|ing|er|ers);analyse;$NO_EXCLUSION"
  "catalog(s|ed|ing)?;catalogue;$NO_EXCLUSION"
  "initializ(e|es|ed|ing|ation);initialise;$NO_EXCLUSION"
  "optimiz(e|es|ed|ing|ation|ations);optimise;$NO_EXCLUSION"
  "customiz(e|es|ed|ing|ation);customise;$NO_EXCLUSION"
  "gray(s|ed|ing|ish|er|est)?;grey;$NO_EXCLUSION"
  "program(s|med|ming)?;$SPELLING_KEEP;$NO_EXCLUSION"
)

findings_count=0

report() {
  local -r path=$1 number=$2 message=$3
  printf '%s:%s: %s\n' "$path" "$number" "$message" >&2
  findings_count=$((findings_count + 1))
}

contains_word() {
  local -r needle=$1
  shift
  local candidate
  for candidate in "$@"; do
    if [[ $candidate == "$needle" ]]; then
      return 0
    fi
  done
  return 1
}

file_extension() {
  local -r name=${1##*/}
  local -r body=${name#.}
  if [[ $body != *.* ]]; then
    printf '%s' "$NO_EXTENSION"
    return 0
  fi
  printf '%s' "${body##*.}"
}

strip_inline_code() {
  local text=$1
  while [[ $text =~ $INLINE_CODE_PATTERN ]]; do
    text=${text/"${BASH_REMATCH[0]}"/ }
  done
  printf '%s' "$text"
}

is_aligned_comment_table() {
  local -r line=$1
  local -r indent=${line%%[![:space:]]*}
  local -r trimmed=${line#"$indent"}
  [[ $trimmed == '#'* && $line =~ $ALIGNED_COLUMNS ]]
}

report_dashes() {
  local -r path=$1 number=$2 prose=$3
  if [[ $prose == *"$EM_DASH"* ]]; then
    report "$path" "$number" \
      'em-dash: use a comma, colon, semicolon or parentheses'
  fi
  if [[ $prose =~ $EN_DASH_PATTERN ]]; then
    report "$path" "$number" 'en-dash used as a dash'
  fi
}

report_email() {
  local -r path=$1 number=$2 prose=$3
  if [[ $prose =~ $URL_PATTERN ]]; then
    return 0
  fi
  if [[ ! $prose =~ $EMAIL_PATTERN ]]; then
    return 0
  fi
  report "$path" "$number" \
    "\"${BASH_REMATCH[2]}\" in prose: spell it \"e-mail\""
}

report_american_spellings() {
  local -r path=$1 number=$2 prose=$3
  if [[ $prose =~ $URL_PATTERN || $prose =~ $TABLE_ROW_PATTERN ]]; then
    return 0
  fi
  local row pattern british exclusion regex
  for row in "${AMERICAN_SPELLINGS[@]}"; do
    IFS=';' read -r pattern british exclusion <<<"$row"
    if [[ $british == "$SPELLING_KEEP" ]]; then
      continue
    fi
    if [[ $exclusion != "$NO_EXCLUSION" && $prose =~ $exclusion ]]; then
      continue
    fi
    regex="$WORD_PREFIX($pattern)$WORD_SUFFIX"
    if [[ ! $prose =~ $regex ]]; then
      continue
    fi
    report "$path" "$number" \
      "\"${BASH_REMATCH[2]}\" is US spelling: use \"$british\""
  done
}

is_wrap_exempt() {
  local -r line=$1 extension=$2
  if contains_word "$extension" "${WRAP_EXEMPT_EXTENSIONS[@]}"; then
    return 0
  fi
  if [[ $line =~ $TABLE_ROW_PATTERN || $line =~ $URL_PATTERN ]]; then
    return 0
  fi
  is_aligned_comment_table "$line"
}

report_long_line() {
  local -r path=$1 number=$2 line=$3 extension=$4
  if is_wrap_exempt "$line" "$extension"; then
    return 0
  fi
  if (( ${#line} <= MAX_COLUMNS )); then
    return 0
  fi
  report "$path" "$number" \
    "${#line} columns: wrap at $MAX_COLUMNS"
}

check_line() {
  local -r path=$1 number=$2 line=$3 extension=$4
  local prose
  prose=$(strip_inline_code "$line")
  report_dashes "$path" "$number" "$prose"
  report_email "$path" "$number" "$prose"
  report_american_spellings "$path" "$number" "$prose"
  report_long_line "$path" "$number" "$line" "$extension"
}

check_file() {
  local -r path=$1
  local extension
  extension=$(file_extension "$path")
  if ! contains_word "$extension" "${CHECKED_EXTENSIONS[@]}"; then
    return 0
  fi
  local -a lines=()
  mapfile -t lines <"$path"
  local number in_fence=0
  for (( number = 1; number <= ${#lines[@]}; number++ )); do
    local line=${lines[number - 1]}
    if [[ $line =~ $FENCE_PATTERN ]]; then
      in_fence=$((1 - in_fence))
      continue
    fi
    if (( in_fence == 1 )); then
      continue
    fi
    check_line "$path" "$number" "$line" "$extension"
  done
}

main() {
  if (( $# == 0 )); then
    printf 'usage: %s <path>...\n' "${0##*/}" >&2
    exit "$USAGE_STATUS"
  fi
  local path
  for path in "$@"; do
    if [[ ! -f $path ]]; then
      printf '%s: not a readable file\n' "$path" >&2
      exit "$USAGE_STATUS"
    fi
    check_file "$path"
  done
  if (( findings_count > 0 )); then
    exit "$FINDINGS_STATUS"
  fi
}

main "$@"
