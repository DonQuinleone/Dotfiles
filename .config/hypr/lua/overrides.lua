local actions = require("actions")

local overrides = {}

function overrides.apply(saved)
    if saved.border_size then
        hl.config({ general = { border_size = saved.border_size } })
    end
    if saved.zoom_detached_camera ~= nil then
        hl.config({
            cursor = { zoom_detached_camera = saved.zoom_detached_camera },
        })
    end
    actions.set_zoom_step(saved.zoom_step)

    for _, device in ipairs(saved.devices or {}) do
        if device.name then
            hl.device(device)
        end
    end
end

return overrides
