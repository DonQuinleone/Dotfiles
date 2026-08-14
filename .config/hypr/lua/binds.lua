local ZOOM_STEP = 1.0
local ZOOM_MIN = 1.0
local ZOOM_MAX = 8.0

local function zoom_by(delta)
    return function()
        local z = hl.get_config("cursor.zoom_factor") + delta
        z = math.max(ZOOM_MIN, math.min(ZOOM_MAX, z))
        hl.config({ cursor = { zoom_factor = z } })
    end
end

local function zoom_reset()
    hl.config({ cursor = { zoom_factor = ZOOM_MIN } })
end

-- A detached camera holds still until the pointer reaches the
-- edge of the zoomed view; attached, the view tracks the
-- pointer continuously.
local function zoom_follow_toggle()
    local detached = hl.get_config("cursor.zoom_detached_camera")
    hl.config({ cursor = { zoom_detached_camera = not detached } })
    hl.notification.create({
        text = detached and "Zoom follows cursor"
            or "Zoom camera fixed",
        timeout = 1500,
        font_size = 22,
    })
end

local apps = {
    { key = "Return", cmd = "ghostty" },
    { key = "b", cmd = "firefox" },
}

local directions = {
    { key = "h", dir = "left" },
    { key = "j", dir = "down" },
    { key = "k", dir = "up" },
    { key = "l", dir = "right" },
}

local binds = {
    { "SUPER + SHIFT + e", hl.dsp.exit() },
    { "SUPER + q", hl.dsp.window.close() },
    { "SUPER + SHIFT + f", hl.dsp.window.fullscreen() },
    { "SUPER + SHIFT + space",
      hl.dsp.window.float({ action = "toggle" }) },
    { "SUPER + comma", hl.dsp.focus({ monitor = "-1" }) },
    { "SUPER + period", hl.dsp.focus({ monitor = "+1" }) },
    { "SUPER + SHIFT + comma",
      hl.dsp.window.move({ monitor = "-1" }) },
    { "SUPER + SHIFT + period",
      hl.dsp.window.move({ monitor = "+1" }) },
    { "SUPER + grave",
      hl.dsp.workspace.toggle_special("term") },
    { "SUPER + SHIFT + grave",
      hl.dsp.workspace.toggle_special("mail") },
    { "SUPER + equal", zoom_by(ZOOM_STEP) },
    { "SUPER + minus", zoom_by(-ZOOM_STEP) },
    { "SUPER + 0", zoom_reset },
    { "SUPER + z", zoom_follow_toggle },
    { "SUPER + mouse_up", zoom_by(ZOOM_STEP) },
    { "SUPER + mouse_down", zoom_by(-ZOOM_STEP) },
}

for _, a in ipairs(apps) do
    table.insert(binds,
        { "SUPER + " .. a.key, hl.dsp.exec_cmd(a.cmd) })
end

for _, d in ipairs(directions) do
    table.insert(binds, { "SUPER + " .. d.key,
        hl.dsp.focus({ direction = d.dir }) })
    table.insert(binds, { "SUPER + SHIFT + " .. d.key,
        hl.dsp.window.move({ direction = d.dir }) })
end

for i = 1, 9 do
    table.insert(binds, { "SUPER + " .. i,
        hl.dsp.focus({ workspace = "r~" .. i }) })
    table.insert(binds, { "SUPER + SHIFT + " .. i,
        hl.dsp.window.move({ workspace = "r~" .. i }) })
end

for _, b in ipairs(binds) do
    hl.bind(b[1], b[2])
end
