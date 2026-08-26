* {
    font-family: "{{ theme_font_ui }}", "{{ theme_font_mono }}";
    font-size: {{ theme_size_ui }}px;
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
    padding: 0 10px;
    margin: 6px 2px;
    border-radius: 8px;
    color: {{ dark_foreground }};
    background: transparent;
}

#workspaces button:hover {
    background: {{ lighter_background }};
    color: {{ foreground }};
}

#workspaces button.active {
    background: {{ accent }};
    color: {{ background }};
}

#workspaces button.urgent {
    background: {{ red }};
    color: {{ background }};
}

#clock {
    color: {{ foreground }};
    font-weight: {{ theme_weight_bold }};
    padding: 0 12px;
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
    padding: 0 10px;
    margin: 6px 2px;
    border-radius: 8px;
    background: {{ lighter_background }};
    color: {{ foreground }};
}

#tray {
    background: transparent;
}

#custom-updates.pending {
    background: {{ yellow }};
    color: {{ background }};
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
    background: {{ red }};
    color: {{ background }};
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
