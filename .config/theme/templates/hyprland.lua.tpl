local active = "rgba({{ accent_strip }}ff)"
local inactive = "rgba({{ muted_strip }}ff)"

hl.config({
    general = {
        col = {
            active_border = active,
            inactive_border = inactive,
        },
    },
    group = {
        col = {
            border_active = active,
            border_inactive = inactive,
        },
        groupbar = {
            font_family = "{{ theme_font_ui }}",
            font_size = {{ theme_size_ui }},
            col = {
                active = "rgba({{ accent_strip }}ff)",
                inactive = "rgba({{ lighter_background_strip }}ff)",
            },
            text_color = "rgba({{ background_strip }}ff)",
            text_color_inactive = "rgba({{ foreground_strip }}ff)",
        },
    },
    misc = {
        background_color = "rgba({{ background_strip }}ff)",
    },
})
