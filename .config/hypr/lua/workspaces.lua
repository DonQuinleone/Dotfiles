local WORKSPACES_PER_RUN = 9

-- Screens take a run of nine in the order below, so whichever
-- of them is connected owns the lowest numbers: undocked, that
-- is the laptop. Every bar labels its own run 1..9 whatever the
-- ids behind it, and the r~1..r~9 binds count up from 1 past
-- whatever another connected screen has claimed, so a run that
-- started higher, or left a gap, would send them to a workspace
-- no screen owns.
local priority = { "DP-5", "DP-6", "eDP-1" }

local function rank(output)
    for index, name in ipairs(priority) do
        if name == output then
            return index
        end
    end
    return #priority + 1
end

-- monitor.added and monitor.removed fire either side of the
-- list they describe, so the screen in hand is folded in or out
-- here rather than trusted to be counted already.
local function connected(joining, leaving)
    local present = {}
    for _, monitor in ipairs(hl.get_monitors()) do
        present[monitor.name] = true
    end
    if joining then
        present[joining] = true
    end
    if leaving then
        present[leaving] = nil
    end

    local outputs = {}
    for name in pairs(present) do
        table.insert(outputs, name)
    end
    table.sort(outputs, function(left, right)
        if rank(left) ~= rank(right) then
            return rank(left) < rank(right)
        end
        return left < right
    end)
    return outputs
end

-- Runs past the connected screens are emitted too, disabled, so
-- that undocking takes the run it retires with it instead of
-- leaving nine empty workspaces on the one screen left.
local function apply(joining, leaving)
    local outputs = connected(joining, leaving)
    for run = 1, math.max(#priority, #outputs) do
        local output = outputs[run]
        local first = (run - 1) * WORKSPACES_PER_RUN + 1
        for offset = 0, WORKSPACES_PER_RUN - 1 do
            hl.workspace_rule({
                workspace = tostring(first + offset),
                monitor = output or "",
                persistent = output ~= nil,
                default = output ~= nil and offset == 0,
            })
        end
    end
end

apply()

hl.on("monitor.added", function(monitor)
    apply(monitor.name, nil)
end)

hl.on("monitor.removed", function(monitor)
    apply(nil, monitor.name)
end)
