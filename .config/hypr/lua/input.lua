local REPEAT_DELAY_MS = 600
local REPEAT_RATE_HZ = 25
local FOLLOW_MOUSE_ALWAYS = 1
local TOUCHPAD_SCROLL_FACTOR = 0.6

hl.config({
    input = {
        kb_layout = "gb",
        repeat_delay = REPEAT_DELAY_MS,
        repeat_rate = REPEAT_RATE_HZ,
        follow_mouse = FOLLOW_MOUSE_ALWAYS,
        touchpad = {
            natural_scroll = false,
            tap_to_click = true,
            disable_while_typing = true,
            scroll_factor = TOUCHPAD_SCROLL_FACTOR,
        },
    },
})

-- Sensitivity runs from -1.0 at the slowest to 1.0 at the
-- fastest.
local devices = {
    { name = "elan0683:00-04f3:320b-touchpad", sensitivity = 0.5  },
    { name = "apple-inc.-magic-trackpad",      sensitivity = 0.88 },
}

for _, device in ipairs(devices) do
    hl.device(device)
end

-- Two-finger pinch belongs to the browser and everything else
-- that zooms its own content, so the magnifier takes four
-- fingers, and workspace swipes answer to either hand shape.
local gestures = {
    { fingers = 4, direction = "pinch",      action = "cursorZoom",
      mode = "live" },
    { fingers = 3, direction = "horizontal", action = "workspace" },
    { fingers = 4, direction = "horizontal", action = "workspace" },
}

for _, gesture in ipairs(gestures) do
    hl.gesture(gesture)
end
