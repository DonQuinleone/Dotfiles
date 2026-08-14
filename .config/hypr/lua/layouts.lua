local actions = require("actions")

local FLOAT_RULE_PREFIX = "float-workspace-"

local modes = {
    { name = "master", tiled = "master",
      label = "Master stack" },
    { name = "monocle", tiled = "monocle",
      label = "Monocle, one window" },
    { name = "scrolling", tiled = "scrolling",
      label = "Scrolling columns" },
    { name = "floating", tiled = "master", floats = true,
      label = "Floating windows" },
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

local function apply(workspace, mode)
    hl.workspace_rule({
        workspace = workspace,
        layout = mode.tiled,
    })
    float_windows(workspace, mode.floats == true)
    chosen[workspace] = mode.name
    actions.notify("Layout: " .. mode.label)
end

local layouts = {}

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

-- A workspace never switched by hand reports only its tiled
-- layout, which is the mode it is in until floating is chosen.
function layouts.cycle()
    local workspace = hl.get_active_workspace()
    if workspace == nil then
        return
    end
    local name = chosen[workspace.name] or workspace.tiled_layout
    apply(workspace.name,
        modes[(index_of[name] or 0) % #modes + 1])
end

return layouts
