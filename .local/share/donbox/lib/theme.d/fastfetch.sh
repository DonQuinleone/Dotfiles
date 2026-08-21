# shellcheck shell=bash

readonly FASTFETCH_CONFIG_FILE="${STATE_DIR}/fastfetch.jsonc"
FASTFETCH_LOGO_FILE="${CONFIG_HOME}/fastfetch"
FASTFETCH_LOGO_FILE+="/logo/logo-color.txt"
readonly FASTFETCH_LOGO_FILE

# os-release names no variant at all, and fedora-release owns the
# file, so a root edit would be undone by the next update.
readonly DESKTOP_FLAVOUR="donbox"

write_fastfetch_config() {
    cat >"${FASTFETCH_CONFIG_FILE}" <<EOF
{
    "logo": {
        "type": "file",
        "source": "${FASTFETCH_LOGO_FILE}",
        "color": {
            "1": "${COLOURS[accent]}",
            "2": "${COLOURS[fg]}",
            "3": "${COLOURS[fgDim]}"
        },
        "padding": {
            "top": 1,
            "right": 4
        }
    },
    "display": {
        "separator": " › ",
        "color": {
            "keys": "${COLOURS[accent]}",
            "title": "${COLOURS[accent]}",
            "separator": "${COLOURS[fgDim]}"
        }
    },
    "modules": [
        {
            "type": "title",
            "format": "{user-name}@{host-name}"
        },
        "separator",
        {
            "type": "os",
            "format": "{name} {version-id} (${DESKTOP_FLAVOUR}) {arch}"
        },
        "host",
        "kernel",
        "uptime",
        "packages",
        "shell",
        "terminal",
        "cpu",
        "gpu",
        "memory",
        "disk",
        "colors"
    ]
}
EOF
}

apply_fastfetch() {
    mkdir -p "${STATE_DIR}"
    write_fastfetch_config
}
