local scratchpads = require("workspaces")

-- Centring measures the whole monitor rather than the area the
-- panel leaves free, so a tall window would slide underneath
-- it. Sizing against the free height keeps the window clear of
-- the panel while staying centred.
local PANEL_HEIGHT = 48
local SETTINGS_WIDTH_FRACTION = 0.55
local SETTINGS_HEIGHT_FRACTION = 0.85

local function float_centred(class, width, height)
    hl.window_rule({
        match = { class = class },
        float = true,
        size = {
            "(monitor_w*" .. width .. ")",
            "((monitor_h-" .. PANEL_HEIGHT .. ")*" .. height .. ")",
        },
        center = true,
    })
end

-- The terminal keeps the session's reading font size, so the
-- editor needs nearly the whole screen to hold the ninety-odd
-- columns a 72-column configuration file wants.
local terminals = {
    { class = "com.donquinleone.activity", width = 0.75,
      height = 0.90 },
    { class = "com.donquinleone.settings", width = 0.92,
      height = 0.92 },
}

for _, pad in ipairs(scratchpads) do
    float_centred(pad.class, pad.width, pad.height)
end

for _, terminal in ipairs(terminals) do
    float_centred(terminal.class, terminal.width, terminal.height)
end

hl.window_rule({
    match = { title = "Picture-in-Picture" },
    float = true,
    pin = true,
})

hl.window_rule({
    match = { class = "org.quickshell", title = "Donbox settings" },
    float = true,
    size = {
        "(monitor_w*" .. SETTINGS_WIDTH_FRACTION .. ")",
        "((monitor_h-" .. PANEL_HEIGHT .. ")*"
            .. SETTINGS_HEIGHT_FRACTION .. ")",
    },
    center = true,
})

-- Each surface enters from the edge it lives on, so the motion
-- says where the thing came from; the centred ones have no edge
-- to come from and grow in place instead. The wallpaper never
-- travels, and the screenshot flash is left to the shell, whose
-- own ramp is gentler than anything the compositor would add.
local layers = {
    { namespace = "^donbox-bar$", animation = "slide top" },
    { namespace = "^donbox-toasts$", animation = "slide right" },
    { namespace = "^donbox-notifications$",
      animation = "slide right" },
    { namespace = "^donbox-osd$", animation = "slide bottom" },
    { namespace = "^donbox-chooser$", animation = "popin 92%" },
    { namespace = "^donbox-screensaver$", animation = "fade" },
    { namespace = "^donbox-wallpaper$", no_anim = true },
    { namespace = "^donbox-flash$", no_anim = true },
}

for _, layer in ipairs(layers) do
    hl.layer_rule({
        match = { namespace = layer.namespace },
        animation = layer.animation,
        no_anim = layer.no_anim,
    })
end
