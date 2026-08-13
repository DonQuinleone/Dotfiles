local envs = {
    { "XCURSOR_THEME", "Adwaita" },
    { "XCURSOR_SIZE", "48" },
    { "HYPRCURSOR_SIZE", "48" },
    { "QT_QPA_PLATFORM", "wayland" },
    { "MOZ_ENABLE_WAYLAND", "1" },
}

for _, e in ipairs(envs) do
    hl.env(e[1], e[2])
end
