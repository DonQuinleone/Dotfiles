local actions = require("actions")

-- config.reloaded also fires for the very first load during
-- startup, before any output exists; announcing that one would
-- toast every login.
hl.on("config.reloaded", function()
    if #hl.get_monitors() == 0 then
        return
    end
    actions.notify("Hyprland configuration reloaded")
end)
