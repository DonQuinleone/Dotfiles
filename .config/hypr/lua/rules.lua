local scratchpads = require("workspaces")

-- Centring measures the whole monitor rather than the area
-- the panel leaves free, so a tall scratchpad would slide
-- underneath it. Sizing against the free height keeps the
-- window clear of the panel while staying centred.
local PANEL_HEIGHT = 48

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
