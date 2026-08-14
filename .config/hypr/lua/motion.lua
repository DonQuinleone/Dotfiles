local state_dir = (os.getenv("XDG_STATE_HOME")
    or (os.getenv("HOME") .. "/.local/state")) .. "/hypr"
local state_file = state_dir .. "/motion"

local DEFAULT_SCALE = 1.0
local MINIMUM_SPEED_DS = 0.2
local MAXIMUM_SPEED_DS = 100
local POPIN_STYLE = "popin 87%"
local SPECIAL_STYLE = "slidefadevert 15%"
local SCALED_CURVE = "emberOut"

-- Deciseconds for one full turn of the focused window's border
-- gradient, at the slowest Hyprland will accept. Looping an angle
-- costs a redraw every refresh for as long as the session lasts,
-- and only a linear curve keeps the turn even: an eased one
-- surges and stalls once per revolution.
local BORDER_TURN_DS = 100

local curves = {
    { "emberOut", { type = "bezier",
        points = { { 0.16, 1.0 }, { 0.3, 1.0 } } } },
    { "emberQuick", { type = "bezier",
        points = { { 0.15, 0.0 }, { 0.1, 1.0 } } } },
    { "emberSoft", { type = "spring", mass = 1,
        stiffness = 238.1191, dampening = 24.21279333 } },
}

-- Speeds are in deciseconds; zoom at 1.5 is the deliberate
-- break from COSMIC's sluggish magnifier. A spring leaf is timed
-- by its constants alone and ignores its speed, which is why the
-- reduced profile has to swap the curve rather than shorten it.
local animations = {
    { leaf = "global", speed = 2.0, bezier = "emberOut" },
    { leaf = "border", speed = 3.0, bezier = "emberOut" },
    { leaf = "borderangle", speed = BORDER_TURN_DS,
      bezier = "linear", style = "loop", loops = true },
    { leaf = "windows", speed = 2.5, spring = "emberSoft" },
    { leaf = "windowsIn", speed = 2.0, spring = "emberSoft",
      style = POPIN_STYLE },
    { leaf = "windowsOut", speed = 1.5, bezier = "emberQuick",
      style = POPIN_STYLE },
    { leaf = "fade", speed = 1.8, bezier = "emberQuick" },
    { leaf = "layers", speed = 2.0, bezier = "emberOut",
      style = "fade" },
    { leaf = "layersOut", speed = 1.5, bezier = "emberQuick" },
    { leaf = "fadeLayersIn", speed = 2.0, bezier = "emberOut" },
    { leaf = "fadeLayersOut", speed = 1.5, bezier = "emberQuick" },
    { leaf = "workspaces", speed = 2.0, bezier = "emberOut",
      style = "slide" },
    { leaf = "specialWorkspace", speed = 1.8, bezier = "emberOut",
      style = SPECIAL_STYLE },
    { leaf = "zoomFactor", speed = 1.5, bezier = "emberQuick" },
}

-- The drift is ambient rather than responsive, so the scale
-- leaves its period alone and the switch alone governs it.
local function speed_for(row, scale)
    if row.loops then
        return row.speed
    end
    return math.max(MINIMUM_SPEED_DS,
        math.min(MAXIMUM_SPEED_DS, row.speed * scale))
end

-- A spring ignores speed, so a scaled scheme has to trade it for
-- a bezier or window motion would be the one thing that never
-- answered the slider.
local function curve_for(row, scale)
    if row.spring == nil then
        return { bezier = row.bezier }
    end
    if scale == DEFAULT_SCALE then
        return { spring = row.spring }
    end
    return { bezier = SCALED_CURVE }
end

local function leaf_spec(row, scale, drift)
    local curve = curve_for(row, scale)
    return {
        leaf = row.leaf,
        enabled = not row.loops or drift,
        speed = speed_for(row, scale),
        style = row.style,
        bezier = curve.bezier,
        spring = curve.spring,
    }
end

local function stored_values()
    local file = io.open(state_file, "r")
    if file == nil then
        return {}
    end
    local values = {}
    for line in file:lines() do
        local key, value = line:match("^(%a+)=(%S+)$")
        if key ~= nil then
            values[key] = value
        end
    end
    file:close()
    return values
end

-- Hyprland only starts a looping angle when a window is mapped,
-- so re-enabling the leaf leaves every open window frozen until
-- something touches focus. Focusing the active window again is
-- the cheapest thing that does.
local function restart_drift()
    local window = hl.get_active_window()
    if window == nil then
        return
    end
    hl.dispatch(hl.dsp.focus({
        window = "address:" .. window.address,
    }))
end

local motion = {}

function motion.apply(scale, drift)
    for _, curve in ipairs(curves) do
        hl.curve(curve[1], curve[2])
    end
    for _, row in ipairs(animations) do
        hl.animation(leaf_spec(row, scale, drift))
    end
    if drift then
        restart_drift()
    end
end

function motion.stored()
    local values = stored_values()
    return tonumber(values.scale) or DEFAULT_SCALE,
        values.drift ~= "off"
end

return motion
