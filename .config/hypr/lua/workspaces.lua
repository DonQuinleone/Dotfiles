local WORKSPACE_COUNT = 9
local FIRST_WORKSPACE = 1

-- 1-9 live on the laptop panel until the dock's monitor
-- descriptions are captured; 11-19/21-29 join then.
for index = FIRST_WORKSPACE, WORKSPACE_COUNT do
    hl.workspace_rule({
        workspace = tostring(index),
        monitor = "eDP-1",
        persistent = true,
        default = (index == FIRST_WORKSPACE),
    })
end

-- Set command to run a graphical client instead of a terminal
-- one, alongside the class it reports, e.g. thunderbird.
local scratchpads = {
    {
        workspace = "special:term",
        class     = "com.donquinleone.scratchterm",
        width     = 0.80,
        height    = 0.82,
    },
    {
        workspace = "special:mail",
        class     = "thunderbird",
        command   = "thunderbird",
        width     = 0.96,
        height    = 0.94,
    },
}

-- Ghostty only honours --class when it is a valid GTK
-- application id and it is not folding into a running
-- instance, and -e swallows every argument after it.
local function launcher(pad)
    if pad.command then
        return pad.command
    end
    local command = "ghostty --gtk-single-instance=false --class="
        .. pad.class
    if pad.exec then
        command = command .. " -e " .. pad.exec
    end
    return command
end

for _, pad in ipairs(scratchpads) do
    hl.workspace_rule({
        workspace = pad.workspace,
        on_created_empty = launcher(pad),
    })
end

return scratchpads
