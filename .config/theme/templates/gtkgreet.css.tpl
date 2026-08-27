window {
    background-image: url("/var/lib/greeter-theme/background");
    background-size: cover;
    background-position: center;
    color: {{ foreground }};
    font-family: "{{ theme_font_ui }}";
}

box, grid, frame, viewport, scrolledwindow {
    background-color: transparent;
    border: none;
}

box#body {
    background-color: alpha({{ background }}, 0.86);
    border: 2px solid {{ accent }};
    border-radius: 14px;
    padding: 28px 32px;
    margin: 24px;
}

label {
    background-color: transparent;
    color: {{ foreground }};
    font-size: {{ theme_size_ui }}px;
}

label#clock {
    background-color: transparent;
    color: {{ foreground }};
    font-size: 46px;
    font-weight: {{ theme_weight_bold }};
    padding-bottom: 14px;
}

entry {
    background-color: {{ dark_background }};
    background-image: none;
    color: {{ foreground }};
    caret-color: {{ accent }};
    border: 1px solid {{ muted }};
    border-radius: 8px;
    padding: 10px 12px;
    margin: 4px 0;
}

entry:focus {
    border-color: {{ accent }};
}

entry#command {
    opacity: 0;
    min-height: 0;
    padding: 0;
    margin: 0;
    border: none;
    font-size: 0;
}

button {
    background-image: none;
    background-color: {{ accent }};
    color: {{ background }};
    border: none;
    border-radius: 8px;
    padding: 10px 18px;
    margin-top: 10px;
}

button:hover {
    background-color: {{ mix accent foreground 15% }};
}

combobox button {
    background-color: {{ dark_background }};
    color: {{ foreground }};
}
