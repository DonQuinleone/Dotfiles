local SESSION_START = "sh -c 'systemctl --user import-environment"
    .. " WAYLAND_DISPLAY DISPLAY HYPRLAND_INSTANCE_SIGNATURE"
    .. " XDG_CURRENT_DESKTOP XDG_SESSION_TYPE"
    .. " && systemctl --user reset-failed"
    .. " && systemctl --user start desktop-session.target'"

hl.on("hyprland.start", function()
    hl.exec_cmd(SESSION_START)
end)

hl.on("hyprland.shutdown", function()
    hl.exec_cmd("systemctl --user stop desktop-session.target")
end)
