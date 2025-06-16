----------- APPLICATION LAUNCHING --------------

local mods = {"ctrl", "alt", "shift"}

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




---------- ADD CUT+PASTE TO FINDER ------------

-- Table to store cut file paths
local cutFiles = {}

-- Function to get selected files in Finder via AppleScript
local function getSelectedFinderItems()
    local ok, result = hs.osascript.applescript([[
    tell application "Finder"
    set theItems to selection
    set thePaths to {}
    repeat with anItem in theItems
        set end of thePaths to POSIX path of (anItem as text)
    end repeat
end tell
return thePaths
]])
return ok and result or {}
end

-- Function to get target Finder window's path
local function getFrontFinderWindowPath()
    local ok, result = hs.osascript.applescript([[
    tell application "Finder"
    if (count of windows) > 0 then
        set theTarget to (target of front window) as alias
        return POSIX path of theTarget
    else
        return ""
    end if
end tell
]])
return ok and result or ""
end

-- Cut files (store paths)
hs.hotkey.bind({"ctrl", "cmd"}, "X", function()
    cutFiles = getSelectedFinderItems()
    if #cutFiles > 0 then
        hs.alert.show("Files Cut")
    else
        hs.alert.show("No files selected")
    end
end)

-- Paste files (move to new location)
hs.hotkey.bind({"ctrl", "cmd"}, "V", function()
    if #cutFiles == 0 then
        hs.alert.show("No files to paste")
        return
    end

    local targetDir = getFrontFinderWindowPath()
    if targetDir == "" then
        hs.alert.show("No Finder window open")
        return
    end

    for _, path in ipairs(cutFiles) do
        local cmd = string.format('mv "%s" "%s"', path, targetDir)
        hs.execute(cmd)
    end

    hs.alert.show("Files moved")
    cutFiles = {}
end)



------------ EMPTY BIN IN FINDER ------------

hs.hotkey.bind({"ctrl", "alt"}, "B", function()
    local frontApp = hs.application.frontmostApplication()
    if not (frontApp and frontApp:name() == "Finder") then return end

    -- Check if Trash has any items
    local binCheck = hs.execute('osascript -e \'tell application "Finder" to get count of items in trash\'')
    local binCount = tonumber(binCheck)

    if binCount == 0 then
        hs.alert.show("Bin is already empty")
        return
    end

    -- Prompt user for confirmation
    local button = hs.dialog.blockAlert(
        "Empty Bin?",
        "Are you sure you want to empty the Bin?",
        "Yes", "Cancel", "informational"
    )

    if button == "Yes" then
        hs.execute('osascript -e \'tell application "Finder" to empty the trash\'')
        hs.alert.show("Bin emptied")
    end

    -- Refocus Finder
    hs.application.launchOrFocus("Finder")
end)


------------ MISC TWEAKS  ------------

-- Insert phonographic rights symbol (℗) with Option+P
hs.hotkey.bind({"alt"}, "P", function()
    hs.eventtap.keyStrokes("℗")
end)
