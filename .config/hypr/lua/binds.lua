local actions = require("actions")
local gaps = require("gaps")
local layouts = require("layouts")

local donbox = "$HOME/.local/bin/donbox"
local RESIZE_STEP = 60

local held = { locked = true, repeating = true }
local locked = { locked = true }
local mouse = { mouse = true }

-- SUPER goes somewhere, SUPER + SHIFT acts on the focused
-- window, SUPER + CTRL adjusts, SUPER + ALT is hardware, the
-- session and the look. Appearance sits under the thumb rather
-- than with the other adjustments because it is changed often.
-- The magnifier keeps plain SUPER against the rule for the same
-- reason, being in constant use.
local binds = {
    -- Applications
    { "SUPER",           "Return",                hl.dsp.exec_cmd("ghostty")                             },
    { "SUPER",           "b",                     hl.dsp.exec_cmd("firefox")                             },
    { "SUPER",           "f",                     hl.dsp.exec_cmd("nautilus")                            },
    { "SUPER",           "a",                     hl.dsp.exec_cmd(donbox .. " activity")                 },

    -- Scratchpads
    { "SUPER",           "d",                     hl.dsp.workspace.toggle_special("term")                },
    { "SUPER",           "e",                     hl.dsp.workspace.toggle_special("mail")                },

    -- Shell
    { "SUPER",           "space",                 hl.dsp.exec_cmd("qs -c donbox ipc call launcher toggle") },
    { "SUPER + CTRL",    "b",                     hl.dsp.exec_cmd("qs -c donbox ipc call bar toggleFocused") },
    { "SUPER + CTRL",    "c",                     hl.dsp.exec_cmd(donbox .. " menu session.settings")    },

    -- Notifications
    { "SUPER",           "n",                     hl.dsp.exec_cmd("qs -c donbox ipc call notifications toggleCentre") },
    { "SUPER + SHIFT",   "n",                     hl.dsp.exec_cmd("qs -c donbox ipc call notifications toggleDnd")    },
    { "SUPER + CTRL",    "n",                     hl.dsp.exec_cmd("qs -c donbox ipc call notifications dismissAll")   },

    -- Menu
    { "SUPER + ALT",     "space",                 hl.dsp.exec_cmd(donbox .. " menu")                     },

    -- Insertions
    { "SUPER + CTRL",    "e",                     hl.dsp.exec_cmd(donbox .. " menu emoji")               },
    { "SUPER + CTRL",    "v",                     hl.dsp.exec_cmd(donbox .. " menu clipboard")           },

    -- Appearance
    { "SUPER + ALT",     "t",                     hl.dsp.exec_cmd(donbox .. " menu style.theme")         },
    { "SUPER + ALT",     "a",                     hl.dsp.exec_cmd(donbox .. " menu style.accent")        },
    { "SUPER + ALT",     "w",                     hl.dsp.exec_cmd(donbox .. " menu style.wallpaper")     },

    -- Windows
    { "SUPER + SHIFT",   "q",                     hl.dsp.window.close()                                  },
    { "SUPER + SHIFT",   "x",                     hl.dsp.window.pin()                                    },
    { "SUPER + SHIFT",   "f",                     hl.dsp.window.fullscreen()                             },
    { "SUPER + SHIFT",   "space",                 hl.dsp.window.float({ action = "toggle" })             },

    -- Layouts
    { "SUPER + SHIFT",   "t",                     layouts.set("master")                                  },
    { "SUPER + SHIFT",   "m",                     layouts.set("monocle")                                 },
    { "SUPER + SHIFT",   "s",                     layouts.set("scrolling")                               },
    { "SUPER + SHIFT",   "backslash",             layouts.cycle                                          },
    { "SUPER + SHIFT",   "g",                     gaps.toggle                                            },

    -- Navigation
    { "SUPER",           "h",                     hl.dsp.focus({ direction = "left" })                   },
    { "SUPER",           "j",                     actions.focus_step("down")                             },
    { "SUPER",           "k",                     actions.focus_step("up")                               },
    { "SUPER",           "l",                     hl.dsp.focus({ direction = "right" })                  },
    { "SUPER + SHIFT",   "h",                     hl.dsp.window.move({ direction = "left" })             },
    { "SUPER + SHIFT",   "j",                     hl.dsp.window.move({ direction = "down" })             },
    { "SUPER + SHIFT",   "k",                     hl.dsp.window.move({ direction = "up" })               },
    { "SUPER + SHIFT",   "l",                     hl.dsp.window.move({ direction = "right" })            },

    -- Monitors
    { "SUPER",           "comma",                 hl.dsp.focus({ monitor = "-1" })                       },
    { "SUPER",           "period",                hl.dsp.focus({ monitor = "+1" })                       },
    { "SUPER + SHIFT",   "comma",                 hl.dsp.window.move({ monitor = "-1" })                 },
    { "SUPER + SHIFT",   "period",                hl.dsp.window.move({ monitor = "+1" })                 },

    -- Sizing
    { "SUPER + CTRL",    "h",                     actions.resize(-RESIZE_STEP, 0)                        },
    { "SUPER + CTRL",    "j",                     actions.resize(0, RESIZE_STEP)                         },
    { "SUPER + CTRL",    "k",                     actions.resize(0, -RESIZE_STEP)                        },
    { "SUPER + CTRL",    "l",                     actions.resize(RESIZE_STEP, 0)                         },

    -- Magnifier
    { "SUPER",           "equal",                 actions.zoom_in                                        },
    { "SUPER",           "minus",                 actions.zoom_out                                       },
    { "SUPER",           "0",                     actions.zoom_reset                                     },
    { "SUPER",           "z",                     actions.zoom_follow_toggle                             },
    { "SUPER + SHIFT",   "z",                     actions.caret_follow_toggle                            },
    { "SUPER",           "mouse_up",              actions.zoom_in                                        },
    { "SUPER",           "mouse_down",            actions.zoom_out                                       },

    -- Comfort
    { "SUPER + CTRL",    "m",                     hl.dsp.exec_cmd(donbox .. " motion reduced toggle")    },
    { "SUPER + ALT",     "n",                     hl.dsp.exec_cmd(donbox .. " nightshift toggle")        },

    -- Session
    { "SUPER",           "Escape",                hl.dsp.exec_cmd(donbox .. " menu power")               },
    { "SUPER + SHIFT",   "Escape",                hl.dsp.exec_cmd("loginctl lock-session")               },
    { "SUPER + CTRL",    "Escape",                hl.dsp.exec_cmd(donbox .. " idle screensaver start")   },
    { "SUPER + ALT",     "e",                     hl.dsp.exit()                                          },

    -- Volume and brightness
    { "SUPER + ALT",     "up",                    hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), held },
    { "SUPER + ALT",     "down",                  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      held },
    { "SUPER + ALT",     "m",                     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     locked },
    { "SUPER + ALT",     "right",                 hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  held },
    { "SUPER + ALT",     "left",                  hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  held },
    { "",                "XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), held },
    { "",                "XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      held },
    { "",                "XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     locked },
    { "",                "XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   locked },
    { "",                "XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  held },
    { "",                "XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  held },

    -- Media
    { "",                "XF86AudioPlay",         hl.dsp.exec_cmd("playerctl play-pause"),                           locked },
    { "",                "XF86AudioPause",        hl.dsp.exec_cmd("playerctl play-pause"),                           locked },
    { "",                "XF86AudioNext",         hl.dsp.exec_cmd("playerctl next"),                                 locked },
    { "",                "XF86AudioPrev",         hl.dsp.exec_cmd("playerctl previous"),                             locked },

    -- Screenshots
    { "SUPER",                  "p",              hl.dsp.exec_cmd(donbox .. " screenshot output")        },
    { "SUPER + SHIFT",          "p",              hl.dsp.exec_cmd(donbox .. " screenshot region")        },
    { "SUPER + CTRL",           "p",              hl.dsp.exec_cmd(donbox .. " screenshot output save")   },
    { "SUPER + CTRL + SHIFT",   "p",              hl.dsp.exec_cmd(donbox .. " screenshot region save")   },
    { "",                       "Print",          hl.dsp.exec_cmd(donbox .. " screenshot output")        },
    { "SHIFT",                  "Print",          hl.dsp.exec_cmd(donbox .. " screenshot region")        },
    { "CTRL",                   "Print",          hl.dsp.exec_cmd(donbox .. " screenshot output save")   },
    { "CTRL + SHIFT",           "Print",          hl.dsp.exec_cmd(donbox .. " screenshot region save")   },

    -- Pointer
    { "SUPER",           "mouse:272",             hl.dsp.window.drag(),                                              mouse },
    { "SUPER + SHIFT",   "mouse:272",             hl.dsp.window.resize(),                                            mouse },
}

for index = 1, 9 do
    local workspace = "r~" .. index
    table.insert(binds, { "SUPER",         index, hl.dsp.focus({ workspace = workspace })      })
    table.insert(binds, { "SUPER + SHIFT", index, layouts.send_to_workspace(workspace)          })
end

for _, bind in ipairs(binds) do
    local mods, key, action, options = bind[1], bind[2], bind[3], bind[4]
    local combo = mods ~= "" and (mods .. " + " .. key) or tostring(key)
    hl.bind(combo, action, options)
end
