local motion = require("motion")

local GAP_INNER = 6
local GAP_OUTER = 12
local BORDER_WIDTH = 4
local CORNER_RADIUS = 10
local BLUR_RADIUS = 8
local BLUR_PASSES = 2

local SHADOW_RANGE = 26
local SHADOW_DROP = 10
local SHADOW_RENDER_POWER = 3

local MASTER_AREA_FRACTION = 0.6
local SCROLLING_COLUMN_FRACTION = 0.5

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
        shadow = {
            enabled = true,
            range = SHADOW_RANGE,
            render_power = SHADOW_RENDER_POWER,
            offset = { 0, SHADOW_DROP },
        },
    },
    master = {
        new_status = "master",
        new_on_top = true,
        mfact = MASTER_AREA_FRACTION,
    },
    scrolling = {
        fullscreen_on_one_column = true,
        column_width = SCROLLING_COLUMN_FRACTION,
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
        zoom_factor = ZOOM_UNMAGNIFIED,
        zoom_rigid = false,
        zoom_detached_camera = false,
    },
    misc = {
        disable_hyprland_logo = true,
        force_default_wallpaper = 0,
        allow_session_lock_restore = true,
    },
    -- A passphrase prompt grabs the keyboard, which otherwise
    -- takes the magnifier away at exactly the moment there is
    -- something small to read. The locker holds the session
    -- lock rather than a grab, so it is unaffected.
    binds = {
        disable_keybind_grabbing = true,
    },
    animations = {
        enabled = true,
    },
})

motion.apply(motion.stored())

-- Palette-driven colours are written by the theme script and
-- are absent until it has run once, so Hyprland's own defaults
-- stand in on a machine that has never applied a theme.
pcall(dofile, state .. "/theme/hyprland.lua")
