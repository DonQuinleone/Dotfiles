/* idiom: symlink. ~/.config/gtk-4.0/gtk.css is a link to
 * current/theme/gtk4.css. libadwaita 1.6 moved these to CSS
 * variables and left the older spelling deprecated but read,
 * so both go out: the variables are what a current libadwaita
 * honours and the @define-color names are what plain GTK 4
 * applications still look for. A surface missing here keeps
 * Adwaita's own grey, and one is enough to leave a window
 * looking like stock GNOME. */
:root {
    --window-bg-color: {{ background }};
    --window-fg-color: {{ foreground }};
    --view-bg-color: {{ dark_background }};
    --view-fg-color: {{ foreground }};
    --headerbar-bg-color: {{ background }};
    --headerbar-fg-color: {{ foreground }};
    --headerbar-border-color: {{ muted }};
    --headerbar-backdrop-color: {{ background }};
    --sidebar-bg-color: {{ dark_background }};
    --sidebar-fg-color: {{ foreground }};
    --sidebar-border-color: {{ muted }};
    --sidebar-backdrop-color: {{ background }};
    --secondary-sidebar-bg-color: {{ lighter_background }};
    --secondary-sidebar-fg-color: {{ foreground }};
    --secondary-sidebar-border-color: {{ muted }};
    --secondary-sidebar-backdrop-color: {{ background }};
    --card-bg-color: {{ lighter_background }};
    --card-fg-color: {{ foreground }};
    --thumbnail-bg-color: {{ lighter_background }};
    --thumbnail-fg-color: {{ foreground }};
    --dialog-bg-color: {{ dark_background }};
    --dialog-fg-color: {{ foreground }};
    --popover-bg-color: {{ lighter_background }};
    --popover-fg-color: {{ foreground }};
    --accent-bg-color: {{ accent }};
    --accent-fg-color: {{ background }};
    --accent-color: {{ accent }};
    --destructive-bg-color: {{ red }};
    --destructive-fg-color: {{ background }};
    --destructive-color: {{ red }};
    --success-bg-color: {{ green }};
    --success-fg-color: {{ background }};
    --success-color: {{ green }};
    --warning-bg-color: {{ yellow }};
    --warning-fg-color: {{ background }};
    --warning-color: {{ yellow }};
    --borders: {{ muted }};
}

@define-color window_bg_color {{ background }};
@define-color window_fg_color {{ foreground }};
@define-color view_bg_color {{ dark_background }};
@define-color view_fg_color {{ foreground }};
@define-color headerbar_bg_color {{ background }};
@define-color headerbar_fg_color {{ foreground }};
@define-color headerbar_border_color {{ muted }};
@define-color headerbar_backdrop_color {{ background }};
@define-color sidebar_bg_color {{ dark_background }};
@define-color sidebar_fg_color {{ foreground }};
@define-color sidebar_border_color {{ muted }};
@define-color sidebar_backdrop_color {{ background }};
@define-color secondary_sidebar_bg_color {{ lighter_background }};
@define-color secondary_sidebar_fg_color {{ foreground }};
@define-color secondary_sidebar_border_color {{ muted }};
@define-color secondary_sidebar_backdrop_color {{ background }};
@define-color card_bg_color {{ lighter_background }};
@define-color card_fg_color {{ foreground }};
@define-color thumbnail_bg_color {{ lighter_background }};
@define-color thumbnail_fg_color {{ foreground }};
@define-color dialog_bg_color {{ dark_background }};
@define-color dialog_fg_color {{ foreground }};
@define-color popover_bg_color {{ lighter_background }};
@define-color popover_fg_color {{ foreground }};
@define-color accent_bg_color {{ accent }};
@define-color accent_fg_color {{ background }};
@define-color accent_color {{ accent }};
@define-color destructive_bg_color {{ red }};
@define-color destructive_fg_color {{ background }};
@define-color destructive_color {{ red }};
@define-color success_bg_color {{ green }};
@define-color success_fg_color {{ background }};
@define-color success_color {{ green }};
@define-color warning_bg_color {{ yellow }};
@define-color warning_fg_color {{ background }};
@define-color warning_color {{ yellow }};
@define-color borders {{ muted }};

selection {
    background-color: @accent_bg_color;
    color: @accent_fg_color;
}
