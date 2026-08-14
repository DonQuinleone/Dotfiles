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
            scroll_factor = 0.6,
        },
    },
})

local devices = {
    { name = "elan0683:00-04f3:320b-touchpad", sensitivity = 0.5 },
    { name = "apple-inc.-magic-trackpad", sensitivity = 0.88 },
}

for _, device in ipairs(devices) do
    hl.device(device)
end

-- Two-finger pinch belongs to the browser and everything else
-- that zooms its own content, so the magnifier takes four
-- fingers, and workspace swipes answer to either hand shape.
local gestures = {
    { fingers = 4, direction = "pinch", action = "cursorZoom",
      mode = "live" },
    { fingers = 3, direction = "horizontal",
      action = "workspace" },
    { fingers = 4, direction = "horizontal",
      action = "workspace" },
}

for _, gesture in ipairs(gestures) do
    hl.gesture(gesture)
end
