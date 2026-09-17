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
    name = "wispr-flow-bubble",
    match = {
        class = "^wispr-flow$",
        initial_title = "^(Status|Flow Status Indicator)$",
    },
    float = true,
    pin = true,
    move = "monitor_w/2-window_w/2 monitor_h-window_h",
    no_focus = true,
    no_blur = true,
    no_shadow = true,
    border_size = 0,
    rounding = 0,
    no_anim = true,
})
