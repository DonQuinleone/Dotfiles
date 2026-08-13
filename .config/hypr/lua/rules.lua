local scratch_classes = { "scratch-term", "scratch-mail" }

for _, class in ipairs(scratch_classes) do
    hl.window_rule({
        match = { class = class },
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
