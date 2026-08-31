local WORKSPACES_PER_MONITOR = 9
local RUN_STRIDE = 10

local MONITORS = {
    {
        description = "Microstep MPG321UX OLED 0x01010101",
        role = "main",
        mode = "3840x2160@60.00",
        position = "0x720",
        scale = 1.5,
        bitdepth = 10,
    },
    {
        description = "LG Electronics BL650 201NTFAP0155",
        role = "upper",
        mode = "1920x1080@60.00",
        position = "2560x0",
        scale = 1,
        bitdepth = 8,
    },
    {
        description = "LG Electronics BL650 201NTJJP0156",
        role = "lower",
        mode = "1920x1080@60.00",
        position = "2560x1080",
        scale = 1,
        bitdepth = 8,
    },
    {
        description = "Chimei Innolux Corporation N160JCA-GT1",
        role = "laptop",
        mode = "1920x1200@60.00",
        position = "0x2160",
        scale = 1,
        bitdepth = 8,
    },
}

hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = 1,
})

for _, monitor in ipairs(MONITORS) do
    hl.monitor({
        output = "desc:" .. monitor.description,
        mode = monitor.mode,
        position = monitor.position,
        scale = monitor.scale,
        transform = 0,
        bitdepth = monitor.bitdepth,
    })
end

local function present(joining, leaving)
    local here = {}
    for _, monitor in ipairs(hl.get_monitors()) do
        here[monitor.description] = true
    end
    if joining then
        here[joining] = true
    end
    if leaving then
        here[leaving] = nil
    end
    return here
end

local function apply(joining, leaving)
    local here = present(joining, leaving)
    for index, monitor in ipairs(MONITORS) do
        local connected = here[monitor.description] == true
        local first = (index - 1) * RUN_STRIDE + 1
        for offset = 0, WORKSPACES_PER_MONITOR - 1 do
            hl.workspace_rule({
                workspace = tostring(first + offset),
                monitor = "desc:" .. monitor.description,
                persistent = connected,
                default = connected and offset == 0,
            })
        end
    end
end

apply()

local monitors = {}

function monitors.workspace_for(slot)
    local focused
    for _, monitor in ipairs(hl.get_monitors()) do
        if monitor.focused then
            focused = monitor.description
        end
    end
    for index, monitor in ipairs(MONITORS) do
        if monitor.description == focused then
            return tostring((index - 1) * RUN_STRIDE + slot)
        end
    end
    return "r~" .. slot
end

local function publish_runs()
    local state = os.getenv("XDG_STATE_HOME")
        or (os.getenv("HOME") .. "/.local/state")
    os.execute("mkdir -p '" .. state .. "/hypr'")
    local file = io.open(state .. "/hypr/runs.tsv", "w")
    if file == nil then
        return
    end
    for index, monitor in ipairs(MONITORS) do
        file:write(monitor.role, "\t",
            monitor.description, "\t",
            tostring((index - 1) * RUN_STRIDE + 1), "\t",
            tostring(WORKSPACES_PER_MONITOR), "\n")
    end
    file:close()
end

publish_runs()

local function described(monitor)
    if type(monitor) == "table" and monitor.description then
        return monitor.description
    end
    return nil
end

hl.on("monitor.added", function(monitor)
    apply(described(monitor), nil)
end)

hl.on("monitor.removed", function(monitor)
    apply(nil, described(monitor))
end)

return monitors
