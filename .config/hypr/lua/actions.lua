local ZOOM_STEP = 1.0
local ZOOM_MIN = 1.0
local ZOOM_MAX = 8.0
local NOTIFY_MS = 1500
local EDGE_TOLERANCE = 40

local state_dir = (os.getenv("XDG_STATE_HOME")
    or (os.getenv("HOME") .. "/.local/state")) .. "/hypr"
local caret_flag = state_dir .. "/caret-follow.on"
local notify_script = "$HOME/.config/hypr/scripts/notify"

local actions = {}

-- The desktop's own confirmations are worth a toast but not a
-- place in the history the user reviews later.
local function notify(text)
    hl.exec_cmd(string.format(
        "%s --transient -a Hyprland -u low -t %d -- %q",
        notify_script, NOTIFY_MS, text))
end

function actions.zoom(delta)
    return function()
        local factor = hl.get_config("cursor.zoom_factor") + delta
        factor = math.max(ZOOM_MIN, math.min(ZOOM_MAX, factor))
        hl.config({ cursor = { zoom_factor = factor } })
    end
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

-- The caret daemon steers the zoom by warping the pointer, so
-- the camera has to be attached for it to have any effect.
function actions.caret_follow_toggle()
    local flag = io.open(caret_flag, "r")
    if flag then
        flag:close()
        os.remove(caret_flag)
        notify("Caret following off")
        return
    end
    local created = io.open(caret_flag, "w")
    if created then
        created:close()
    end
    hl.config({ cursor = { zoom_detached_camera = false } })
    notify("Caret following on")
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

actions.ZOOM_STEP = ZOOM_STEP
actions.notify = notify

return actions
