# shellcheck shell=bash

# One list, whichever manager a thing comes from. dnf answers for
# seventy thousand packages in under a second and Flathub for
# three thousand in about the same, so the whole catalogue is
# built once and the chooser does the searching, rather than a
# query running against a manager on every keystroke.

readonly FLATPAK_REMOTE=flathub
readonly CATALOGUE_KIND_WIDTH=7
readonly CATALOGUE_NAME_WIDTH=32

# Every source settles on name, kind and a description before
# anything is shown, so only one thing knows how a row is laid
# out. Columns are padded rather than hidden behind a separator,
# so what the chooser reads is what the reader sees, and the kind
# and the name fall in the first two words where the chooser can
# hand them straight back.
catalogue_display() {
    awk -F'\t' -v kw="${CATALOGUE_KIND_WIDTH}" \
        -v nw="${CATALOGUE_NAME_WIDTH}" '
        { printf "%-*s %-*s %s\n", kw, $2, nw, $1, $3 }
    '
}

# dnf's query format prints a tab as the two characters it is
# written with, so the columns are cut apart on the first space
# instead: a package name never holds one.
catalogue_dnf_rows() {
    dnf -q repoquery --available --qf '%{name} %{summary}\n' \
        2>/dev/null | sort -u |
        awk 'BEGIN { OFS = "\t" }
            { name = $1
              print name, "dnf", substr($0, length(name) + 2) }'
}

# Flathub names a thing twice, once for the machine and once for
# a person, and both are worth searching.
catalogue_flatpak_rows() {
    flatpak remote-ls "${FLATPAK_REMOTE}" --app \
        --columns=application,name,description 2>/dev/null |
        awk -F'\t' 'BEGIN { OFS = "\t" }
            { print $1, "flatpak", $2 ", " $3 }'
}

catalogue_rows() {
    {
        catalogue_dnf_rows
        catalogue_flatpak_rows
    } | catalogue_display
}

# What the manifest claims, which is the only honest answer to
# "what is mine to remove".
catalogue_manifest_rows() {
    local kind name
    for kind in dnf flatpak; do
        while read -r name; do
            [[ -n "${name}" ]] || continue
            printf '%s\t%s\t%s\n' "${name}" "${kind}" \
                "in the manifest"
        done < <(manifest_list "${kind}")
    done | catalogue_display
}

catalogue_describe() {
    local kind="$1" name="$2"
    case "${kind}" in
    dnf) dnf -q info "${name}" 2>&1 ;;
    flatpak)
        flatpak remote-info "${FLATPAK_REMOTE}" "${name}" 2>&1
        ;;
    *) printf 'no such kind: %s\n' "${kind}" ;;
    esac
}

catalogue_install() {
    local kind="$1"
    shift
    case "${kind}" in
    dnf) sudo dnf install "$@" ;;
    flatpak) sudo flatpak install -y "${FLATPAK_REMOTE}" "$@" ;;
    esac
}

catalogue_uninstall() {
    local kind="$1"
    shift
    case "${kind}" in
    dnf) sudo dnf remove "$@" ;;
    flatpak) sudo flatpak uninstall -y "$@" ;;
    esac
}
