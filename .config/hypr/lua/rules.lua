hl.window_rule({
    name = "float-portal-dialogs",
    match = { class = "^xdg-desktop-portal-gtk$" },
    float = true,
    size = "1200 800",
    center = true,
})

hl.window_rule({
    match = { title = "Picture-in-Picture" },
    float = true,
    pin = true,
})

hl.window_rule({
    match = {
        class = "^$",
        title = "^$",
        xwayland = true,
        float = true,
        fullscreen = false,
        pin = false,
    },
    no_focus = true,
})

hl.window_rule({
    name = "float-slack-huddle",
    match = {
        class = "^com\\.slack\\.Slack$",
        initial_title = "^Slack – Huddle preview$",
    },
    float = true,
    size = "1200 800",
    center = true,
})

hl.window_rule({
    name = "float-writ-capture",
    match = { class = "^writ-capture$" },
    float = true,
    size = "800 100",
    center = true,
})
