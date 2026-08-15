# shellcheck shell=bash

readonly FASTFETCH_CONFIG_FILE="${CONFIG_HOME}/fastfetch/config.jsonc"
readonly FASTFETCH_LOGO_FILE="${CONFIG_HOME}/fastfetch/logo/logo-color.txt"

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
        "os",
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
    mkdir -p "$(dirname "${FASTFETCH_CONFIG_FILE}")"
    write_fastfetch_config
}
