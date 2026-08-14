local scratchpads = require("workspaces")

-- Centring measures the whole monitor rather than the area
-- the panel leaves free, so a tall scratchpad would slide
-- underneath it. Sizing against the free height keeps the
-- window clear of the panel while staying centred.
local PANEL_HEIGHT = 48
local SETTINGS_WIDTH_FRACTION = 0.55
local SETTINGS_HEIGHT_FRACTION = 0.85

for _, pad in ipairs(scratchpads) do
    hl.window_rule({
        match = { class = pad.class },
        float = true,
        size = {
            "(monitor_w*" .. pad.width .. ")",
            "((monitor_h-" .. PANEL_HEIGHT .. ")*"
                .. pad.height .. ")",
        },
        center = true,
    })
end

hl.window_rule({
    match = { title = "Picture-in-Picture" },
    float = true,
    pin = true,
})

hl.window_rule({
    match = { class = "org.quickshell", title = "Ember settings" },
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
    { namespace = "^ember-bar$", animation = "slide top" },
    { namespace = "^ember-toasts$", animation = "slide right" },
    { namespace = "^ember-notifications$",
      animation = "slide right" },
    { namespace = "^ember-quick-settings$",
      animation = "slide right" },
    { namespace = "^ember-osd$", animation = "slide bottom" },
    { namespace = "^ember-chooser$", animation = "popin 92%" },
    { namespace = "^ember-screensaver$", animation = "fade" },
    { namespace = "^ember-wallpaper$", no_anim = true },
    { namespace = "^ember-flash$", no_anim = true },
}

for _, layer in ipairs(layers) do
    hl.layer_rule({
        match = { namespace = layer.namespace },
        animation = layer.animation,
        no_anim = layer.no_anim,
    })
end
