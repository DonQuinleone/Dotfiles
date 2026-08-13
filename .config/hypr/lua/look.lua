local ember = {
    bg = "1B1B1B",
    fg = "E7E7E7",
    accent = "DC6F00",
    accent_soft = "F0A05A",
    border_idle = "3A332D",
}

hl.config({
    general = {
        gaps_in = 6,
        gaps_out = 12,
        border_size = 4,
        ["col.active_border"] = "rgba(" .. ember.accent
            .. "ff) rgba(" .. ember.accent_soft .. "ff) 45deg",
        ["col.inactive_border"] = "rgba(" .. ember.border_idle
            .. "ff)",
        layout = "master",
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
        allow_session_lock_restore = true,
        vfr = true,
    },
    animations = {
        enabled = true,
    },
})

-- Speeds are in deciseconds: frequent actions stay near
-- 150-200ms, zoom is deliberately faster than COSMIC's.
local beziers = {
    { "emberOut", 0.16, 1.0, 0.3, 1.0 },
    { "emberSnap", 0.2, 0.9, 0.1, 1.0 },
}

local animations = {
    { "windows", true, 2.0, "emberOut" },
    { "workspaces", true, 2.0, "emberOut", "slide" },
    { "zoomFactor", true, 1.5, "emberSnap" },
    { "fade", true, 1.5, "emberOut" },
    { "border", true, 3.0, "emberOut" },
}

for _, b in ipairs(beziers) do
    hl.bezier(b[1], b[2], b[3], b[4], b[5])
end

for _, a in ipairs(animations) do
    hl.animation(a[1], a[2], a[3], a[4], a[5])
end
