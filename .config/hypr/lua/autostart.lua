local COMMANDS = {
    "sh -c 'systemctl --user import-environment WAYLAND_DISPLAY"
        .. " DISPLAY HYPRLAND_INSTANCE_SIGNATURE"
        .. " XDG_CURRENT_DESKTOP XDG_SESSION_TYPE"
        .. " && systemctl --user start desktop-session.target'",
    "gsettings set org.gnome.desktop.interface "
        .. "toolkit-accessibility true",
}

hl.on("hyprland.start", function()
    for _, command in ipairs(COMMANDS) do
        hl.exec_cmd(command)
    end
end)
