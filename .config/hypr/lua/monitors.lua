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

local scripts = "$HOME/.config/hypr/scripts"

local function apply_saved_profile()
    hl.exec_cmd(scripts .. "/monitor-profile detect")
end

-- Runs after the fallback above on both a cold start and a
-- config reload, and overwrites it with a saved profile's exact
-- geometry when the connected outputs match one; matching
-- nothing leaves the fallback in place.
for _, event in ipairs({ "hyprland.start", "config.reloaded" })
do
    hl.on(event, apply_saved_profile)
end
