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

local VOLUME_UP     = "volume up"
local VOLUME_DOWN   = "volume down"
local MUTE_VOL      = "volume mute"
local MUTE_MIC      = "volume mic"
local COPY_SCREEN   = "screenshot copy-screen"
local COPY_REGION   = "screenshot copy-region"
local SAVE_SCREEN   = "screenshot save-screen"
local SAVE_REGION   = "screenshot save-region"
local ANNOTATE      = "screenshot annotate"

local BRIGHTER      = "brightness up"
local DIMMER        = "brightness down"

local TERM          = "kitty"
local FILES         = TERM .. " yazi"
local BROWSER       = "firefox"
local ACTIVITY      = TERM .. " -o font_size=20 btop"
local LLM           = TERM .. " claude --dangerously-skip-permissions"
local PICKER        = "rofi -show drun"
local BINDS         = TERM .. " nvim ~/.dotfiles/.config/hypr/lua/binds.lua"
local JUMPBOX       = TERM .. " jumpbox"
local BLUETOOTH     = TERM .. " bluetoothctl"

local RESTORE_NOTE  = "makoctl restore"
local DND           = "makoctl mode -t do-not-disturb"
local DISMISS_ALL   = "makoctl dismiss --all"

local MONITOR_LEFT  = "focus-monitor left"
local MONITOR_RIGHT = "focus-monitor right"
local SEND_LEFT     = "send-window-to-monitor left"
local SEND_RIGHT    = "send-window-to-monitor right"

local BAR_TOGGLE    = "systemctl --user kill -s SIGUSR1 waybar.service"
local KEEP_AWAKE    = "keep-awake toggle"
local NIGHT_SHIFT   = "night-shift toggle"
local LOCK          = "loginctl lock-session"
local PLAY_PAUSE    = "playerctl play-pause"
local NEXT_TRACK    = "playerctl next"
local PREV_TRACK    = "playerctl previous"

local FOCUS_LEFT    = focus({ direction = "left" })
local FOCUS_RIGHT   = focus({ direction = "right" })
local FOCUS_DOWN    = actions.focus_step("down")
local FOCUS_UP      = actions.focus_step("up")

local MOVE_LEFT     = window.move({ direction = "left" })
local MOVE_DOWN     = window.move({ direction = "down" })
local MOVE_UP       = window.move({ direction = "up" })
local MOVE_RIGHT    = window.move({ direction = "right" })
local FLOAT_TOGGLE  = window.float({ action = "toggle" })

local NARROWER      = actions.resize(-RESIZE_STEP, 0)
local WIDER         = actions.resize(RESIZE_STEP, 0)
local TALLER        = actions.resize(0, RESIZE_STEP)
local SHORTER       = actions.resize(0, -RESIZE_STEP)

local KEY_VOL_UP    = "XF86AudioRaiseVolume"
local KEY_VOL_DOWN  = "XF86AudioLowerVolume"
local KEY_MUTE      = "XF86AudioMute"
local KEY_MIC_MUTE  = "XF86AudioMicMute"
local KEY_BRIGHT_UP = "XF86MonBrightnessUp"
local KEY_BRIGHT_DN = "XF86MonBrightnessDown"
local KEY_PLAY      = "XF86AudioPlay"
local KEY_PAUSE     = "XF86AudioPause"
local KEY_NEXT      = "XF86AudioNext"
local KEY_PREV      = "XF86AudioPrev"

