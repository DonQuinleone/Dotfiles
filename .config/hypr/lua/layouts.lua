local actions = require("actions")

local FLOAT_RULE_PREFIX = "float-workspace-"

local modes = {
    { name = "master", tiled = "master",
      label = "Master stack" },
    { name = "monocle", tiled = "monocle", stacked = true,
      label = "Monocle, one window" },
    { name = "scrolling", tiled = "scrolling",
      label = "Scrolling columns" },
}

local index_of = {}
for index, mode in ipairs(modes) do
    index_of[mode.name] = index
end

local chosen = {}
local float_rules = {}

local function float_rule(workspace)
    if not float_rules[workspace] then
        float_rules[workspace] = hl.window_rule({
            name = FLOAT_RULE_PREFIX .. workspace,
            match = { workspace = workspace },
            float = true,
            enabled = false,
        })
    end
    return float_rules[workspace]
end

local function float_windows(workspace, floating)
    float_rule(workspace):set_enabled(floating)
    local action = floating and "enable" or "disable"
    for _, window in ipairs(hl.get_workspace_windows(workspace)) do
        hl.dispatch(hl.dsp.window.float({
            action = action,
            window = window,
        }))
    end
end

local function selector(window)
    return "address:" .. window.address
end

local function tiled_windows(workspace)
    local tiled = {}
    for _, window in ipairs(hl.get_workspace_windows(workspace)) do
        if not window.floating then
            table.insert(tiled, window)
        end
    end
    return tiled
end

local function gather(workspace)
    local windows = tiled_windows(workspace)
    local anchor = windows[1]
    if anchor == nil then
        return
    end
    if anchor.group == nil then
        hl.dispatch(hl.dsp.group.toggle({
            window = selector(anchor),
        }))
        anchor = hl.get_window(selector(anchor))
    end
    if anchor == nil or anchor.group == nil then
        return
    end
    for index = 2, #windows do
        if windows[index].group == nil then
            anchor.group:add(windows[index])
        end
    end
end

local function scatter(workspace)
    for _, window in ipairs(hl.get_workspace_windows(workspace)) do
        local current = hl.get_window(selector(window))
        if current ~= nil and current.group ~= nil then
            hl.dispatch(hl.dsp.group.toggle({
                window = selector(current),
            }))
        end
    end
end

local function stack_windows(workspace, stacked)
    if stacked then
        gather(workspace)
        return
    end
    scatter(workspace)
end

local function apply(workspace, mode)
    hl.workspace_rule({
        workspace = workspace,
        layout = mode.tiled,
    })
    float_windows(workspace, mode.floats == true)
    stack_windows(workspace, mode.stacked == true)
    chosen[workspace] = mode.name
    actions.notify("Layout: " .. mode.label)
end

local function chosen_layout(workspace)
    return chosen[workspace.name] or workspace.tiled_layout
end

local function stacks(workspace)
    local mode = modes[index_of[chosen_layout(workspace)] or 0]
    return mode ~= nil and mode.stacked == true
end

local layouts = {}

function layouts.send_to_workspace(workspace)
    return function()
        local window = hl.get_active_window()
        if window ~= nil and window.group ~= nil then
            window.group:remove(window)
        end
        hl.dispatch(hl.dsp.window.move({ workspace = workspace }))
        local landed = hl.get_active_workspace()
        if landed == nil then
            return
        end
        stack_windows(landed.name, stacks(landed))
    end
end

function layouts.set(name)
    local mode = modes[index_of[name]]
    return function()
        local workspace = hl.get_active_workspace()
        if workspace == nil then
            return
        end
        apply(workspace.name, mode)
    end
end

function layouts.cycle()
    local workspace = hl.get_active_workspace()
    if workspace == nil then
        return
    end
    local name = chosen_layout(workspace)
    apply(workspace.name,
        modes[(index_of[name] or 0) % #modes + 1])
end

return layouts
