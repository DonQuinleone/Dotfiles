local WORKSPACES_PER_RUN = 9

-- The r~1..r~9 binds resolve against the focused monitor's own
-- run, so every screen needs a full set and the numbers only
-- have to be distinct. Hyprland leaves a run uncreated while
-- its connector is absent, which is what keeps an undocked
-- laptop down to one set rather than all three.
local runs = {
    { monitor = "DP-5",  first = 1 },
    { monitor = "DP-6",  first = 11 },
    { monitor = "eDP-1", first = 21 },
}

for _, run in ipairs(runs) do
    for offset = 0, WORKSPACES_PER_RUN - 1 do
        hl.workspace_rule({
            workspace = tostring(run.first + offset),
            monitor = run.monitor,
            persistent = true,
            default = offset == 0,
        })
    end
end
