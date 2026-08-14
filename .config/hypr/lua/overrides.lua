local overrides = {}

function overrides.apply(saved)
    hl.config({
        general = { border_size = saved.border_size },
        cursor = {
            zoom_detached_camera = saved.zoom_detached_camera,
        },
    })

    for _, device in ipairs(saved.devices or {}) do
        if device.name then
            hl.device(device)
        end
    end
end

return overrides
