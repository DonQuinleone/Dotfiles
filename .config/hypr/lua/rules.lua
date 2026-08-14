local scratchpads = require("workspaces")

for _, pad in ipairs(scratchpads) do
    hl.window_rule({
        match = { class = pad.class },
        float = true,
        size = {
            "(monitor_w*" .. pad.width .. ")",
            "(monitor_h*" .. pad.height .. ")",
        },
        center = true,
    })
end

hl.window_rule({
    match = { title = "Picture-in-Picture" },
    float = true,
    pin = true,
})
