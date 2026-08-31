local GAP_INNER = 6
local GAP_OUTER = 12
local BORDER_WIDTH = 4
local CORNER_RADIUS = 10
local BLUR_RADIUS = 8
local BLUR_PASSES = 2
local MASTER_AREA_FRACTION = 0.5
local SCROLLING_COLUMN_FRACTION = 0.5
local SCROLLING_FOLLOW_MIN_VISIBLE = 0.0
local GROUPBAR_HEIGHT = 34
local GROUPBAR_TEXT_PADDING = 12
local GROUPBAR_ROUNDING = 8
local GROUPBAR_TAB_GAP = 2
local GROUPBAR_WINDOW_GAP = 6
local GROUPBAR_INDICATOR_HEIGHT = 0
local ZOOM_UNMAGNIFIED = 1.0

hl.config({
    general = {
        gaps_in = GAP_INNER,
        gaps_out = GAP_OUTER,
        border_size = BORDER_WIDTH,
        layout = "master",
    },
    decoration = {
        rounding = CORNER_RADIUS,
        blur = {
            enabled = true,
            size = BLUR_RADIUS,
            passes = BLUR_PASSES,
        },
    },
    master = {
        new_status = "slave",
        new_on_top = false,
        mfact = MASTER_AREA_FRACTION,
    },
    scrolling = {
        direction = "right",
        fullscreen_on_one_column = true,
        column_width = SCROLLING_COLUMN_FRACTION,
        follow_min_visible = SCROLLING_FOLLOW_MIN_VISIBLE,
    },
    group = {
        groupbar = {
            stacked = true,
            gradients = true,
            height = GROUPBAR_HEIGHT,
            text_padding = GROUPBAR_TEXT_PADDING,
            rounding = GROUPBAR_ROUNDING,
            gaps_in = GROUPBAR_TAB_GAP,
            gaps_out = GROUPBAR_WINDOW_GAP,
            indicator_height = GROUPBAR_INDICATOR_HEIGHT,
        },
    },
    cursor = {
        -- Hyprland holds the software-cursor lock for zoom in one
        -- process-wide flag while the zoom itself is per monitor,
        -- so another screen drops the lock mid-frame and the
        -- hardware plane, which no zoom transform reaches, comes
        -- back unmagnified.
        no_hardware_cursors = true,
        zoom_factor = ZOOM_UNMAGNIFIED,
        zoom_rigid = false,
        zoom_detached_camera = false,
        no_warps = false,
        warp_on_change_workspace = 1,
    },
    xwayland = {
        force_zero_scaling = true,
    },
    misc = {
        disable_hyprland_logo = true,
        force_default_wallpaper = 0,
        allow_session_lock_restore = true,
        focus_on_activate = true,
        on_focus_under_fullscreen = 1,
        key_press_enables_dpms = true,
        mouse_move_enables_dpms = true,
    },
    binds = {
        disable_keybind_grabbing = true,
    },
    animations = {
        enabled = true,
    },
})

local state = os.getenv("XDG_STATE_HOME")
    or (os.getenv("HOME") .. "/.local/state")

local rendered = io.open(state .. "/theme/hyprland.lua")
if rendered ~= nil then
    local chunk = (loadstring or load)(rendered:read("*a"))
    rendered:close()
    if chunk ~= nil then
        pcall(chunk)
    end
end
