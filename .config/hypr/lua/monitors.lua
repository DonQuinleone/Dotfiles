-- Dock monitor descriptions are captured on first dock via
-- hyprctl monitors all; until then externals take the
-- catch-all rule.
local monitors = {
    { output = "eDP-1", mode = "1920x1200@60", position = "auto",
      scale = 1.0 },
    { output = "", mode = "preferred", position = "auto",
      scale = 1.0 },
}

for _, m in ipairs(monitors) do
    hl.monitor(m)
end
