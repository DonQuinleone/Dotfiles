set -g THEME_MODE {{ mode }}
set -g THEME_ACCENT {{ accent_strip }}
set -g THEME_FG {{ foreground_strip }}
set -g THEME_FG_DIM {{ dark_foreground_strip }}
set -g THEME_BG {{ background_strip }}
set -g THEME_GOOD {{ green_strip }}
set -g THEME_WARN {{ yellow_strip }}
set -g THEME_BAD {{ red_strip }}

set -g fish_color_normal {{ foreground_strip }}
set -g fish_color_command {{ accent_strip }}
set -g fish_color_function {{ accent_strip }}
set -g fish_color_builtin {{ orange_strip }}
set -g fish_color_keyword {{ orange_strip }}
set -g fish_color_quote {{ green_strip }}
set -g fish_color_redirection {{ yellow_strip }}
set -g fish_color_operator {{ yellow_strip }}
set -g fish_color_end {{ dark_foreground_strip }}
set -g fish_color_param {{ foreground_strip }}
set -g fish_color_option {{ orange_strip }}
set -g fish_color_comment {{ dark_foreground_strip }}
set -g fish_color_escape {{ yellow_strip }}
set -g fish_color_error {{ red_strip }}
set -g fish_color_cancel {{ red_strip }}
set -g fish_color_autosuggestion \
    {{ mix_strip dark_foreground background 45% }}
set -g fish_color_valid_path --underline
set -g fish_color_selection --background={{ selection }}
set -g fish_color_search_match --background={{ selection }}
set -g fish_color_history_current {{ accent_strip }} --bold

set -g fish_pager_color_prefix {{ accent_strip }}
set -g fish_pager_color_completion {{ foreground_strip }}
set -g fish_pager_color_description {{ dark_foreground_strip }}
set -g fish_pager_color_progress {{ dark_foreground_strip }}
set -g fish_pager_color_selected_background --background={{ selection }}
