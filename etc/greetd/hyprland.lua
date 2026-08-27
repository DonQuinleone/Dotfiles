local MONITORS = {
    {
        description = "Microstep MPG321UX OLED 0x01010101",
        mode = "3840x2160@60.00",
        position = "0x720",
        scale = 1.5,
        bitdepth = 10,
    },
    {
        description = "LG Electronics BL650 201NTFAP0155",
        mode = "1920x1080@60.00",
        position = "2560x0",
        scale = 1,
        bitdepth = 8,
    },
    {
        description = "LG Electronics BL650 201NTJJP0156",
        mode = "1920x1080@60.00",
        position = "2560x1080",
        scale = 1,
        bitdepth = 8,
    },
    {
        description = "Chimei Innolux Corporation N160JCA-GT1",
        mode = "1920x1200@60.00",
        position = "0x2160",
        scale = 1,
        bitdepth = 8,
    },
}

local ALT_ON_BOTH_SIDES = "lv3:ralt_alt"
local GREETER = "gtkgreet -l -c start-hyprland"
    .. " -s /etc/greetd/style.css"
    .. "; hyprctl dispatch \"hl.dsp.exit()\""

hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = 1,
})

for _, monitor in ipairs(MONITORS) do
    hl.monitor({
        output = "desc:" .. monitor.description,
        mode = monitor.mode,
        position = monitor.position,
        scale = monitor.scale,
        bitdepth = monitor.bitdepth,
    })
end

hl.config({
    input = {
        kb_layout = "gb",
        kb_options = ALT_ON_BOTH_SIDES,
    },
    misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        force_default_wallpaper = 0,
    },
    animations = {
        enabled = false,
    },
})

hl.on("hyprland.start", function()
    hl.exec_cmd(GREETER)
end)
