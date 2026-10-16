local actions = require("actions")
local monitors = require("monitors")
local gaps = require("gaps")
local layouts = require("layouts")
local state = require("state")

local RESIZE_STEP = 60

local held = { repeating = true }
local locked = { locked = true }
local mouse = { mouse = true }

local focus = hl.dsp.focus
local window = hl.dsp.window

local function run(command)
    return hl.dsp.exec_cmd(command)
end

local TERM       = "kitty"

local function terminal(command, options)
    local line = TERM
    if options then
        line = line .. " " .. options
    end
    return line .. " tmux-run " .. command
end

local BROWSER    = "firefox"
local ACTIVITY   = terminal("btop", "-o font_size=20")
local LLM        = terminal("claude --dangerously-skip-permissions")
local PICKER     = "rofi -show drun"
local BINDS      = terminal(
    "nvim ~/.dotfiles/.config/hypr/lua/binds.lua", "-o font_size=16")
local JUMPBOX    = terminal("jumpbox")
local BLUETOOTH  = terminal("bluetoothctl")

local BAR_TOGGLE = "bar toggle"
local BAR_TOGGLE_ALL = "bar all"

local BASTION    = "op item get ITEM_ID"
.. " --reveal --fields password | wl-copy --sensitive"
.. " && wtype -M ctrl -M shift -k v -m shift -m ctrl"

local SLACK_MUTE = {
    mods = "CTRL SHIFT",
    key = "space",
    window = "class:^(com\\.slack\\.Slack)$",
}

