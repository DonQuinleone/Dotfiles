local DEFAULT_ZOOM_STEP = 1.0
local ZOOM_MIN = 1.0
local ZOOM_MAX = 8.0
local NOTIFY_MS = 1500
local EDGE_TOLERANCE = 40

local notify_script = "$HOME/.local/bin/donbox notify"

-- Held in the module rather than captured by each binding, so
-- the shell can change the step through overrides.apply without
-- the compositor reloading its configuration.
local zoom_step = require("settings").load().zoom_step
    or DEFAULT_ZOOM_STEP

local actions = {}

function actions.set_zoom_step(step)
    zoom_step = tonumber(step) or DEFAULT_ZOOM_STEP
end

local function notify(text)
    hl.exec_cmd(string.format(
        "%s --transient -a Hyprland -u low -t %d -- %q",
        notify_script, NOTIFY_MS, text))
end

local function change_zoom(delta)
    local factor = hl.get_config("cursor.zoom_factor") + delta
    factor = math.max(ZOOM_MIN, math.min(ZOOM_MAX, factor))
    hl.config({ cursor = { zoom_factor = factor } })
end

function actions.zoom_in()
    change_zoom(zoom_step)
end

function actions.zoom_out()
    change_zoom(-zoom_step)
end

function actions.zoom_reset()
    hl.config({ cursor = { zoom_factor = ZOOM_MIN } })
end

-- A detached camera holds still until the pointer reaches the
-- edge of the zoomed view; attached, the view tracks the
-- pointer continuously.
function actions.zoom_follow_toggle()
    local detached = hl.get_config("cursor.zoom_detached_camera")
    hl.config({ cursor = { zoom_detached_camera = not detached } })
    notify(detached and "Zoom follows cursor"
        or "Zoom camera fixed")
end

local function overlaps_column(a, b)
    return a.at.x < b.at.x + b.size.x
        and b.at.x < a.at.x + a.size.x
end

local function neighbour_below(window)
    local windows = hl.get_workspace_windows(window.workspace)
    local bottom = window.at.y + window.size.y
    for _, other in ipairs(windows) do
        if not other.floating
            and other.address ~= window.address
            and overlaps_column(window, other)
            and other.at.y + EDGE_TOLERANCE >= bottom then
            return other
        end
    end
    return nil
end

local function nearest_above(window)
    local windows = hl.get_workspace_windows(window.workspace)
    local best, best_gap
    for _, other in ipairs(windows) do
        local gap = window.at.y - (other.at.y + other.size.y)
        if not other.floating
            and other.address ~= window.address
            and overlaps_column(window, other)
            and gap > -EDGE_TOLERANCE
            and (best_gap == nil or gap < best_gap) then
            best, best_gap = other, gap
        end
    end
    return best
end

-- Growing the bottom window of a stack downwards asks Hyprland
-- to move the screen edge, which it ignores, so the height is
-- taken from the window above instead.
function actions.resize(dx, dy)
    return function()
        local window = hl.get_active_window()
        if window == nil then
            return
        end
        local grows_down = dy > 0 and not window.floating
        if grows_down and neighbour_below(window) == nil then
            local above = nearest_above(window)
            if above ~= nil then
                hl.dispatch(hl.dsp.window.resize({
                    x = 0,
                    y = -dy,
                    relative = true,
                    window = "address:" .. above.address,
                }))
                return
            end
        end
        hl.dispatch(hl.dsp.window.resize({
            x = dx,
            y = dy,
            relative = true,
        }))
    end
end

local group_steps = {
    down = hl.dsp.group.next,
    up = hl.dsp.group.prev,
}

-- A grouped window covers its siblings, so nothing lies in the
-- direction asked for and stepping the group is the only way to
-- reach them.
function actions.focus_step(direction)
    local step = group_steps[direction]
    return function()
        local window = hl.get_active_window()
        if step ~= nil and window ~= nil
            and window.group ~= nil then
            hl.dispatch(step())
            return
        end
        hl.dispatch(hl.dsp.focus({ direction = direction }))
    end
end

actions.notify = notify

return actions