local rows = {
    { "SUPER",                "Return",      run(TERM),                          "Open terminal"          },
    { "SUPER",                "b",           run(BROWSER),                       "Open browser"           },
    { "SUPER",                "f",           run(FILES),                         "Open file manager"      },
    { "SUPER",                "a",           run(ACTIVITY),                      "Open activity monitor"  },
    { "SUPER",                "o",           run("cpanel-sso"),                  "Open cPanel SSO"        },
    { "SUPER",                "i",           run(LLM),                           "Open Claude Code"       },
    { "SUPER",                "s",           run(JUMPBOX),                       "Open jumpbox"           },
    { "SUPER",                "space",       run(PICKER),                        "Open launcher"          },
    { "SUPER",                "v",           run("clipboard-history"),           "Open clipboard history" },
    { "SUPER + CTRL",         "comma",       run(BINDS),                         "Modify keybinds"        },

    { "SUPER",                "n",           run(RESTORE_NOTE),                  "Restore notification"   },
    { "SUPER + SHIFT",        "n",           run(DND),                           "Toggle do not disturb"  },
    { "SUPER + CTRL",         "n",           run(DISMISS_ALL),                   "Dismiss notifications"  },

    { "SUPER + ALT",          "t",           run("theme pick"),                  "Pick theme"             },
    { "SUPER + ALT",          "w",           run("wallpaper pick"),              "Pick wallpaper"         },
    { "SUPER + SHIFT",        "slash",       run("keybind-help"),                "Search keybinds"        },

    { "SUPER + SHIFT",        "q",           window.close(),                     "Close window"           },
    { "SUPER + SHIFT",        "x",           window.pin(),                       "Pin window"             },
    { "SUPER + SHIFT",        "f",           window.fullscreen(),                "Fullscreen window"      },
    { "SUPER + SHIFT",        "space",       FLOAT_TOGGLE,                       "Toggle floating"        },

    { "SUPER + SHIFT",        "t",           layouts.set("master"),              "Set master layout"      },
    { "SUPER + SHIFT",        "m",           layouts.set("monocle"),             "Set monocle layout"     },
    { "SUPER + SHIFT",        "s",           layouts.set("scrolling"),           "Set scrolling layout"   },
    { "SUPER + SHIFT",        "g",           gaps.toggle,                        "Toggle gaps"            },
    { "SUPER + SHIFT",        "b",           run(BAR_TOGGLE),                    "Toggle bar"             },

    { "SUPER",                "h",           FOCUS_LEFT,                         "Focus left"             },
    { "SUPER",                "j",           FOCUS_DOWN,                         "Focus down"             },
    { "SUPER",                "k",           FOCUS_UP,                           "Focus up"               },
    { "SUPER",                "l",           FOCUS_RIGHT,                        "Focus right"            },
    { "SUPER + SHIFT",        "h",           MOVE_LEFT,                          "Move window left"       },
    { "SUPER + SHIFT",        "j",           MOVE_DOWN,                          "Move window down"       },
    { "SUPER + SHIFT",        "k",           MOVE_UP,                            "Move window up"         },
    { "SUPER + SHIFT",        "l",           MOVE_RIGHT,                         "Move window right"      },

    { "SUPER",                "comma",       run(MONITOR_LEFT),                  "Focus monitor left"     },
    { "SUPER",                "period",      run(MONITOR_RIGHT),                 "Focus monitor right"    },
    { "SUPER + SHIFT",        "comma",       run(SEND_LEFT),                     "Send window left"       },
    { "SUPER + SHIFT",        "period",      run(SEND_RIGHT),                    "Send window right"      },

    { "SUPER + CTRL",         "h",           NARROWER,                           "Resize narrower"        },
    { "SUPER + CTRL",         "j",           TALLER,                             "Resize taller"          },
    { "SUPER + CTRL",         "k",           SHORTER,                            "Resize shorter"         },
    { "SUPER + CTRL",         "l",           WIDER,                              "Resize wider"           },

    { "SUPER",                "equal",       actions.zoom_in,                    "Zoom in"                },
    { "SUPER",                "minus",       actions.zoom_out,                   "Zoom out"               },
    { "SUPER",                "0",           actions.zoom_reset,                 "Reset zoom"             },
    { "SUPER",                "z",           actions.zoom_follow_toggle,         "Toggle zoom follow"     },
    { "SUPER",                "mouse_up",    actions.zoom_in,                    "Zoom in"                },
    { "SUPER",                "mouse_down",  actions.zoom_out,                   "Zoom out"               },

    { "SUPER + CTRL",         "c",           run(KEEP_AWAKE),                    "Toggle keep awake"      },
    { "SUPER + SHIFT",        "c",           run(BLUETOOTH),                     "Open bluetooth console" },
    { "SUPER + ALT",          "n",           run(NIGHT_SHIFT),                   "Toggle night shift"     },
    { "SUPER + ALT",          "r",           run("record"),                      "Toggle recording"       },

    { "SUPER",                "Escape",      run("power-menu"),                  "Open power menu"        },
    { "SUPER + SHIFT",        "Escape",      run(LOCK),                          "Lock screen"            },
    { "SUPER + ALT",          "e",           hl.dsp.exit(),                      "Exit session"           },

    { "SUPER",                "p",           run(COPY_SCREEN),                   "Copy screen"            },
    { "SUPER + SHIFT",        "p",           run(COPY_REGION),                   "Copy region"            },
    { "SUPER + CTRL",         "p",           run(SAVE_SCREEN),                   "Save screen"            },
    { "SUPER + CTRL + SHIFT", "p",           run(SAVE_REGION),                   "Save region"            },
    { "SUPER + ALT",          "p",           run(ANNOTATE),                      "Annotate region"        },

    { "",                     "Print",       run(COPY_REGION),                   "Copy region"            },
    { "SHIFT",                "Print",       run(COPY_SCREEN),                   "Copy screen"            },
    { "CTRL",                 "Print",       run(SAVE_SCREEN),                   "Save screen"            },
    { "CTRL + SHIFT",         "Print",       run(SAVE_REGION),                   "Save region"            },

    { "SUPER + ALT",          "up",          run(VOLUME_UP),             held,   "Raise volume"           },
    { "SUPER + ALT",          "down",        run(VOLUME_DOWN),           held,   "Lower volume"           },
    { "SUPER + ALT",          "m",           run(MUTE_VOL),              locked, "Mute sound"             },
    { "SUPER + ALT",          "right",       run(BRIGHTER),              held,   "Raise brightness"       },
    { "SUPER + ALT",          "left",        run(DIMMER),                held,   "Lower brightness"       },

    { "",                     KEY_VOL_UP,    run(VOLUME_UP),             held                             },
    { "",                     KEY_VOL_DOWN,  run(VOLUME_DOWN),           held                             },
    { "",                     KEY_MUTE,      run(MUTE_VOL),              locked                           },
    { "",                     KEY_MIC_MUTE,  run(MUTE_MIC),              locked                           },
    { "",                     KEY_BRIGHT_UP, run(BRIGHTER),              held                             },
    { "",                     KEY_BRIGHT_DN, run(DIMMER),                held                             },

    { "",                     KEY_PLAY,      run(PLAY_PAUSE),            locked, "Toggle playback"        },
    { "",                     KEY_PAUSE,     run(PLAY_PAUSE),            locked, "Toggle playback"        },
    { "",                     KEY_NEXT,      run(NEXT_TRACK),            locked, "Play next track"        },
    { "",                     KEY_PREV,      run(PREV_TRACK),            locked, "Play previous track"    },

    { "SUPER",                "mouse:272",   window.drag(),              mouse,  "Drag window"            },
    { "SUPER + SHIFT",        "mouse:272",   window.resize(),            mouse,  "Resize window"          },
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
