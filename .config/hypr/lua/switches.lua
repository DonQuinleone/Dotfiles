local scripts = "$HOME/.config/hypr/scripts"

local switches = {
    { "switch:on:Lid Switch", scripts .. "/lid close" },
    { "switch:off:Lid Switch", scripts .. "/lid open" },
}

for _, switch in ipairs(switches) do
    hl.bind(switch[1], hl.dsp.exec_cmd(switch[2]),
        { locked = true })
end

-- Plugging a monitor in or out decides between the docked and
-- travelling idle profiles, which saved layout to apply, where
-- stray workspaces need to move, and whether the lid switch is
-- still allowed to suspend the machine.
local idle_profile = scripts .. "/idle-profile"
local monitor_profile = scripts .. "/monitor-profile"
local lid = scripts .. "/lid"

local monitor_hooks = {
    { "monitor.added",   idle_profile },
    { "monitor.added",   monitor_profile .. " detect" },
    { "monitor.added",   lid .. " sync" },
    { "monitor.removed", idle_profile },
    { "monitor.removed", monitor_profile .. " reflow" },
    { "monitor.removed", lid .. " sync" },
}

for _, hook in ipairs(monitor_hooks) do
    hl.on(hook[1], function()
        hl.exec_cmd(hook[2])
    end)
end
