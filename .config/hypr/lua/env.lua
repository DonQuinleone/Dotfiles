local DEFAULT_CURSOR_SIZE = 48

local apps = require("apps")
local saved = require("settings").load()

local cache = os.getenv("XDG_CACHE_HOME")
    or (os.getenv("HOME") .. "/.cache")

local data = os.getenv("XDG_DATA_HOME")
    or (os.getenv("HOME") .. "/.local/share")

local state = os.getenv("XDG_STATE_HOME")
    or (os.getenv("HOME") .. "/.local/state")

local cursor_size = tostring(
    saved.cursor_size or DEFAULT_CURSOR_SIZE)

local envs = {
    { "TERMINAL", apps.terminal },
    { "EDITOR", apps.editor },
    { "XCURSOR_THEME", "Adwaita" },
    { "XCURSOR_SIZE", cursor_size },
    { "HYPRCURSOR_SIZE", cursor_size },
    -- Applications shipping their own Qt, TeamSpeak among
    -- them, abort outright when their bundled Wayland plugin
    -- fails to initialise, so leave XWayland as the fallback.
    { "QT_QPA_PLATFORM", "wayland;xcb" },
    { "QT_QPA_PLATFORMTHEME", "qt6ct" },
    { "QT_WAYLAND_DISABLE_WINDOWDECORATION", "1" },
    { "MOZ_ENABLE_WAYLAND", "1" },
    -- Fedora's launcher keeps ~/.mozilla alive to track
    -- langpacks, and Firefox then prefers it over the XDG
    -- directory its profile already lives in.
    { "MOZ_DISABLE_LANGPACKS", "1" },
    { "NPM_CONFIG_CACHE", cache .. "/npm" },
    { "GNUPGHOME", data .. "/gnupg" },
    -- A terminal started by the compositor never sources
    -- the shell config, so Claude Code would otherwise fall
    -- back to ~/.claude and keep a second set of settings.
    { "CLAUDE_CONFIG_DIR", data .. "/claude" },
    { "QT_ACCESSIBILITY", "1" },
    { "QT_LINUX_ACCESSIBILITY_ALWAYS_ON", "1" },
    { "GNOME_ACCESSIBILITY", "1" },
}

for _, e in ipairs(envs) do
    hl.env(e[1], e[2])
end
