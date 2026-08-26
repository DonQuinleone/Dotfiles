return {
    background = "{{ mode }}",
    ui = {
        accent = "{{ accent }}",
        accentDim = "{{ mix accent background 15% }}",
        bg = "{{ background }}",
        bgAlt = "{{ dark_background }}",
        border = "{{ muted }}",
        borderStrong = "{{ mix muted foreground 25% }}",
        onAccent = "{{ background }}",
        surface = "{{ lighter_background }}",
    },
    text = {
        accent = "{{ accent }}",
        bad = "{{ red }}",
        fg = "{{ foreground }}",
        fgDim = "{{ dark_foreground }}",
        good = "{{ green }}",
        warn = "{{ yellow }}",
    },
}
