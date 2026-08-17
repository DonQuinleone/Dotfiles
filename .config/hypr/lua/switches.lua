local donbox = "$HOME/.local/bin/donbox"

local switches = {
    { "switch:on:Lid Switch", donbox .. " lid close" },
    { "switch:off:Lid Switch", donbox .. " lid open" },
}

for _, switch in ipairs(switches) do
    hl.bind(switch[1], hl.dsp.exec_cmd(switch[2]),
        { locked = true })
end

local idle_profile = donbox .. " idle profile"
local monitor_profile = donbox .. " monitor profile"
local lid = donbox .. " lid"

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
