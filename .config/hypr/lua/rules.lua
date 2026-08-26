local BAR_HEIGHT = 40

local FLOATING_TERMINALS = {
    { class = "activity", width = 0.75, height = 0.90 },
    { class = "files", width = 0.80, height = 0.88 },
}

local function float_centred(class, width, height)
    hl.window_rule({
        match = { class = class },
        float = true,
        size = {
            "(monitor_w*" .. width .. ")",
            "((monitor_h-" .. BAR_HEIGHT .. ")*" .. height .. ")",
        },
        center = true,
    })
end

for _, terminal in ipairs(FLOATING_TERMINALS) do
    float_centred(terminal.class, terminal.width, terminal.height)
end

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
