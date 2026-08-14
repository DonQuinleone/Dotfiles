local scratchpads = require("workspaces")

for _, pad in ipairs(scratchpads) do
    hl.window_rule({
        match = { class = pad.class },
        float = true,
        size = { "(monitor_w*0.62)", "(monitor_h*0.65)" },
        center = true,
    })
end

hl.window_rule({
    match = { title = "Picture-in-Picture" },
    float = true,
    pin = true,
})
