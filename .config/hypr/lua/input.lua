local TOUCHPAD_SCROLL_FACTOR = 0.6
local ALT_ON_BOTH_SIDES = "lv3:ralt_alt"

local DEVICES = {
    { name = "elan0683:00-04f3:320b-touchpad", sensitivity = 0.5 },
    { name = "apple-inc.-magic-trackpad", sensitivity = 0.88 },
}

local GESTURES = {
    { fingers = 4, direction = "pinch", action = "cursorZoom",
      mode = "live" },
    { fingers = 3, direction = "horizontal", action = "workspace" },
    { fingers = 4, direction = "horizontal", action = "workspace" },
}

hl.config({
    input = {
        kb_layout = "gb",
        kb_options = ALT_ON_BOTH_SIDES,
        focus_on_close = 1,
        touchpad = {
            scroll_factor = TOUCHPAD_SCROLL_FACTOR,
        },
    },
})

for _, device in ipairs(DEVICES) do
    hl.device(device)
end

for _, gesture in ipairs(GESTURES) do
    hl.gesture(gesture)
end
