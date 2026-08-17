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
