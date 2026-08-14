local envs = {
    { "XCURSOR_THEME", "Adwaita" },
    { "XCURSOR_SIZE", "48" },
    { "HYPRCURSOR_SIZE", "48" },
    { "QT_QPA_PLATFORM", "wayland" },
    { "QT_QPA_PLATFORMTHEME", "qt6ct" },
    { "QT_WAYLAND_DISABLE_WINDOWDECORATION", "1" },
    { "MOZ_ENABLE_WAYLAND", "1" },
    { "QT_ACCESSIBILITY", "1" },
    { "QT_LINUX_ACCESSIBILITY_ALWAYS_ON", "1" },
    { "GNOME_ACCESSIBILITY", "1" },
}

for _, e in ipairs(envs) do
    hl.env(e[1], e[2])
end
