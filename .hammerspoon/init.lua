local mods = {"ctrl", "alt"}

local appBindings = {
    -- Browsers & Internet
    ["B"]       = "LibreWolf",
    ["E"]       = "Ente Auth",
    ["P"]       = "Bitwarden",
    -- Communication
    ["D"]       = "Discord",
    ["M"]       = "Thunderbird",
    ["O"]       = "Microsoft Outlook",
    ["T"]       = "Microsoft Teams",
    ["Z"]       = "zoom.us",
    -- File Management
    ["C"]       = "Cyberduck",
    ["F"]       = "Finder",
    -- Productivity & Utilities
    ["H"]       = "Home",
    ["K"]       = "Calendar",
    ["."]       = "System Settings",
    ["return"]  = "Ghostty",
    [","]       = "Keymapp",
    ["N"]       = "Notes",
    ["W"]       = "Microsoft Word",
    ["X"]       = "Microsoft Excel",
    ["Q"]       = "Microsoft PowerPoint",
    -- Audio
    ["A"]       = "Loopback",
    ["L"]       = "TakeLogger",
    ["0"]       = "Pro Tools",
    ["9"]       = "DSP-Quattro",
    ["8"]       = "iZotope RX 10 Audio Editor",
    ["7"]       = "dBpoweramp Music Converter",
    ["6"]       = "Melodyne",
    ["3"]       = "Mp3tag",
    ["S"]       = "Spotify",
    -- Adobe Creative Suite
    ["U"]       = "Adobe Photoshop 2025",
    ["I"]       = "Adobe Illustrator 2025",
    ["Y"]       = "Adobe Premiere Pro 2025",
    -- Games
    ["G"]       = "Steam",
    ["V"]       = "Minecraft",
}

for key, app in pairs(appBindings) do
    hs.hotkey.bind(mods, key, function()
        hs.application.launchOrFocus(app)
    end)
end

hs.hotkey.bind(mods, "R", hs.reload)
