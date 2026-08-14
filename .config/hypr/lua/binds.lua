local ZOOM_STEP = 1.0
local ZOOM_MIN = 1.0
local ZOOM_MAX = 8.0
local RESIZE_STEP = 60
local NOTIFY_MS = 1500
local NOTIFY_FONT = 22

local state_dir = (os.getenv("XDG_STATE_HOME")
    or (os.getenv("HOME") .. "/.local/state")) .. "/hypr"
local caret_flag = state_dir .. "/caret-follow.on"

local function notify(text)
    hl.notification.create({
        text = text,
        timeout = NOTIFY_MS,
        font_size = NOTIFY_FONT,
    })
end

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
    notify(detached and "Zoom follows cursor"
        or "Zoom camera fixed")
end

-- The caret daemon steers the zoom by warping the pointer, so
-- the camera has to be attached for it to have any effect.
local function caret_follow_toggle()
    local flag = io.open(caret_flag, "r")
    if flag then
        flag:close()
        os.remove(caret_flag)
        notify("Caret following off")
        return
    end
    local created = io.open(caret_flag, "w")
    if created then
        created:close()
    end
    hl.config({ cursor = { zoom_detached_camera = false } })
    notify("Caret following on")
end

local apps = {
    { key = "Return", cmd = "ghostty" },
    { key = "b", cmd = "firefox" },
}

local directions = {
    { key = "h", dir = "left", dx = -1, dy = 0 },
    { key = "j", dir = "down", dx = 0, dy = 1 },
    { key = "k", dir = "up", dx = 0, dy = -1 },
    { key = "l", dir = "right", dx = 1, dy = 0 },
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
    { "SUPER + SHIFT + z", caret_follow_toggle },
    { "SUPER + mouse_up", zoom_by(ZOOM_STEP) },
    { "SUPER + mouse_down", zoom_by(-ZOOM_STEP) },
    { "SUPER + mouse:272", hl.dsp.window.drag(),
      { mouse = true } },
    { "SUPER + mouse:273", hl.dsp.window.resize(),
      { mouse = true } },
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
    table.insert(binds, { "SUPER + CTRL + " .. d.key,
        hl.dsp.window.resize({
            x = d.dx * RESIZE_STEP,
            y = d.dy * RESIZE_STEP,
            relative = true,
        }) })
end

for i = 1, 9 do
    table.insert(binds, { "SUPER + " .. i,
        hl.dsp.focus({ workspace = "r~" .. i }) })
    table.insert(binds, { "SUPER + SHIFT + " .. i,
        hl.dsp.window.move({ workspace = "r~" .. i }) })
end

for _, b in ipairs(binds) do
    hl.bind(b[1], b[2], b[3])
end
