local MASTER_AREA_FRACTION = 0.6
local SCROLLING_COLUMN_FRACTION = 0.5
local GROUPBAR_HEIGHT = 34
local GROUPBAR_TEXT_PADDING = 12
local GROUPBAR_ROUNDING = 8
local GROUPBAR_TAB_GAP = 2
local GROUPBAR_WINDOW_GAP = 6
local GROUPBAR_INDICATOR_HEIGHT = 0

local motion = require("motion")

local state = os.getenv("XDG_STATE_HOME")
    or (os.getenv("HOME") .. "/.local/state")

hl.config({
    general = {
        gaps_in = 6,
        gaps_out = 12,
        border_size = 4,
        layout = "master",
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
    decoration = {
        rounding = 10,
        blur = {
            enabled = true,
            size = 8,
            passes = 2,
        },
    },
    cursor = {
        zoom_factor = 1.0,
        zoom_rigid = false,
        zoom_detached_camera = false,
    },
    misc = {
        disable_hyprland_logo = true,
        force_default_wallpaper = 0,
        allow_session_lock_restore = true,
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
