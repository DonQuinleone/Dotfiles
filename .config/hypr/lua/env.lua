local CURSOR_SIZE = "48"

local home = os.getenv("HOME")
local path = os.getenv("PATH") or "/usr/local/bin:/usr/bin"

local home_directories = {
    home .. "/.local/share/mise/shims",
    home .. "/.local/bin",
}

for _, directory in ipairs(home_directories) do
    if not path:find(directory, 1, true) then
        path = directory .. ":" .. path
    end
end

local envs = {
    { "PATH", path },
    { "TERMINAL", "kitty-tmux" },
    { "EDITOR", "nvim" },
    { "XCURSOR_THEME", "Adwaita" },
    { "XCURSOR_SIZE", CURSOR_SIZE },
    { "HYPRCURSOR_SIZE", CURSOR_SIZE },
    { "QT_QPA_PLATFORM", "wayland;xcb" },
    { "QT_QPA_PLATFORMTHEME", "qt6ct" },
    { "QT_WAYLAND_DISABLE_WINDOWDECORATION", "1" },
    { "MOZ_ENABLE_WAYLAND", "1" },
    { "MOZ_DISABLE_LANGPACKS", "1" },
    { "GNUPGHOME", home .. "/.local/share/gnupg" },
    { "CLAUDE_CONFIG_DIR", home .. "/.local/share/claude" },
    { "NPM_CONFIG_CACHE", home .. "/.cache/npm" },
    { "QT_ACCESSIBILITY", "1" },
    { "QT_LINUX_ACCESSIBILITY_ALWAYS_ON", "1" },
    { "GNOME_ACCESSIBILITY", "1" },
}

for _, variable in ipairs(envs) do
    hl.env(variable[1], variable[2])
end
