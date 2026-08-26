* {
    font-family: "{{ theme_font_ui }}", "{{ theme_font_mono }}";
    font-size: 14px;
    border: none;
    border-radius: 0;
    min-height: 0;
}

window#waybar {
    background: {{ background }};
    color: {{ foreground }};
}

window#waybar.hidden {
    opacity: 0.0;
}

#workspaces {
    margin-left: 6px;
}

#workspaces button {
    padding: 0 5px;
    margin: 0;
    border: none;
    border-radius: 0;
    background: transparent;
    color: {{ muted }};
}

#workspaces button:hover {
    background: transparent;
    color: {{ foreground }};
}

#workspaces button.active {
    background: transparent;
    color: {{ accent }};
}

#workspaces button.urgent {
    background: transparent;
    color: {{ red }};
}

#clock {
    color: {{ foreground }};
    font-weight: {{ theme_weight_bold }};
    padding: 0 10px;
}

#tray,
#cpu,
#memory,
#network,
#bluetooth,
#pulseaudio,
#battery,
#custom-notifications,
#custom-updates {
    padding: 0 8px;
    margin: 0;
    background: transparent;
    color: {{ dark_foreground }};
}

#clock,
#battery {
    color: {{ foreground }};
}

#custom-updates.pending {
    color: {{ yellow }};
}

#custom-notifications.silenced {
    color: {{ dark_foreground }};
}

#pulseaudio.muted,
#pulseaudio.source-muted {
    color: {{ dark_foreground }};
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

tooltip {
    background: {{ dark_background }};
    color: {{ foreground }};
    border: 1px solid {{ muted }};
    border-radius: 8px;
}
