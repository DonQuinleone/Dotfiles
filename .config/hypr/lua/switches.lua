local scripts = "$HOME/.config/hypr/scripts"

local switches = {
    { "switch:on:Lid Switch", scripts .. "/lid close" },
    { "switch:off:Lid Switch", scripts .. "/lid open" },
}

for _, switch in ipairs(switches) do
    hl.bind(switch[1], hl.dsp.exec_cmd(switch[2]),
        { locked = true })
end

-- Plugging a monitor in or out is what decides between the
-- docked and travelling idle profiles.
local monitor_events = { "monitor.added", "monitor.removed" }

for _, event in ipairs(monitor_events) do
    hl.on(event, function()
        hl.exec_cmd(scripts .. "/idle-profile")
    end)
end
