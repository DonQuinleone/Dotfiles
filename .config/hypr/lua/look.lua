local motion = require("motion")

local GAP_INNER = 6
local GAP_OUTER = 12
local BORDER_WIDTH = 4
local CORNER_RADIUS = 10
local BLUR_RADIUS = 8
local BLUR_PASSES = 2

local MASTER_AREA_FRACTION = 0.5
local SCROLLING_COLUMN_FRACTION = 0.5

-- Hyprland will not scroll a column into view for the pointer
-- until four tenths of it are already showing, which leaves the
-- sliver at the edge of the tape, the one actually worth
-- reaching for, stuck there. Asking for none of it makes the
-- pointer bring a column in exactly as the keys do.
local SCROLLING_FOLLOW_MIN_VISIBLE = 0.0

local GROUPBAR_HEIGHT = 34
local GROUPBAR_TEXT_PADDING = 12
local GROUPBAR_ROUNDING = 8
local GROUPBAR_TAB_GAP = 2
local GROUPBAR_WINDOW_GAP = 6
local GROUPBAR_INDICATOR_HEIGHT = 0

local ZOOM_UNMAGNIFIED = 1.0

local state = os.getenv("XDG_STATE_HOME")
    or (os.getenv("HOME") .. "/.local/state")

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
    -- Focus sent to another monitor must carry the pointer
    -- with it, or follow_mouse snaps it straight back.
    cursor = {
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
    },
    -- A passphrase prompt grabs the keyboard, which otherwise
    -- takes the magnifier away at exactly the moment there is
    -- something small to read. The locker holds the session
    -- lock rather than a grab, so it is unaffected.
    binds = {
        disable_keybind_grabbing = true,
        hide_special_on_workspace_change = true,
    },
    animations = {
        enabled = true,
    },
})

motion.apply(motion.stored())

-- Palette-driven colours are written by the theme script and
-- are absent until it has run once, so Hyprland's own defaults
-- stand in on a machine that has never applied a theme.
pcall(dofile, state .. "/donbox/current/hyprland.lua")
