local actions = require("actions")
local gaps = require("gaps")
local layouts = require("layouts")

local scripts = "$HOME/.config/hypr/scripts"
local step = actions.ZOOM_STEP
local RESIZE_STEP = 60

local held = { locked = true, repeating = true }
local locked = { locked = true }
local mouse = { mouse = true }

local binds = {
    -- Session
    { "SUPER + SHIFT",   "e",                     hl.dsp.exit()                                          },
    { "SUPER",           "Escape",                hl.dsp.exec_cmd(scripts .. "/power-menu")              },
    { "SUPER + SHIFT",   "Escape",                hl.dsp.exec_cmd("loginctl lock-session")               },
    { "SUPER + CTRL",    "Escape",                hl.dsp.exec_cmd(scripts .. "/idle-screensaver start")  },

    -- Applications
    { "SUPER",           "Return",                hl.dsp.exec_cmd("ghostty")                             },
    { "SUPER",           "b",                     hl.dsp.exec_cmd("firefox")                             },
    { "SUPER",           "f",                     hl.dsp.exec_cmd("nautilus")                            },

    -- Scratchpads
    { "SUPER",           "d",                     hl.dsp.workspace.toggle_special("term")                },
    { "SUPER",           "e",                     hl.dsp.workspace.toggle_special("mail")                },

    -- Shell
    { "SUPER + SHIFT",   "b",                     hl.dsp.exec_cmd("qs -c ember ipc call bar toggleFocused") },
    { "SUPER",           "space",                 hl.dsp.exec_cmd("qs -c ember ipc call launcher toggle") },
    { "SUPER + SHIFT",   "t",                     hl.dsp.exec_cmd(scripts .. "/theme-menu")              },
    { "SUPER + CTRL",    "t",                     hl.dsp.exec_cmd(scripts .. "/theme-menu accent")       },
    { "SUPER + SHIFT",   "s",                     hl.dsp.exec_cmd("qs -c ember ipc call quickSettings toggle") },

    -- Notifications
    { "SUPER",           "n",                     hl.dsp.exec_cmd("qs -c ember ipc call notifications toggleCentre") },
    { "SUPER + SHIFT",   "n",                     hl.dsp.exec_cmd("qs -c ember ipc call notifications toggleDnd")    },
    { "SUPER + CTRL",    "n",                     hl.dsp.exec_cmd("qs -c ember ipc call notifications dismissAll")   },

    -- Windows
    { "SUPER",           "q",                     hl.dsp.window.close()                                  },
    { "SUPER",           "x",                     hl.dsp.window.pin()                                    },
    { "SUPER + SHIFT",   "f",                     hl.dsp.window.fullscreen()                             },
    { "SUPER + SHIFT",   "space",                 hl.dsp.window.float({ action = "toggle" })             },

    -- Layouts
    { "SUPER",           "t",                     layouts.set("master")                                  },
    { "SUPER",           "m",                     layouts.set("monocle")                                 },
    { "SUPER",           "s",                     layouts.set("scrolling")                               },
    { "SUPER",           "backslash",             layouts.cycle                                          },
    { "SUPER",           "g",                     gaps.toggle                                            },

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
    { "SUPER",           "equal",                 actions.zoom(step)                                     },
    { "SUPER",           "minus",                 actions.zoom(-step)                                    },
    { "SUPER",           "0",                     actions.zoom_reset                                     },
    { "SUPER",           "z",                     actions.zoom_follow_toggle                             },
    { "SUPER + SHIFT",   "z",                     actions.caret_follow_toggle                            },
    { "SUPER",           "mouse_up",              actions.zoom(step)                                     },
    { "SUPER",           "mouse_down",            actions.zoom(-step)                                    },

    -- Volume and brightness
    { "SUPER + ALT",     "k",                     hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), held },
    { "SUPER + ALT",     "j",                     hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      held },
    { "SUPER + ALT",     "m",                     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     locked },
    { "SUPER + ALT",     "l",                     hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  held },
    { "SUPER + ALT",     "h",                     hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  held },
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
    { "SUPER",                  "p",              hl.dsp.exec_cmd(scripts .. "/screenshot output")       },
    { "SUPER + SHIFT",          "p",              hl.dsp.exec_cmd(scripts .. "/screenshot region")       },
    { "SUPER + CTRL",           "p",              hl.dsp.exec_cmd(scripts .. "/screenshot output save")  },
    { "SUPER + CTRL + SHIFT",   "p",              hl.dsp.exec_cmd(scripts .. "/screenshot region save")  },
    { "",                       "Print",          hl.dsp.exec_cmd(scripts .. "/screenshot output")       },
    { "SHIFT",                  "Print",          hl.dsp.exec_cmd(scripts .. "/screenshot region")       },
    { "CTRL",                   "Print",          hl.dsp.exec_cmd(scripts .. "/screenshot output save")  },
    { "CTRL + SHIFT",           "Print",          hl.dsp.exec_cmd(scripts .. "/screenshot region save")  },

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
