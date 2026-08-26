@define-color theme_bg_color {{ background }};
@define-color theme_fg_color {{ foreground }};
@define-color theme_base_color {{ dark_background }};
@define-color theme_text_color {{ foreground }};
@define-color theme_selected_bg_color {{ accent }};
@define-color theme_selected_fg_color {{ background }};
@define-color theme_unfocused_bg_color {{ background }};
@define-color theme_unfocused_fg_color {{ foreground }};
@define-color theme_unfocused_base_color {{ dark_background }};
@define-color theme_unfocused_text_color {{ foreground }};
@define-color theme_unfocused_selected_bg_color {{ accent }};
@define-color theme_unfocused_selected_fg_color {{ background }};
@define-color insensitive_bg_color {{ background }};
@define-color insensitive_fg_color {{ dark_foreground }};
@define-color insensitive_base_color {{ dark_background }};
@define-color borders {{ muted }};
@define-color unfocused_borders {{ muted }};
@define-color success_color {{ green }};
@define-color warning_color {{ yellow }};
@define-color error_color {{ red }};

*:selected,
*:selected:focus,
selection {
    background-color: @theme_selected_bg_color;
    color: @theme_selected_fg_color;
}
