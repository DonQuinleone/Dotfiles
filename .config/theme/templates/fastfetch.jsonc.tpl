{
    "logo": {
        "color": {
            "1": "{{ accent }}",
            "2": "{{ foreground }}",
            "3": "{{ dark_foreground }}"
        },
        "padding": {
            "top": 1,
            "right": 4
        }
    },
    "display": {
        "separator": " › ",
        "color": {
            "keys": "{{ accent }}",
            "title": "{{ accent }}",
            "separator": "{{ dark_foreground }}"
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
            "format": "{name} {version-id} (donbox) {arch}"
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
