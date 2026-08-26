* {
    background:      {{ background }};
    background-alt:  {{ lighter_background }};
    foreground:      {{ foreground }};
    foreground-dim:  {{ dark_foreground }};
    accent:          {{ accent }};
    urgent:          {{ red }};
    border-colour:   {{ muted }};
}

window {
    width:            760px;
    border:           2px;
    border-radius:    12px;
    border-color:     @border-colour;
    background-color: @background;
    padding:          0;
}

mainbox {
    background-color: transparent;
    padding:          16px;
    spacing:          12px;
    children:         [ inputbar, listview ];
}

inputbar {
    background-color: @background-alt;
    text-color:       @foreground;
    border-radius:    8px;
    padding:          12px 14px;
    spacing:          10px;
    children:         [ prompt, entry ];
}

prompt {
    background-color: transparent;
    text-color:       @accent;
}

entry {
    background-color: transparent;
    text-color:       @foreground;
    placeholder:      "Search";
    placeholder-color: @foreground-dim;
}

listview {
    background-color: transparent;
    lines:            10;
    columns:          1;
    scrollbar:        false;
    spacing:          4px;
    dynamic:          true;
}

element {
    background-color: transparent;
    text-color:       @foreground;
    border-radius:    8px;
    padding:          10px 12px;
    spacing:          12px;
}

element selected {
    background-color: @accent;
    text-color:       @background;
}

element urgent {
    text-color: @urgent;
}

element-icon {
    background-color: transparent;
    size:             28px;
    vertical-align:   0.5;
}

element-text {
    background-color: transparent;
    text-color:       inherit;
    vertical-align:   0.5;
}

message {
    background-color: @background-alt;
    border-radius:    8px;
    padding:          10px;
}

textbox {
    background-color: transparent;
    text-color:       @foreground;
}
