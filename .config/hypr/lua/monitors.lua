-- Fallback for outputs no saved profile covers: the built-in
-- panel keeps its known-good settings, and anything else is
-- guessed at until "monitor-profile save" teaches us its
-- description, resolution, scale and position.
local fallback = {
    { output = "eDP-1", mode = "1920x1200@60",
      position = "auto", scale = 1.0 },
    { output = "",      mode = "preferred",
      position = "auto", scale = 1.0 },
}

for _, monitor in ipairs(fallback) do
    hl.monitor(monitor)
end

local state = os.getenv("XDG_STATE_HOME")
    or (os.getenv("HOME") .. "/.local/state")

-- "monitor profile" records the rules it last applied. Re-emitting
-- them here means a reload hands the compositor rules identical to
-- the active ones, which it then skips: no modeset, no flash, and
-- no held key left repeating into a frozen session. Without this
-- the fallback above would clobber the live layout on every save
-- of any config file, and the profile would modeset it back.
pcall(dofile, state .. "/hypr/monitor-rules.lua")

local donbox = "$HOME/.local/bin/donbox"

local function apply_saved_profile()
    hl.exec_cmd(donbox .. " monitor profile detect")
end

-- Runs after the fallback above on both a cold start and a
-- config reload, and overwrites it with a saved profile's exact
-- geometry when the connected outputs match one; matching
-- nothing leaves the fallback in place.
for _, event in ipairs({ "hyprland.start", "config.reloaded" })
do
    hl.on(event, apply_saved_profile)
end
