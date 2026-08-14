hl.config({
    input = {
        kb_layout = "gb",
        repeat_delay = 600,
        repeat_rate = 25,
        follow_mouse = 1,
        touchpad = {
            natural_scroll = false,
            tap_to_click = true,
            disable_while_typing = true,
        },
    },
})

local devices = {
    { name = "elan0683:00-04f3:320b-touchpad", sensitivity = 0.5 },
}

for _, d in ipairs(devices) do
    hl.device(d)
end

-- Touchpads emit smooth scroll axes rather than the discrete
-- wheel clicks SUPER + mouse_up/down needs, so pinch is the
-- magnifier's touchpad entry point.
hl.gesture({
    fingers = 2,
    direction = "pinch",
    action = "cursorZoom",
    mode = "live",
})

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace",
})
