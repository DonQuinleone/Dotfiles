local config = os.getenv("XDG_CONFIG_HOME")
    or (os.getenv("HOME") .. "/.config")

local commands = {
    "gsettings set org.gnome.desktop.interface "
        .. "toolkit-accessibility true",
    config .. "/hypr/scripts/caret-follow",
    "qs -c ember",
    config .. "/hypr/scripts/theme-daemon",
    config .. "/hypr/scripts/idle-profile",
}

hl.on("hyprland.start", function()
    for _, command in ipairs(commands) do
        hl.exec_cmd(command)
    end
end)
