local actions = require("actions")
local monitors = require("monitors")
local gaps = require("gaps")
local layouts = require("layouts")

local RESIZE_STEP = 60
local WORKSPACES_PER_MONITOR = 9

local held = { repeating = true }
local locked = { locked = true }
local mouse = { mouse = true }

local focus = hl.dsp.focus
local window = hl.dsp.window

local function run(command)
    return hl.dsp.exec_cmd(command)
end

local VOLUME_UP = "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
local VOLUME_DOWN = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
local SINK_MUTE = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
local SOURCE_MUTE = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
local COPY_SCREEN = "screenshot copy-screen"
local COPY_REGION = "screenshot copy-region"
local SAVE_SCREEN = "screenshot save-screen"
local SAVE_REGION = "screenshot save-region"

local BRIGHTER = "brightnessctl set 5%+"
local DIMMER = "brightnessctl set 5%-"

local rows = {
    { "SUPER", "Return", run("kitty"),
      "Open the terminal" },
    { "SUPER", "b", run("firefox"),
      "Open the browser" },
    { "SUPER", "f", run("kitty --class files yazi"),
      "Open the file manager" },
    { "SUPER", "a", run("kitty --class activity btop"),
      "See the machine's activity" },
    { "SUPER", "o", run("cpanel-sso"),
      "cPanel SSO" },
    { "SUPER", "i",
      run("kitty --class agent claude --dangerously-skip-permissions"),
      "Open the coding agent" },
    { "SUPER", "space", run("rofi -show drun"),
      "Open the launcher" },
    { "SUPER", "v", run("clipboard-history"),
      "Paste from the clipboard history" },
    { "SUPER + CTRL", "v", run("clipboard-history"),
      "Paste from the clipboard history" },
    { "SUPER + CTRL", "e", run("rofimoji"),
      "Insert an emoji" },

    { "SUPER", "n", run("makoctl restore"),
      "Bring back the last notification" },
    { "SUPER + SHIFT", "n",
      run("makoctl mode -t do-not-disturb"),
      "Toggle do not disturb" },
    { "SUPER + CTRL", "n", run("makoctl dismiss --all"),
      "Dismiss every notification" },

    { "SUPER + ALT", "t", run("theme pick"),
      "Choose the theme" },
    { "SUPER + ALT", "w", run("wallpaper pick"),
      "Choose the wallpaper" },

    { "SUPER + SHIFT", "slash", run("keybind-help"),
      "Search these keybinds" },

    { "SUPER + SHIFT", "q", window.close(),
      "Close the window" },
    { "SUPER + SHIFT", "x", window.pin(),
      "Pin the window" },
    { "SUPER + SHIFT", "f", window.fullscreen(),
      "Fullscreen the window" },
    { "SUPER + SHIFT", "space",
      window.float({ action = "toggle" }),
      "Float or tile the window" },

    { "SUPER + SHIFT", "t", layouts.set("master"),
      "The master layout" },
    { "SUPER + SHIFT", "m", layouts.set("monocle"),
      "The monocle layout" },
    { "SUPER + SHIFT", "s", layouts.set("scrolling"),
      "The scrolling layout" },
    { "SUPER + SHIFT", "backslash", layouts.cycle,
      "The next layout along" },
    { "SUPER + SHIFT", "g", gaps.toggle,
      "Toggle the gaps" },

    { "SUPER", "h", focus({ direction = "left" }),
      "Focus leftwards" },
    { "SUPER", "j", actions.focus_step("down"),
      "Focus downwards" },
    { "SUPER", "k", actions.focus_step("up"),
      "Focus upwards" },
    { "SUPER", "l", focus({ direction = "right" }),
      "Focus rightwards" },
    { "SUPER + SHIFT", "h", window.move({ direction = "left" }),
      "Move the window left" },
    { "SUPER + SHIFT", "j", window.move({ direction = "down" }),
      "Move the window down" },
    { "SUPER + SHIFT", "k", window.move({ direction = "up" }),
      "Move the window up" },
    { "SUPER + SHIFT", "l", window.move({ direction = "right" }),
      "Move the window right" },

    { "SUPER", "comma", run("focus-monitor left"),
      "Focus the monitor to the left" },
    { "SUPER", "period", run("focus-monitor right"),
      "Focus the monitor to the right" },
    { "SUPER + SHIFT", "comma",
      run("send-window-to-monitor left"),
      "Send the window a monitor left" },
    { "SUPER + SHIFT", "period",
      run("send-window-to-monitor right"),
      "Send the window a monitor right" },

    { "SUPER + CTRL", "h", actions.resize(-RESIZE_STEP, 0),
      "Resize narrower" },
    { "SUPER + CTRL", "j", actions.resize(0, RESIZE_STEP),
      "Resize taller" },
    { "SUPER + CTRL", "k", actions.resize(0, -RESIZE_STEP),
      "Resize shorter" },
    { "SUPER + CTRL", "l", actions.resize(RESIZE_STEP, 0),
      "Resize wider" },

    { "SUPER", "equal", actions.zoom_in, "Zoom in" },
    { "SUPER", "minus", actions.zoom_out, "Zoom out" },
    { "SUPER", "0", actions.zoom_reset, "Put the zoom back" },
    { "SUPER", "z", actions.zoom_follow_toggle,
      "Toggle the zoom following the cursor" },
    { "SUPER", "mouse_up", actions.zoom_in, "Zoom in" },
    { "SUPER", "mouse_down", actions.zoom_out, "Zoom out" },

    { "SUPER + CTRL", "c", run("keep-awake toggle"),
      "Keep the computer awake" },
    { "SUPER + SHIFT", "c",
      run("kitty --class activity bluetoothctl"),
      "Bluetooth, at the console" },
    { "SUPER + ALT", "n", run("night-shift toggle"),
      "Toggle night shift" },
    { "SUPER + ALT", "r", run("record"),
      "Record a region, or stop" },

    { "SUPER", "Escape", run("power-menu"),
      "Open the power menu" },
    { "SUPER + SHIFT", "Escape", run("loginctl lock-session"),
      "Lock the screen" },
    { "SUPER + ALT", "e", hl.dsp.exit(),
      "Leave the session" },

    { "SUPER", "p", run(COPY_SCREEN),
      "Copy the screen" },
    { "SUPER + SHIFT", "p", run(COPY_REGION),
      "Copy a region" },
    { "SUPER + CTRL", "p", run(SAVE_SCREEN),
      "Save the screen" },
    { "SUPER + CTRL + SHIFT", "p", run(SAVE_REGION),
      "Save a region" },
    { "SUPER + ALT", "p", run("screenshot annotate"),
      "Annotate a region" },

    { "", "Print", run(COPY_REGION), "Copy a region" },
    { "SHIFT", "Print", run(COPY_SCREEN), "Copy the screen" },
    { "CTRL", "Print", run(SAVE_SCREEN), "Save the screen" },
    { "CTRL + SHIFT", "Print", run(SAVE_REGION),
      "Save a region" },

    { "SUPER + ALT", "up", run(VOLUME_UP), held, "Volume up" },
    { "SUPER + ALT", "down", run(VOLUME_DOWN), held,
      "Volume down" },
    { "SUPER + ALT", "m", run(SINK_MUTE), locked,
      "Mute the sound" },
    { "SUPER + ALT", "right", run(BRIGHTER), held, "Brighter" },
    { "SUPER + ALT", "left", run(DIMMER), held, "Dimmer" },

    { "", "XF86AudioRaiseVolume", run(VOLUME_UP), held },
    { "", "XF86AudioLowerVolume", run(VOLUME_DOWN), held },
    { "", "XF86AudioMute", run(SINK_MUTE), locked },
    { "", "XF86AudioMicMute", run(SOURCE_MUTE), locked },
    { "", "XF86MonBrightnessUp", run(BRIGHTER), held },
    { "", "XF86MonBrightnessDown", run(DIMMER), held },

    { "", "XF86AudioPlay", run("playerctl play-pause"), locked,
      "Play or pause" },
    { "", "XF86AudioPause", run("playerctl play-pause"), locked,
      "Play or pause" },
    { "", "XF86AudioNext", run("playerctl next"), locked,
      "Next track" },
    { "", "XF86AudioPrev", run("playerctl previous"), locked,
      "Previous track" },

    { "SUPER", "mouse:272", window.drag(), mouse,
      "Drag the window" },
    { "SUPER + SHIFT", "mouse:272", window.resize(), mouse,
      "Resize the window" },
}

