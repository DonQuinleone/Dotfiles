window {
    background-color: {{ background }};
    color: {{ foreground }};
}

box#body {
    background-color: {{ lighter_background }};
    border: 2px solid {{ accent }};
    border-radius: 12px;
    padding: 24px;
}

label {
    color: {{ foreground }};
    font-family: "{{ theme_font_ui }}";
    font-size: {{ theme_size_ui }}px;
}

entry {
    background-color: {{ dark_background }};
    color: {{ foreground }};
    border: 1px solid {{ muted }};
    border-radius: 8px;
    padding: 10px 12px;
}

entry:focus {
    border-color: {{ accent }};
}

button {
    background-color: {{ accent }};
    color: {{ background }};
    border: none;
    border-radius: 8px;
    padding: 10px 16px;
}

button:hover {
    background-color: {{ mix accent foreground 15% }};
}

combobox button {
    background-color: {{ dark_background }};
    color: {{ foreground }};
}
