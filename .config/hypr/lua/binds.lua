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

local TERM       = "kitty"
local FILES      = TERM .. " yazi"
local BROWSER    = "firefox"
local ACTIVITY   = TERM .. " -o font_size=20 btop"
local LLM        = TERM .. " claude --dangerously-skip-permissions"
local PICKER     = "rofi -show drun"
local BINDS      = TERM .. " nvim ~/.dotfiles/.config/hypr/lua/binds.lua"
local JUMPBOX    = TERM .. " jumpbox"
local BLUETOOTH  = TERM .. " bluetoothctl"

local BAR_TOGGLE = "systemctl --user kill -s SIGUSR1 waybar.service"

local BASTION    = "op item get ITEM_ID"
    .. " --reveal --fields password | wl-copy"
    .. " && wtype -M ctrl -M shift -k v -m shift -m ctrl"

local rows = {
    { "SUPER",                "Return",                run(TERM),                                     "Open terminal"          },
    { "SUPER",                "b",                     run(BROWSER),                                  "Open browser"           },
    { "SUPER",                "f",                     run(FILES),                                    "Open file manager"      },
    { "SUPER",                "a",                     run(ACTIVITY),                                 "Open activity monitor"  },
    { "SUPER",                "o",                     run("cpanel-sso"),                             "Open cPanel SSO"        },
    { "SUPER",                "i",                     run(LLM),                                      "Open Claude Code"       },
    { "SUPER",                "s",                     run(JUMPBOX),                                  "Open jumpbox"           },
    { "SUPER",                "space",                 run(PICKER),                                   "Open launcher"          },
    { "SUPER",                "v",                     run("clipboard-history"),                      "Open clipboard history" },
    { "SUPER + CTRL",         "o",                     run(BASTION),                                  "Paste Bastion password" },
    { "SUPER + CTRL",         "comma",                 run(BINDS),                                    "Modify keybinds"        },

    { "SUPER",                "n",                     run("makoctl restore"),                        "Restore notification"   },
    { "SUPER + SHIFT",        "n",                     run("makoctl mode -t do-not-disturb"),         "Toggle do not disturb"  },
    { "SUPER + CTRL",         "n",                     run("makoctl dismiss --all"),                  "Dismiss notifications"  },

    { "SUPER + ALT",          "t",                     run("theme pick"),                             "Pick theme"             },
    { "SUPER + ALT",          "w",                     run("wallpaper pick"),                         "Pick wallpaper"         },
    { "SUPER + SHIFT",        "slash",                 run("keybind-help"),                           "Search keybinds"        },

    { "SUPER + SHIFT",        "q",                     window.close(),                                "Close window"           },
    { "SUPER + SHIFT",        "x",                     window.pin(),                                  "Pin window"             },
    { "SUPER + SHIFT",        "f",                     window.fullscreen(),                           "Fullscreen window"      },
    { "SUPER + SHIFT",        "space",                 window.float({ action = "toggle" }),           "Toggle floating"        },

    { "SUPER + SHIFT",        "t",                     layouts.set("master"),                         "Set master layout"      },
    { "SUPER + SHIFT",        "m",                     layouts.set("monocle"),                        "Set monocle layout"     },
    { "SUPER + SHIFT",        "s",                     layouts.set("scrolling"),                      "Set scrolling layout"   },
    { "SUPER + SHIFT",        "g",                     gaps.toggle,                                   "Toggle gaps"            },
    { "SUPER + SHIFT",        "b",                     run(BAR_TOGGLE),                               "Toggle bar"             },

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

    { "SUPER + CTRL",         "h",                     actions.resize(-RESIZE_STEP, 0),               "Resize narrower"        },
    { "SUPER + CTRL",         "j",                     actions.resize(0, RESIZE_STEP),                "Resize taller"          },
    { "SUPER + CTRL",         "k",                     actions.resize(0, -RESIZE_STEP),               "Resize shorter"         },
    { "SUPER + CTRL",         "l",                     actions.resize(RESIZE_STEP, 0),                "Resize wider"           },

    { "SUPER",                "equal",                 actions.zoom_in,                               "Zoom in"                },
    { "SUPER",                "minus",                 actions.zoom_out,                              "Zoom out"               },
    { "SUPER",                "0",                     actions.zoom_reset,                            "Reset zoom"             },
    { "SUPER",                "z",                     actions.zoom_follow_toggle,                    "Toggle zoom follow"     },
    { "SUPER",                "mouse_up",              actions.zoom_in,                               "Zoom in"                },
    { "SUPER",                "mouse_down",            actions.zoom_out,                              "Zoom out"               },

    { "SUPER + CTRL",         "c",                     run("keep-awake toggle"),                      "Toggle keep awake"      },
    { "SUPER + SHIFT",        "c",                     run(BLUETOOTH),                                "Open bluetooth console" },
    { "SUPER + ALT",          "n",                     run("night-shift toggle"),                     "Toggle night shift"     },
    { "SUPER + ALT",          "r",                     run("record"),                                 "Toggle recording"       },

    { "SUPER",                "Escape",                run("power-menu"),                             "Open power menu"        },
    { "SUPER + SHIFT",        "Escape",                run("loginctl lock-session"),                  "Lock screen"            },
    { "SUPER + ALT",          "e",                     hl.dsp.exit(),                                 "Exit session"           },

    { "SUPER",                "p",                     run("screenshot copy-screen"),                 "Copy screen"            },
    { "SUPER + SHIFT",        "p",                     run("screenshot copy-region"),                 "Copy region"            },
    { "SUPER + CTRL",         "p",                     run("screenshot save-screen"),                 "Save screen"            },
    { "SUPER + CTRL + SHIFT", "p",                     run("screenshot save-region"),                 "Save region"            },
    { "SUPER + ALT",          "p",                     run("screenshot annotate"),                    "Annotate region"        },

    { "",                     "Print",                 run("screenshot copy-region"),                 "Copy region"            },
    { "SHIFT",                "Print",                 run("screenshot copy-screen"),                 "Copy screen"            },
    { "CTRL",                 "Print",                 run("screenshot save-screen"),                 "Save screen"            },
    { "CTRL + SHIFT",         "Print",                 run("screenshot save-region"),                 "Save region"            },

    { "SUPER + ALT",          "up",                    run("volume up"),                      held,   "Raise volume"           },
    { "SUPER + ALT",          "down",                  run("volume down"),                    held,   "Lower volume"           },
    { "SUPER + ALT",          "m",                     run("volume mute"),                    locked, "Mute sound"             },
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

    { "SUPER",                "mouse:272",             window.drag(),                         mouse,  "Drag window"            },
    { "SUPER + SHIFT",        "mouse:272",             window.resize(),                       mouse,  "Resize window"          },
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
