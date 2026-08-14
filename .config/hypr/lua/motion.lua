local state_dir = (os.getenv("XDG_STATE_HOME")
    or (os.getenv("HOME") .. "/.local/state")) .. "/hypr"
local profile_file = state_dir .. "/motion"

local DEFAULT_PROFILE = "full"
local POPIN_STYLE = "popin 87%"
local SPECIAL_STYLE = "slidefadevert 15%"
local INSTANT_SPEED_DS = 0.4
local INSTANT_CURVE = "linear"

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

local profiles = {
    full = { drift = true },
    reduced = { drift = false, speed = INSTANT_SPEED_DS,
        bezier = INSTANT_CURVE },
}

local function leaf_spec(row, profile)
    local spec = {
        leaf = row.leaf,
        enabled = not row.loops or profile.drift,
        speed = profile.speed or row.speed,
        style = row.style,
    }
    if profile.bezier ~= nil then
        spec.bezier = profile.bezier
        return spec
    end
    spec.bezier = row.bezier
    spec.spring = row.spring
    return spec
end

local motion = {}

motion.DEFAULT_PROFILE = DEFAULT_PROFILE

function motion.apply(name)
    local profile = profiles[name] or profiles[DEFAULT_PROFILE]
    for _, curve in ipairs(curves) do
        hl.curve(curve[1], curve[2])
    end
    for _, row in ipairs(animations) do
        hl.animation(leaf_spec(row, profile))
    end
end

function motion.profile()
    local file = io.open(profile_file, "r")
    if file == nil then
        return DEFAULT_PROFILE
    end
    local name = file:read("*l")
    file:close()
    if profiles[name] == nil then
        return DEFAULT_PROFILE
    end
    return name
end

return motion
