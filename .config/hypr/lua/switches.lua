local scripts = "$HOME/.config/hypr/scripts"

local switches = {
    { "switch:on:Lid Switch", scripts .. "/lid close" },
    { "switch:off:Lid Switch", scripts .. "/lid open" },
}

for _, switch in ipairs(switches) do
    hl.bind(switch[1], hl.dsp.exec_cmd(switch[2]),
        { locked = true })
end
