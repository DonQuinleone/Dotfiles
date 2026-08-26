* {
    font-family: "{{ theme_font_ui }}", sans-serif;
    font-size: {{ theme_size_bar }}px;
    font-weight: {{ theme_weight_body }};
    min-height: 0;
    border: none;
    border-radius: 0;
    box-shadow: none;
    text-shadow: none;
}

window#waybar {
    background-color: {{ dark_background }};
    color: {{ foreground }};
    border-bottom: 1px solid {{ muted }};
}

.modules-left {
    padding-left: 8px;
}

.modules-right {
    padding-right: 10px;
}

#clock,
#battery,
#custom-caffeine,
#custom-dnd,
#custom-record,
#custom-tailscale,
#tray {
    padding: 7px 2px;
    background-color: transparent;
}

#clock {
    font-weight: {{ theme_weight_bold }};
}

#workspaces {
    padding: 0;
    background-color: transparent;
}

#workspaces button {
    padding: 6px 6px 0 6px;
    margin: 0;
    color: {{ dark_foreground }};
    background-color: transparent;
    border-bottom: 2px solid transparent;
}

#workspaces button.empty {
    color: {{ mix dark_foreground dark_background 60% }};
}

#workspaces button.visible {
    color: {{ foreground }};
}

#workspaces button.active {
    color: {{ foreground }};
    border-bottom-color: {{ accent }};
}

#workspaces button.urgent {
    color: {{ red }};
    border-bottom-color: {{ red }};
}

#workspaces button:hover {
    color: {{ foreground }};
    border-bottom-color: {{ muted }};
}

#battery.warning {
    color: {{ yellow }};
}

#battery.critical {
    color: {{ red }};
}

#battery.charging {
    color: {{ green }};
}

#custom-tailscale.up,
#custom-tailscale.exit {
    color: {{ green }};
}

#custom-tailscale.off {
    color: {{ dark_foreground }};
}

#custom-tailscale.attention {
    color: {{ yellow }};
}

#custom-record {
    color: {{ red }};
}

#custom-dnd {
    color: {{ yellow }};
}

#custom-caffeine {
    color: {{ accent }};
}
