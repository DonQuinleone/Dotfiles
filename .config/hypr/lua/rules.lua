local scratchpads = require("scratchpads")

-- Centring measures the whole monitor rather than the area the
-- panel leaves free, so a tall window would slide underneath
-- it. Sizing against the free height keeps the window clear of
-- the panel while staying centred.
local PANEL_HEIGHT = 48
local PANE_GAP = 6

-- Hyprland sizes and places a window from expressions over the
-- monitor it lands on, so a measure is a fraction of one of its
-- dimensions plus the pixels the gaps and the panel take out of
-- it.
local function measure(axis, fraction, pixels)
    return string.format("(monitor_%s*%.6f%+.1f)",
        axis, fraction, pixels)
end

local function float_centred(class, width, height)
    hl.window_rule({
        match = { class = class },
        float = true,
        size = {
            measure("w", width, 0),
            measure("h", height, -PANEL_HEIGHT * height),
        },
        center = true,
    })
end

-- Panes are placed rather than centred: each one starts where
-- the shares before it end, and every gap between them pushes
-- the rest along.
local function place_pane(pad, index, before)
    local pane = pad.panes[index]
    local gaps = (#pad.panes - 1) * PANE_GAP
    hl.window_rule({
        match = { class = pane.class },
        workspace = scratchpads.workspace_of(pad) .. " silent",
        float = true,
        size = {
            measure("w", pad.width * pane.share,
                -gaps * pane.share),
            measure("h", pad.height,
                -PANEL_HEIGHT * pad.height),
        },
        move = {
            measure("w",
                (1 - pad.width) / 2 + pad.width * before,
                (index - 1) * PANE_GAP - gaps * before),
            measure("h", (1 - pad.height) / 2,
                PANEL_HEIGHT * pad.height / 2),
        },
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
    { class = "com.donquinleone.update", width = 0.75,
      height = 0.90 },
    { class = "com.donquinleone.packages", width = 0.80,
      height = 0.88 },
}

for _, pad in ipairs(scratchpads.pads) do
    local before = 0
    for index, pane in ipairs(pad.panes) do
        place_pane(pad, index, before)
        before = before + pane.share
    end
end

for _, terminal in ipairs(terminals) do
    float_centred(terminal.class, terminal.width, terminal.height)
end

hl.window_rule({
    match = { title = "Picture-in-Picture" },
    float = true,
    pin = true,
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
