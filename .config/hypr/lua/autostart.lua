local donbox = os.getenv("HOME") .. "/.local/bin/donbox"

-- graphical-session.target refuses a manual start, so the only
-- way to reach it is a target bound to it. Nothing else pulls it
-- in when the compositor is started straight from the greeter,
-- and without it xdg-desktop-portal never runs: GTK then has
-- nobody to ask for color-scheme and falls back to light.
local commands = {
    "systemctl --user start donbox-session.target",
    "gsettings set org.gnome.desktop.interface "
        .. "toolkit-accessibility true",
    donbox .. " caret follow",
    -- A second shell draws its own bar, wallpaper and toasts
    -- over the first, and the two are indistinguishable on
    -- screen until something is clicked twice.
    "qs -n -c donbox",
    -- Records what is copied, so the clipboard picker has a
    -- history to offer.
    "wl-paste --watch cliphist store",
    donbox .. " theme daemon",
    donbox .. " idle profile",
    donbox .. " nightshift daemon",
}

hl.on("hyprland.start", function()
    for _, command in ipairs(commands) do
        hl.exec_cmd(command)
    end
end)
