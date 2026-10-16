local CURSOR_SIZE = "48"

local home = os.getenv("HOME")
local path = os.getenv("PATH") or "/usr/local/bin:/usr/bin"

local local_bin = home .. "/.local/bin"

if not path:find(local_bin, 1, true) then
    path = local_bin .. ":" .. path
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
    { "MOZ_DISABLE_LANGPACKS", "1" },
    { "GNUPGHOME", home .. "/.local/share/gnupg" },
    { "CLAUDE_CONFIG_DIR", home .. "/.local/share/claude" },
    { "NPM_CONFIG_CACHE", home .. "/.cache/npm" },
}

for _, variable in ipairs(envs) do
    hl.env(variable[1], variable[2])
end