for index = 1, WORKSPACES_PER_MONITOR do
    table.insert(rows, { "SUPER", index, function()
        hl.dispatch(focus({
            workspace = monitors.workspace_for(index),
        }))
    end, "Focus workspace " .. index })
    table.insert(rows, { "SUPER + SHIFT", index, function()
        layouts.send_to_workspace(
            monitors.workspace_for(index))()
    end, "Send the window to workspace " .. index })
end

local function combination(mods, key)
    if mods == nil or mods == "" then
        return tostring(key)
    end
    return mods .. " + " .. key
end

local function options_of(row)
    if type(row[4]) == "table" then
        return row[4]
    end
    return nil
end

local function description_of(row)
    if type(row[4]) == "string" then
        return row[4]
    end
    if type(row[5]) == "string" then
        return row[5]
    end
    return nil
end

for _, row in ipairs(rows) do
    hl.bind(combination(row[1], row[2]), row[3], options_of(row))
end

local state = os.getenv("XDG_STATE_HOME")
    or (os.getenv("HOME") .. "/.local/state")

os.execute("mkdir -p '" .. state .. "/hypr'")

local sheet = io.open(state .. "/hypr/binds.tsv", "w")
if sheet ~= nil then
    for _, row in ipairs(rows) do
        local description = description_of(row)
        if description ~= nil then
            sheet:write(combination(row[1], row[2]), "\t",
                description, "\n")
        end
    end
    sheet:close()
end