local rows = {
    { "SUPER",                "h",                     focus({ direction = "left" }),                 "Focus left"             },
    { "SUPER",                "j",                     actions.focus_step("down"),                    "Focus down"             },
    { "SUPER",                "k",                     actions.focus_step("up"),                      "Focus up"               },
    { "SUPER",                "l",                     focus({ direction = "right" }),                "Focus right"            },
    { "SUPER + SHIFT",        "h",                     window.move({ direction = "left" }),           "Move window left"       },
    { "SUPER + SHIFT",        "j",                     window.move({ direction = "down" }),           "Move window down"       },
    { "SUPER + SHIFT",        "k",                     window.move({ direction = "up" }),             "Move window up"         },
    { "SUPER + SHIFT",        "l",                     window.move({ direction = "right" }),          "Move window right"      },

    { "SUPER",                "comma",                 run("focus-monitor left"),                     "Focus monitor left"     },
    { "SUPER",                "period",                run("focus-monitor right"),                    "Focus monitor right"    },
    { "SUPER + SHIFT",        "comma",                 run("send-window-to-monitor left"),            "Send window left"       },
    { "SUPER + SHIFT",        "period",                run("send-window-to-monitor right"),           "Send window right"      },

    { "SUPER + SHIFT",        "q",                     window.close(),                                "Close window"           },
    { "SUPER + SHIFT",        "f",                     window.fullscreen(),                           "Fullscreen window"      },
    { "SUPER + SHIFT",        "space",                 window.float({ action = "toggle" }),           "Toggle floating"        },
    { "SUPER + SHIFT",        "x",                     window.pin(),                                  "Pin window"             },

    { "SUPER",                "Return",                run(TERM),                                     "Open terminal"          },
    { "SUPER",                "space",                 run(PICKER),                                   "Open launcher"          },
    { "SUPER",                "b",                     run(BROWSER),                                  "Open browser"           },
    { "SUPER",                "i",                     run(LLM),                                      "Open Claude Code"       },
    { "SUPER",                "s",                     run("flatpak run com.slack.Slack"),            "Open Slack"             },
    { "SUPER",                "t",                     run("ts3"),                                    "Open TeamSpeak 3"       },
    { "SUPER",                "o",                     run("cpanel-sso"),                             "Open cPanel SSO"        },
    { "SUPER + SHIFT",        "o",                     run(JUMPBOX),                                  "Open jumpbox"           },
    { "SUPER + CTRL",         "o",                     run(BASTION),                                  "Paste Bastion password" },
    { "SUPER",                "a",                     run(ACTIVITY),                                 "Open activity monitor"  },
    { "SUPER",                "v",                     run("clipboard-history"),                      "Open clipboard history" },
    { "SUPER",                "y",                     run("flatpak run com.yubico.yubioath"),        "Open Yubikey Auth"      },
    { "SUPER + CTRL",         "comma",                 run(BINDS),                                    "Modify keybinds"        },

    { "SUPER + SHIFT",        "t",                     layouts.set("master"),                         "Set master layout"      },
    { "SUPER + SHIFT",        "m",                     layouts.set("monocle"),                        "Set monocle layout"     },
    { "SUPER + SHIFT",        "s",                     layouts.set("scrolling"),                      "Set scrolling layout"   },
    { "SUPER + ALT",          "h",                     layouts.orient("left"),                        "Master column left"     },
    { "SUPER + ALT",          "l",                     layouts.orient("right"),                       "Master column right"    },
    { "SUPER",                "r",                     run("scene pick"),                             "Recall a scene"         },
    { "SUPER + SHIFT",        "g",                     gaps.toggle,                                   "Toggle gaps"            },
    { "SUPER + SHIFT",        "b",                     run(BAR_TOGGLE),                               "Toggle bar here"        },
    { "SUPER + CTRL + SHIFT", "b",                     run(BAR_TOGGLE_ALL),                           "Toggle all bars"        },

    { "SUPER + CTRL",         "h",                     actions.resize(-RESIZE_STEP, 0),               "Resize narrower"        },
    { "SUPER + CTRL",         "j",                     actions.resize(0, RESIZE_STEP),                "Resize taller"          },
    { "SUPER + CTRL",         "k",                     actions.resize(0, -RESIZE_STEP),               "Resize shorter"         },
    { "SUPER + CTRL",         "l",                     actions.resize(RESIZE_STEP, 0),                "Resize wider"           },

    { "SUPER",                "numbersign",            hl.dsp.send_shortcut(SLACK_MUTE),              "Toggle Slack mute"      },
    { "SUPER + ALT",          "m",                     run("volume mute"),                    locked, "Mute sound"             },
    { "SUPER + ALT",          "up",                    run("volume up"),                      held,   "Raise volume"           },
    { "SUPER + ALT",          "down",                  run("volume down"),                    held,   "Lower volume"           },
    { "SUPER + ALT",          "right",                 run("brightness up"),                  held,   "Raise brightness"       },
    { "SUPER + ALT",          "left",                  run("brightness down"),                held,   "Lower brightness"       },

    { "",                     "XF86AudioRaiseVolume",  run("volume up"),                      held                             },
    { "",                     "XF86AudioLowerVolume",  run("volume down"),                    held                             },
    { "",                     "XF86AudioMute",         run("volume mute"),                    locked                           },
    { "",                     "XF86AudioMicMute",      run("volume mic"),                     locked                           },
    { "",                     "XF86MonBrightnessUp",   run("brightness up"),                  held                             },
    { "",                     "XF86MonBrightnessDown", run("brightness down"),                held                             },

    { "",                     "XF86AudioPlay",         run("playerctl play-pause"),           locked, "Toggle playback"        },
    { "",                     "XF86AudioPause",        run("playerctl play-pause"),           locked, "Toggle playback"        },
    { "",                     "XF86AudioNext",         run("playerctl next"),                 locked, "Play next track"        },
    { "",                     "XF86AudioPrev",         run("playerctl previous"),             locked, "Play previous track"    },

    { "SUPER",                "p",                     run("screenshot copy-screen"),                 "Copy screen"            },
    { "SUPER + SHIFT",        "p",                     run("screenshot copy-region"),                 "Copy region"            },
    { "SUPER + CTRL",         "p",                     run("screenshot save-screen"),                 "Save screen"            },
    { "SUPER + CTRL + SHIFT", "p",                     run("screenshot save-region"),                 "Save region"            },
    { "SUPER + ALT",          "p",                     run("screenshot annotate"),                    "Annotate region"        },
    { "SUPER + ALT",          "r",                     run("record"),                                 "Toggle recording"       },

    { "",                     "Print",                 run("screenshot copy-region"),                 "Copy region"            },
    { "SHIFT",                "Print",                 run("screenshot copy-screen"),                 "Copy screen"            },
    { "CTRL",                 "Print",                 run("screenshot save-screen"),                 "Save screen"            },
    { "CTRL + SHIFT",         "Print",                 run("screenshot save-region"),                 "Save region"            },

    { "SUPER",                "n",                     run("makoctl restore"),                        "Restore notification"   },
    { "SUPER + SHIFT",        "n",                     run("dnd toggle"),                             "Toggle do not disturb"  },
    { "SUPER + CTRL",         "n",                     run("makoctl dismiss --all"),                  "Dismiss notifications"  },

    { "SUPER",                "c",                     run("caffeinate toggle"),                      "Toggle caffeinate"      },
    { "SUPER + ALT",          "n",                     run("night-shift toggle"),                     "Toggle night shift"     },
    { "SUPER + SHIFT",        "c",                     run(BLUETOOTH),                                "Open bluetooth console" },

    { "SUPER",                "equal",                 actions.zoom_in,                               "Zoom in"                },
    { "SUPER",                "minus",                 actions.zoom_out,                              "Zoom out"               },
    { "SUPER",                "0",                     actions.zoom_reset,                            "Reset zoom"             },
    { "SUPER",                "z",                     actions.zoom_follow_toggle,                    "Toggle zoom follow"     },
    { "SUPER",                "mouse_up",              actions.zoom_in,                               "Zoom in"                },
    { "SUPER",                "mouse_down",            actions.zoom_out,                              "Zoom out"               },

    { "SUPER + ALT",          "t",                     run("theme pick"),                             "Pick theme"             },
    { "SUPER + ALT",          "w",                     run("wallpaper pick"),                         "Pick wallpaper"         },
    { "SUPER + SHIFT",        "slash",                 run("keybind-help"),                           "Search keybinds"        },

    { "SUPER",                "Escape",                run("power-menu"),                             "Open power menu"        },
    { "SUPER + SHIFT",        "Escape",                run("loginctl lock-session"),                  "Lock screen"            },
    { "SUPER + ALT",          "e",                     hl.dsp.exit(),                                 "Exit session"           },

    { "SUPER",                "mouse:272",             window.drag(),                         mouse,  "Drag window"            },
    { "SUPER + SHIFT",        "mouse:272",             window.resize(),                       mouse,  "Resize window"          },
}

for index = 1, monitors.WORKSPACES_PER_MONITOR do
    table.insert(rows, { "SUPER", index, function()
        hl.dispatch(focus({
            workspace = monitors.workspace_for(index),
        }))
    end, "Focus workspace " .. index })
    table.insert(rows, { "SUPER + SHIFT", index, function()
        layouts.send_to_workspace(
            monitors.workspace_for(index))()
    end, "Send window to workspace " .. index })
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

local sheet = state.writer("hypr/binds.tsv")
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
